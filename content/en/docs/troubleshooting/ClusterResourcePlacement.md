---
title: ClusterResourcePlacement TSG
description: Identify and fix KubeFleet issues associated with the ClusterResourcePlacement API
weight: 1
---

This TSG is meant to help you troubleshoot issues with the ClusterResourcePlacement API in Fleet.

## Cluster Resource Placement

Internal Objects to keep in mind when troubleshooting CRP related errors on the hub cluster:
 - `ClusterResourceSnapshot`
 - `ClusterSchedulingPolicySnapshot`
 - `ClusterResourceBinding`
 - `Work`

Please read the [Fleet API reference](docs/api-reference) for more details about each object.

## Complete Progress of the ClusterResourcePlacement
Understanding the progression and the status of the `ClusterResourcePlacement` custom resource is crucial for diagnosing and identifying failures. 
You can view the status of the `ClusterResourcePlacement` custom resource by using the following command:
```bash
kubectl describe clusterresourceplacement <name>
```

The complete progression of `ClusterResourcePlacement` is as follows:
1. `ClusterResourcePlacementScheduled`: Indicates a resource has been scheduled for placement.. 
    - If this condition is false, refer to [CRP Schedule Failure TSG](ClusterResourcePlacementScheduled). 
2. `ClusterResourcePlacementRolloutStarted`: Indicates the rollout process has begun.
   - If this condition is false refer to [CRP Rollout Failure TSG](ClusterResourcePlacementRolloutStarted)
   - If you are triggering a rollout with a staged update run, refer to [ClusterStagedUpdateRun TSG](ClusterStagedUpdateRun).
3. `ClusterResourcePlacementOverridden`: Indicates the resource has been overridden.
   - If this condition is false, refer to [CRP Override Failure TSG](ClusterResourcePlacementOverridden)
4. `ClusterResourcePlacementWorkSynchronized`: Indicates the work objects have been synchronized.
   - If this condition is false, refer to [CRP Work-Synchronization Failure TSG](ClusterResourcePlacementWorkSynchronized)
5. `ClusterResourcePlacementApplied`: Indicates the resource has been applied. This condition will only be populated if the
apply strategy in use is of the type `ClientSideApply` (default) or `ServerSideApply`.
   - If this condition is false, refer to [CRP Work-Application Failure TSG](ClusterResourcePlacementApplied)
6. `ClusterResourcePlacementAvailable`: Indicates the resource is available. This condition will only be populated if the
apply strategy in use is of the type `ClientSideApply` (default) or `ServerSideApply`.
   - If this condition is false, refer to [CRP Availability Failure TSG](ClusterResourcePlacementAvailable)
7. `ClusterResourcePlacementDiffreported`: Indicates whether diff reporting has completed on all resources. This condition
will only be populated if the apply strategy in use is of the type `ReportDiff`.
   - If this condition is false, refer to the [CRP Diff Reporting Failure TSG](ClusterResourcePlacementDiffReported) for more information.

## How can I debug if some clusters are not selected as expected?

Check the status of the `ClusterSchedulingPolicySnapshot` to determine which clusters were selected along with the reason.

## How can I debug if a selected cluster does not have the expected resources on it or if CRP doesn't pick up the latest changes?

Please check the following cases,
- Check whether the `ClusterResourcePlacementRolloutStarted` condition in `ClusterResourcePlacement` status is set to **true** or **false**.
- If `false`, see [CRP Schedule Failure TSG](ClusterResourcePlacementScheduled).
- If `true`,
  - Check to see if `ClusterResourcePlacementApplied` condition is set to **unknown**, **false** or **true**.
  - If `unknown`, wait for the process to finish, as the resources are still being applied to the member cluster. If the state remains unknown for a while, create a [issue](https://github.com/kubefleet-dev/kubefleet/issues), as this is an unusual behavior.
  - If `false`, refer to [CRP Work-Application Failure TSG](ClusterResourcePlacementApplied).
  - If `true`, verify that the resource exists on the hub cluster.

We can also take a look at the `placementStatuses` section in `ClusterResourcePlacement` status for that particular cluster. In `placementStatuses` we would find `failedPlacements` section which should have the reasons as to why resources failed to apply.

## How can I debug if the drift detection result or the configuration difference check result are different from my expectations?

See the [Drift Detection and Configuration Difference Check Unexpected Result TSG](DriftAndDiffDetection) for more information.

## How can I find and verify the latest ClusterSchedulingPolicySnapshot for a ClusterResourcePlacement?

To find the latest `ClusterSchedulingPolicySnapshot` for a `ClusterResourcePlacement` resource, run the following command:

```
kubectl get clusterschedulingpolicysnapshot -l kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP={CRPName}
```
> NOTE: In this command, replace `{CRPName}` with your `ClusterResourcePlacement` name.

Then, compare the `ClusterSchedulingPolicySnapshot` with the `ClusterResourcePlacement` policy to make sure that they match, excluding the `numberOfClusters` field from the `ClusterResourcePlacement` spec.

If the placement type is `PickN`, check whether the number of clusters that's requested in the `ClusterResourcePlacement` policy matches the value of the number-of-clusters label.

## How can I find the latest ClusterResourceBinding resource?

The following command lists all `ClusterResourceBindings` instances that are associated with `ClusterResourcePlacement`:
```
kubectl get clusterresourcebinding -l kubernetes-fleet.io/parent-CRP={CRPName}
```
> NOTE: In this command, replace `{CRPName}` with your `ClusterResourcePlacement` name.

### Example

In this case we have `ClusterResourcePlacement` called test-crp.

1. List the `ClusterResourcePlacement` to get the name of the CRP,
```
kubectl get crp test-crp
NAME       GEN   SCHEDULED   SCHEDULEDGEN   APPLIED   APPLIEDGEN   AGE
test-crp   1     True        1              True      1            15s
```

2. The following command is run to view the status of the `ClusterResourcePlacement` deployment.
```bash
kubectl describe clusterresourceplacement test-crp
```

3. Here's an example output. From the `placementStatuses` section of the `test-crp` status, notice that it has distributed 
resources to two member clusters and, therefore, has two `ClusterResourceBindings` instances:
```
status:
  conditions:
  - lastTransitionTime: "2023-11-23T00:49:29Z"
    ...
  placementStatuses:
  - clusterName: kind-cluster-1
    conditions:
      ...
      type: ResourceApplied
  - clusterName: kind-cluster-2
    conditions:
      ...
      reason: ApplySucceeded
      status: "True"
      type: ResourceApplied
```

3. To get the `ClusterResourceBindings` value, run the following command:
```bash
    kubectl get clusterresourcebinding -l kubernetes-fleet.io/parent-CRP=test-crp 
```
4. The output lists all `ClusterResourceBindings` instances that are associated with `test-crp`. 
```
kubectl get clusterresourcebinding -l kubernetes-fleet.io/parent-CRP=test-crp 
NAME                               WORKCREATED   RESOURCESAPPLIED   AGE
test-crp-kind-cluster-1-be990c3e   True          True               33s
test-crp-kind-cluster-2-ec4d953c   True          True               33s
```
The `ClusterResourceBinding` resource name uses the following format: `{CRPName}-{clusterName}-{suffix}`. 
Find the `ClusterResourceBinding` for the target cluster you are looking for based on the `clusterName`.


## How can I find the latest ClusterResourceSnapshot resource?

To find the latest ClusterResourceSnapshot resource, run the following command:

```
kubectl get clusterresourcesnapshot -l kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP={CRPName}
```
> NOTE: In this command, replace `{CRPName}` with your `ClusterResourcePlacement` name.

## How can I find the correct work resource that's associated with ClusterResourcePlacement?

To find the correct work resource, follow these steps:

1. Identify the member cluster namespace and the `ClusterResourcePlacement` name. The format for the namespace is `fleet-member-{clusterName}`.
2. To get the work resource, run the following command:

```
kubectl get work -n fleet-member-{clusterName} -l kubernetes-fleet.io/parent-CRP={CRPName}
```
> NOTE: In this command, replace `{clusterName}` and `{CRPName}` with the names that you identified in the first step.
