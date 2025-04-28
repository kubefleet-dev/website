---
title: Using the ReportDiff Apply Mode
description: How to use the ReportDiff apply mode
weight: 12
---

This guide provides an overview on how to use the `ReportDiff` apply mode, which allows one to
easily evaluate how things will change in the system without the risk of incurring unexpected
changes. In this mode, Fleet will check for configuration differences between the hub cluster
resource templates and their corresponding resources on the member clusters, but will not
perform any apply op. This is most helpful in cases of experimentation and drift/diff analysis.

# How the `ReportDiff` mode can help

To use this mode, simply set the `type` field in the apply strategy part of the CRP API
from `ClientSideApply` (the default) or `ServerSideApply` to `ReportDiff`. Configuration
differences are checked per `comparisonOption` setting, in consistency with the behavior
documented in the drift detection how-to guide; see the document for more information.

The steps below might help explain the workflow better; it assumes that you have a fleet
of two member clusters, `member-1` and `member-2`:

* Switch to the hub cluster and create a namespace, `work-3`, with some labels.

    ```sh
    kubectl config use-context hub-admin
    kubectl create ns work-3
    kubectl label ns work-3 app=work-3
    kubectl label ns work-3 owner=leon
    ```

* Create a CRP object that places the namespace to all member clusters:

    ```sh
    cat <<EOF | kubectl apply -f -
    # The YAML configuration of the CRP object.
    apiVersion: placement.kubernetes-fleet.io/v1beta1
    kind: ClusterResourcePlacement
    metadata:
      name: work-3
    spec:
      resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1
          # Select all namespaces with the label app=work-3. 
          labelSelector:
            matchLabels:
              app: work-3
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

* In a few seconds, Fleet will complete the placement. Verify that the CRP is available by checking its status.

* After the CRP becomes available, edit its apply strategy and set it to use the ReportDiff mode:

    ```sh
    cat <<EOF | kubectl apply -f -
    # The YAML configuration of the CRP object.
    apiVersion: placement.kubernetes-fleet.io/v1beta1
    kind: ClusterResourcePlacement
    metadata:
      name: work-3
    spec:
      resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1
          # Select all namespaces with the label app=work-3. 
          labelSelector:
            matchLabels:
              app: work-3
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
        applyStrategy:
          type: ReportDiff   
    EOF
    ```

* The CRP should remain available, as currently there is no configuration difference at all.
Check the `ClusterResourcePlacementDiffReported` condition in the status; it should report no error:

    ```sh
    kubectl get clusterresourceplacement.v1beta1.placement.kubernetes-fleet.io work-3 -o jsonpath='{.status.conditions[?(@.type=="ClusterResourcePlacementDiffReported")]}' | jq
    # The command above uses JSON paths to query the drift details directly and
    # uses the jq utility to pretty print the output JSON.
    #
    # jq might not be available in your environment. You may have to install it
    # separately, or omit it from the command.
    #
    # If the output is empty, the status might have not been populated properly
    # yet. You can switch the output type from jsonpath to yaml to see the full
    # object.
    ```

    ```json
    {
      "lastTransitionTime": "2025-03-19T06:45:58Z",
      "message": "Diff reporting in 2 cluster(s) has been completed",
      "observedGeneration": ...,
      "reason": "DiffReportingCompleted",
      "status": "True",
      "type": "ClusterResourcePlacementDiffReported"
    }
    ```

* Now, switch to the second member cluster and make a label change on the applied namespace.
After the change is done, switch back to the hub cluster.

    ```sh
    kubectl config use-context member-2-admin
    kubectl label ns work-3 owner=krauser --overwrite
    #
    kubectl config use-context hub-admin
    ```

* Fleet will detect this configuration difference shortly (w/in 15 seconds).
Verify that the diff details have been added to the CRP status, specifically reported
in the `diffedPlacements` part of the status; the `jq` query below
will list all the clusters with the `diffedPlacements` status information populated:

    ```sh
    kubectl get clusterresourceplacement.v1beta1.placement.kubernetes-fleet.io work-3 -o jsonpath='{.status.placementStatuses}' \
        | jq '[.[] | select (.diffedPlacements != null)] | map({clusterName, diffedPlacements})'
    # The command above uses JSON paths to retrieve the relevant status information
    # directly and uses the jq utility to query the data.
    #
    # jq might not be available in your environment. You may have to install it
    # separately, or omit it from the command.
    ```

    The output should be as follows:

    ```json
    {
        "clusterName": "member-2",
        "diffedPlacements": [
            {
                "firstDiffedObservedTime": "2025-03-19T06:49:54Z",
                "kind": "Namespace",
                "name": "work-3",
                "observationTime": "2025-03-19T06:50:25Z",
                "observedDiffs": [
                    {
                        "path": "/metadata/labels/owner",
                        "valueInHub": "leon",
                        "valueInMember": "krauser"
                    }
                ],
                "targetClusterObservedGeneration": 0,
                "version": "v1" 
            }
        ]
    }
    ```

    Fleet will report the following information about a configuration difference:

    * `group`, `kind`, `version`, `namespace`, and `name`: the resource that has configuration differences.
    * `observationTime`: the timestamp where the current diff detail is collected.
    * `firstDiffedObservedTime`: the timestamp where the current diff is first observed.
    * `observedDiffs`: the diff details, specifically:
        * `path`: A JSON path (RFC 6901) that points to the diff'd field;
        * `valueInHub`: the value at the JSON path as seen from the hub cluster resource template
        (the desired state). If this value is absent, the field does not exist in the resource template.
        * `valueInMember`: the value at the JSON path as seen from the member cluster resource
        (the current state). If this value is absent, the field does not exist in the current state.
    * `targetClusterObservedGeneration`: the generation of the member cluster resource.

## More information on the ReportDiff mode

* As mentioned earlier, with this mode no apply op will be run at all; it is up to the user to
decide the best way to handle found configuration differences (if any).
* Diff reporting becomes successful and complete as soon as Fleet finishes checking all the resources;
whether configuration differences are found or not has no effect on the diff reporting success status.
  *  When a resource change has been applied on the hub cluster side, for CRPs of the ReportDiff mode, 
  the change will be immediately rolled out to all member clusters (when the rollout strategy is set to 
  RollingUpdate, the default type), as soon as they have completed diff reporting earlier.
* It is worth noting that Fleet will only report differences on resources that have corresponding manifests 
on the hub cluster. If, for example, a namespace-scoped object has been created on the member cluster but 
not on the hub cluster, Fleet will ignore the object, even if its owner namespace has been selected for placement.