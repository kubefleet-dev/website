---
title: Enabling Drift Detection in Fleet
description: How to enable drift detection in Fleet
weight: 11
---

This guide provides an overview on how to enable drift detection in Fleet. This feature can help
developers and admins identify (and act upon) configuration drifts in their KubeFleet system,
which are often brought by temporary fixes, inadvertent changes, and failed automations.

> Before you begin
>
> The new drift detection experience is currently in preview. 
>
> Note that the APIs for the new experience are only available in the Fleet v1beta1 API, not the v1 API. If you do not see the new APIs in command outputs, verify that you are explicitly requesting the v1beta1 API objects, as opposed to the v1 API objects (the default). 

## What is a drift?

A drift occurs when a non-Fleet agent (e.g., a developer or a controller) makes changes to
a field of a Fleet-managed resource directly on the member cluster side without modifying
the corresponding resource template created on the hub cluster.

See the steps below for an example; the code assumes that you have a Fleet of two clusters,
`member-1` and `member-2`.

* Switch to the hub cluster in the preview environment:

    ```sh
    kubectl config use-context hub-admin
    ```

* Create a namespace, `work`, on the hub cluster, with some labels:

    ```sh
    kubectl create ns work
    kubectl label ns work app=work
    kubectl label ns work owner=redfield
    ```

* Create a CRP object, which places the namespace on all member clusters:

    ```sh
    cat <<EOF | kubectl apply -f -
    # The YAML configuration of the CRP object.
    apiVersion: placement.kubernetes-fleet.io/v1beta1
    kind: ClusterResourcePlacement
    metadata:
      name: work
    spec:
      resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1
          # Select all namespaces with the label app=work.      
          labelSelector:
            matchLabels:
              app: work
      policy:
        placementType: PickAll
      strategy:
        # For simplicity reasons, the CRP is configured to roll out changes to
        # all member clusters at once. This is not a setup recommended for production
        # use.         
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 100%
          unavailablePeriodSeconds: 1            
    EOF
    ```

* Fleet should be able to finish the placement within seconds. To verify the progress, run the command below:

    ```sh
    kubectl get clusterresourceplacement.v1beta1.placement.kubernetes-fleet.io work
    ```

    Confirm that in the output, Fleet has reported that the placement is of the `Available` state.

* Switch to the first member cluster, `member-1`:

    ```sh
    kubectl config use-context member-1-admin
    ```

* You should see the namespace, `work`, being placed in this member cluster:

    ```sh
    kubectl get ns work --show-labels
    ```

    The output should look as follows; note that all the labels have been set 
    (the `kubernetes.io/metadata.name` label is added by the Kubernetes system automatically):

    ```
    NAME     STATUS   AGE   LABELS
    work     Active   91m   app=work,owner=redfield,kubernetes.io/metadata.name=work
    ```

* Anyone with proper access to the member cluster could modify the namespace as they want;
for example, one can set the `owner` label to a different value:

    ```sh
    kubectl label ns work owner=wesker --overwrite
    kubectl label ns work use=hack --overwrite
    ```

    **Now the namespace has drifted from its intended state.**

Note that drifts are not necessarily a bad thing: to ensure system availability, often developers 
and admins would need to make ad-hoc changes to the system; for example, one might need to set a
Deployment on a member cluster to use a different image from its template (as kept on the hub
cluster) to test a fix. In the current version of Fleet, the system is not drift-aware, which
means that Fleet will simply re-apply the resource template periodically with or without drifts.

In the case above:

* Since the owner label has been set on the resource template, its value would be overwritten by
Fleet, from `wesker` to `redfield`, within minutes. This provides a great consistency guarantee
but also blocks out all possibilities of expedient fixes/changes, which can be an inconvenience at times.

* The `use` label is not a part of the resource template, so it will not be affected by any
apply op performed by Fleet. Its prolonged presence might pose an issue, depending on the
nature of the setup.

## How Fleet can be used to handle drifts gracefully

Fleet aims to provide an experience that:

* ✅ allows developers and admins to make changes on the member cluster side when necessary; and
* ✅ helps developers and admins to detect drifts, esp. long-living ones, in their systems,
so that they can be handled properly; and
* ✅ grants developers and admins great flexibility on when and how drifts should be handled.

To enable the new experience, set proper apply strategies in the CRP object, as
illustrated by the steps below:

* Switch to the hub cluster:

    ```sh
    kubectl config use-context hub-admin
    ```

* Update the existing CRP (`work`), to use an apply strategy with the `whenToApply` field set to
`IfNotDrifted`:

    ```sh
    cat <<EOF | kubectl apply -f -
    # The YAML configuration of the CRP object.
    apiVersion: placement.kubernetes-fleet.io/v1beta1
    kind: ClusterResourcePlacement
    metadata:
      name: work
    spec:
      resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1
          # Select all namespaces with the label app=work. 
          labelSelector:
            matchLabels:
              app: work
      policy:
        placementType: PickAll
      strategy:
        applyStrategy:
          whenToApply: IfNotDrifted
        # For simplicity reasons, the CRP is configured to roll out changes to
        # all member clusters at once. This is not a setup recommended for production
        # use.      
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 100%
          unavailablePeriodSeconds: 1                
    EOF
    ```

    The `whenToApply` field features two options:
    
    * `Always`: this is the default option 😑. With this setting, Fleet will periodically apply
    the resource templates from the hub cluster to member clusters, with or without drifts.
    This is consistent with the behavior before the new drift detection and takeover experience.
    * `IfNotDrifted`: this is the new option ✨ provided by the drift detection mechanism. With
    this setting, Fleet will check for drifts periodically; if drifts are found, Fleet will stop
    applying the resource templates and report in the CRP status.

* Switch to the first member cluster and edit the labels for a second time, effectively re-introducing
a drift in the system. After it's done, switch back to the hub cluster:

    ```sh
    kubectl config use-context member-1-admin
    kubectl label ns work owner=wesker --overwrite
    kubectl label ns work use=hack --overwrite
    #
    kubectl config use-context hub-admin
    ```

* Fleet should be able to find the drifts swiftly (w/in a few seconds). Inspect the placement status Fleet
reports for each cluster:

    ```sh
    kubectl get clusterresourceplacement.v1beta1.placement.kubernetes-fleet.io work -o jsonpath='{.status.placementStatuses}' | jq
    # The command above uses JSON paths to query the relevant status information
    # directly and uses the jq utility to pretty print the output JSON.
    #
    # jq might not be available in your environment. You may have to install it
    # separately, or omit it from the command.
    #
    # If the output is empty, the status might have not been populated properly
    # yet. Retry in a few seconds; you may also want to switch the output type
    # from jsonpath to yaml to see the full object.
    ```

    The output should look like this:

    ```yaml
    {
        "clusterName": "member-1",
        "conditions": [
            ...
            {
                ...
                "status": "False",
                "type": "Applied"
            }
        ],
        "driftedPlacements": [
            {
                "firstDriftedObservedTime": "...",
                "kind": "Namespace",
                "name": "work",
                "observationTime": "...",
                "observedDrifts": [
                    {
                        "path": "/metadata/labels/owner",
                        "valueInHub": "redfield",
                        "valueInMember": "wesker"
                    }
                ],
                "targetClusterObservedGeneration": 0,
                "version": "v1"
            }
        ],
        "failedPlacements": [
            {
                "condition": {
                    "lastTransitionTime": "...",
                    "message": "Failed to apply the manifest (error: cannot apply manifest: drifts are found between the manifest and the object from the member cluster)",
                    "reason": "FoundDrifts",
                    "status": "False",
                    "type": "Applied"
                },
                "kind": "Namespace",
                "name": "work",
                "version": "v1"
            }
        ]
    },
    {
        "clusterName": "member-2",
        "conditions": [...]
    }
    ```

    You should see that cluster `member-1` has encountered an apply failure. The
    `failedPlacements` part explains exactly which manifests have failed on `member-1`
    and its reason; in this case, the apply op fails as Fleet finds out that the namespace
    `work` has drifted from its intended state. The `driftedPlacements` part specifies in
    detail which fields have drifted and the value differences between the hub
    cluster and the member cluster.

    Fleet will report the following information about a drift:

    * `group`, `kind`, `version`, `namespace`, and `name`: the resource that has drifted from its desired state.
    * `observationTime`: the timestamp where the current drift detail is collected.
    * `firstDriftedObservedTime`: the timestamp where the current drift is first observed.
    * `observedDrifts`: the drift details, specifically:
        * `path`: A JSON path (RFC 6901) that points to the drifted field;
        * `valueInHub`: the value at the JSON path as seen from the hub cluster resource template 
        (the desired state). If this value is absent, the field does not exist in the resource template.
        * `valueInMember`: the value at the JSON path as seen from the member cluster resource
        (the current state). If this value is absent, the field does not exist in the current state.
    * `targetClusterObservedGeneration`: the generation of the member cluster resource.

    The following `jq` query can help you better extract the drifted clusters and the drift
    details from the CRP status output:

    ```sh
    kubectl get clusterresourceplacement.v1beta1.placement.kubernetes-fleet.io work -o jsonpath='{.status.placementStatuses}' \
        | jq '[.[] | select (.driftedPlacements != null)] | map({clusterName, driftedPlacements})'
    # The command above uses JSON paths to query the relevant status information
    # directly and uses the jq utility to pretty print the output JSON.
    #
    # jq might not be available in your environment. You may have to install it
    # separately, or omit it from the command.
    ```

    This query would filter out all the clusters that do not have drifts and report only
    the drifted clusters with the drift details:

    ```yaml
    {
        "clusterName": "member-1",
        "driftedPlacements": [
            {
                "firstDriftedObservedTime": "...",
                "kind": "Namespace",
                "name": "work",
                "observationTime": "...",
                "observedDrifts": [
                    {
                        "path": "/metadata/labels/owner",
                        "valueInHub": "redfield",
                        "valueInMember": "wesker"
                    }
                ],
                "targetClusterObservedGeneration": 0,
                "version": "v1"
            }
        ]
    }
    ```


* To fix the drift, consider one of the following options:

    * Switch the `whenToApply` setting back to `Always`, which will instruct Fleet to overwrite
    the drifts using values from the hub cluster resource template; or
    * Edit the drifted field directly on the member cluster side, so that the value is
    consistent with that on the hub cluster; Fleet will periodically re-evaluate drifts
    and should report that no drifts are found soon after.
    * Delete the resource from the member cluster. Fleet will then re-apply the resource
    template and re-create the resource.

    > Important:
    >
    > The presence of drifts will **NOT** stop Fleet from rolling out newer resource versions. If you choose to edit the resource template on the hub cluster, Fleet will always apply the new resource template in the rollout process, which may also resolve the drift.

## Comparison options

One may have found out that the namespace on the member cluster has another drift, the
label `use=hack`, which is not reported in the CRP status by Fleet. This is because by default
Fleet compares only managed fields, i.e., fields that are explicitly specified in the resource
template. If a field is not populated on the hub cluster side, Fleet will not recognize its
presence on the member cluster side as a drift. This allows controllers on the member cluster
side to manage some fields automatically without Fleet's involvement; for example, one might would
like to use an HPA solution to auto-scale Deployments as appropriate and consequently decide not
to include the `.spec.replicas` field in the resource template.

Fleet recognizes that there might be cases where developers and admins would like to have their
resources look exactly the same across their fleet. If this scenario applies, one might set up
the `comparisonOptions` field in the apply strategy from the `partialComparison` value
(the default) to `fullComparison`:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: work
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      version: v1
      labelSelector:
        matchLabels:
          app: work
  policy:
    placementType: PickAll
  strategy:
    applyStrategy:
      whenToApply: IfNotDrifted
      comparisonOption: fullComparison
```

With this setting, Fleet will recognize the presence of any unmanaged fields (i.e., fields that
are present on the member cluster side, but not set on the hub cluster side) as drifts as well. 
If anyone adds a field to a Fleet-managed object directly on the member cluster, it would trigger
an apply error, which you can find out about the details the same way as illustrated in the
section above.

## Summary

Below is a summary of the synergy between the `whenToApply` and `comparisonOption` settings:

| `whenToApply` setting | `comparisonOption` setting | Drift scenario | Outcome
| -------- | ------- | -------- | ------- |
| `IfNotDrifted` | `partialComparison` | A managed field (i.e., a field that has been explicitly set in the hub cluster resource template) is edited. | Fleet will report an apply error in the status, plus the drift details. |
| `IfNotDrifted` | `partialComparison` | An unmanaged field (i.e., a field that has not been explicitly set in the hub cluster resource template) is edited/added. | N/A; the change is left untouched, and Fleet will ignore it. |
| `IfNotDrifted` | `fullComparison` | Any field is edited/added. | Fleet will report an apply error in the status, plus the drift details. |
| `Always` | `partialComparison` | A managed field (i.e., a field that has been explicitly set in the hub cluster resource template) is edited. | N/A; the change is overwritten shortly. |
| `Always` | `partialComparison` | An unmanaged field (i.e., a field that has not been explicitly set in the hub cluster resource template) is edited/added. | N/A; the change is left untouched, and Fleet will ignore it. |
| `Always` | `fullComparison` | Any field is edited/added. | The change on managed fields will be overwritten shortly; Fleet will report drift details about changes on unmanaged fields, but this is not considered as an apply error. |


