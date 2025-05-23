---
title: CRP Diff Reporting Failure TSG
description: Troubleshoot failures in the CRP diff reporting process
weight: 9
---

This document helps you troubleshoot diff reporting failures when using the KubeFleet CRP API,
specifically when you find that the `ClusterResourcePlacementDiffReported` status condition has been
set to `False` in the CRP status.

> Note
>
> If you are looking for troubleshooting steps on unexpected drift detection and/or configuration
> difference detection results, see the [Drift Detection and Configuration Difference Detection Failure TSG](DriftAndDiffDetection)
> instead.

> Note
>
> The `ClusterResourcePlacementDiffReported` status condition will only be set if the CRP has
> an apply strategy of the `ReportDiff` type. If your CRP uses `ClientSideApply` (default) or
> `ServerSideApply` typed apply strategies, it is perfectly normal if the `ClusterResourcePlacementDiffReported`
> status condition is absent in the CRP status.

## Common scenarios

`ClusterResourcePlacementDiffReported` status condition will be set to `False` if KubeFleet cannot complete
the configuration difference checking process for one or more of the selected resources.

Depending on your CRP configuration, KubeFleet might use one of the three approaches for configuration
difference checking:

* If the resource cannot be found on a member cluster, KubeFleet will simply report a full object
difference.
* If you ask KubeFleet to perform partial comparisons, i.e., the `comparisonOption` field in the
CRP apply strategy (`.spec.strategy.applyStrategy.comparisonOption` field) is set to `partialComparison`,
KubeFleet will perform a dry-run apply op (server-side apply with conflict overriding enabled) and
compare the returned apply result against the current state of the resource on the member cluster
side for configuration differences.
* If you ask KubeFleet to perform full comparisons, i.e., the `comparisonOption` field in the
CRP apply strategy (`.spec.strategy.applyStrategy.comparisonOption` field) is set to `fullComparison`,
KubeFleet will directly compare the given manifest (the resource created on the hub cluster side) against
the current state of the resource on the member cluster side for configuration differences.

Failures might arise if:

* The dry-run apply op does not complete successfully; or
* An unexpected error occurs during the comparison process, such as a JSON path parsing/evaluation error.
    * In this case, please consider [filing a bug to the KubeFleet team](https://github.com/kubefleet-dev/kubefleet/issues).

## Investigation steps

If you encounter such a failure, follow the steps below for investigation: 

* Identify the specific resources that have failed in the diff reporting process first. In the CRP status,
find out the individual member clusters that have diff reporting failures: inspect the
`.status.placementStatuses` field of the CRP object; each entry corresponds to a member cluster, and 
for each entry, check if it has a status condition, `ClusterResourcePlacementDiffReported`, in
the `.status.placementStatuses[*].conditions` field, which has been set to `False`. Write down the name
of the member cluster.

* For each cluster name that has been written down, list all the work objects that have been created
for the cluster in correspondence with the CRP object:

    ```sh
    # Replace [YOUR-CLUSTER-NAME] and [YOUR-CRP-NAME] with values of your own.
    kubectl get work -n fleet-member-[YOUR-CLUSTER-NAME] -l kubernetes-fleet.io/parent-CRP=[YOUR-CRP-NAME]
    ```

* For each found work object, inspect its status. The `.status.manifestConditions` field features an array of which
each item explains about the processing result of a resource on the given member cluster. Find out all items with
a `DiffReported` condition in the `.status.manifestConditions[*].conditions` field that has been set to `False`.
The `.status.manifestConditions[*].identifier` field tells the GVK, namespace, and name of the failing resource.

* Read the `message` field of the `DiffReported` condition (`.status.manifestConditions[*].conditions[*].message`);
KubeFleet will include the details about the diff reporting failures in the field.

* If you are familiar with the cause of the error (for example, dry-run apply ops fails due to API server traffic control
measures), fixing the cause (tweaking traffic control limits) should resolve the failure. KubeFleet will periodically
retry diff reporting in face of failures. Otherwise, [file an issue to the KubeFleet team](https://github.com/kubefleet-dev/kubefleet/issues).
