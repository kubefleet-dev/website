---
title: ResourcePlacement TSG
description: Identify and fix KubeFleet issues associated with the ResourcePlacement API
weight: 2
---

This TSG is meant to help you troubleshoot issues with the ResourcePlacement API in Fleet.

## Resource Placement

Internal Objects to keep in mind when troubleshooting RP related errors on the hub cluster:

- `ResourceSnapshot`
- `SchedulingPolicySnapshot`
- `ResourceBinding`
- `Work`

Please read the [Fleet API reference](docs/api-reference) for more details about each object.

## Complete Progress of the ResourcePlacement

Understanding the progression and the status of the `ResourcePlacement` custom resource is crucial for diagnosing and identifying failures.
You can view the status of the `ResourcePlacement` custom resource by using the following command:

```bash
kubectl describe resourceplacement <name> -n <namespace>
```

The complete progression of `ResourcePlacement` is as follows:

1. `ResourcePlacementScheduled`: Indicates a resource has been scheduled for placement.
   - If this condition is false, refer to [CRP Schedule Failure TSG](ClusterResourcePlacementScheduled).
2. `ResourcePlacementRolloutStarted`: Indicates the rollout process has begun.
   - If this condition is false, refer to [CRP Rollout Failure TSG](ClusterResourcePlacementRolloutStarted).
   - If you are triggering a rollout with a staged update run, refer to [ClusterStagedUpdateRun TSG](ClusterStagedUpdateRun).
3. `ResourcePlacementOverridden`: Indicates the resource has been overridden.
   - If this condition is false, refer to [CRP Override Failure TSG](ClusterResourcePlacementOverridden).
4. `ResourcePlacementWorkSynchronized`: Indicates the work objects have been synchronized.
   - If this condition is false, refer to [CRP Work-Synchronization Failure TSG](ClusterResourcePlacementWorkSynchronized).
5. `ResourcePlacementApplied`: Indicates the resource has been applied. This condition will only be populated if the
apply strategy in use is of the type `ClientSideApply` (default) or `ServerSideApply`.
   - If this condition is false, refer to [CRP Work-Application Failure TSG](ClusterResourcePlacementApplied).
6. `ResourcePlacementAvailable`: Indicates the resource is available. This condition will only be populated if the
apply strategy in use is of the type `ClientSideApply` (default) or `ServerSideApply`.
   - If this condition is false, refer to [CRP Availability Failure TSG](ClusterResourcePlacementAvailable).
7. `ResourcePlacementDiffreported`: Indicates whether diff reporting has completed on all resources. This condition
will only be populated if the apply strategy in use is of the type `ReportDiff`.
   - If this condition is false, refer to the [CRP Diff Reporting Failure TSG](ClusterResourcePlacementDiffReported) for more information.

> **Note**: ResourcePlacement and ClusterResourcePlacement share the same underlying architecture and condition types.
> The troubleshooting approaches documented in the CRP TSG files are applicable to ResourcePlacement as well. The main
> difference is that ResourcePlacement is namespace-scoped and works with namespace-scoped resources, while
> ClusterResourcePlacement is cluster-scoped. When following CRP TSG guidance, substitute the appropriate RP commands
> (e.g., use `kubectl get resourceplacement -n <namespace>` instead of `kubectl get clusterresourceplacement`).

## How can I debug if some clusters are not selected as expected?

Check the status of the `SchedulingPolicySnapshot` to determine which clusters were selected along with the reason.

To find the latest `SchedulingPolicySnapshot` for a `ResourcePlacement` resource, run the following command:

```bash
kubectl get schedulingpolicysnapshot -n <namespace> -l kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP={RPName}
```

> NOTE: In this command, replace `{RPName}` with your `ResourcePlacement` name and `<namespace>` with the namespace where the ResourcePlacement exists.

Then, compare the `SchedulingPolicySnapshot` with the `ResourcePlacement` policy to make sure that they match.

## How can I debug if a selected cluster does not have the expected resources on it or if RP doesn't pick up the latest changes?

Please check the following cases,

- Check whether the `ResourcePlacementRolloutStarted` condition in `ResourcePlacement` status is set to **true** or **false**.
- If `false`, the resource placement has not started rolling out yet.
- If `true`,
  - Check to see if `ResourcePlacementApplied` condition is set to **unknown**, **false** or **true**.
  - If `unknown`, wait for the process to finish, as the resources are still being applied to the member cluster. If the state remains unknown for a while, create a [issue](https://github.com/kubefleet-dev/kubefleet/issues), as this is an unusual behavior.
  - If `false`, the resources failed to apply. Check the `Failed Placements` section in the status for more details.
  - If `true`, verify that the resource exists on the hub cluster in the same namespace as the ResourcePlacement.

We can also take a look at the `Placement Statuses` section in `ResourcePlacement` status for that particular cluster. In `Placement Statuses` we would find `Failed Placements` section which should have the reasons as to why resources failed to apply.

## How can I debug if the drift detection result or the configuration difference check result are different from my expectations?

See the [Drift Detection and Configuration Difference Check Unexpected Result TSG](DriftAndDiffDetection) for more information.

## How can I find the latest ResourceBinding resource?

The following command lists all `ResourceBindings` instances that are associated with `ResourcePlacement`:

```bash
kubectl get resourcebinding -n <namespace> -l kubernetes-fleet.io/parent-CRP={RPName}
```

> NOTE: In this command, replace `{RPName}` with your `ResourcePlacement` name and `<namespace>` with the namespace where the ResourcePlacement exists.

### Example

In this case we have `ResourcePlacement` called test-rp in namespace `test-ns`.

1. List the `ResourcePlacement` to get the name of the RP,

```bash
kubectl get rp test-rp -n test-ns
NAME       GEN   SCHEDULED   SCHEDULEDGEN   AVAILABLE   AVAILABLE-GEN   AGE
test-rp    1     True        1              True        1               15s
```

2. The following command is run to view the status of the `ResourcePlacement` deployment.

```bash
kubectl describe resourceplacement test-rp -n test-ns
```

3. Here's an example output. From the `Placement Statuses` section of the `test-rp` status, notice that it has distributed
resources to two member clusters and, therefore, has two `ResourceBindings` instances:

```bash
Status:
  Conditions:
  - Last Transition Time: "2023-11-23T00:49:29Z"
    ...
  Placement Statuses:
  - Cluster Name: kind-cluster-1
    conditions:
      ...
      Reason: AllWorkHaveBeenApplied
      Status: True
      Type: Applied
  - clusterName: kind-cluster-2
    conditions:
      ...
      Reason: AllWorkHaveBeenApplied
      Status: True
      Type: Applied
```

3. To get the `ResourceBindings` value, run the following command:

```bash
    kubectl get resourcebinding -n test-ns -l kubernetes-fleet.io/parent-CRP=test-rp 
```

4. The output lists all `ResourceBindings` instances that are associated with `test-rp`.

```bash
kubectl get resourcebinding -n test-ns -l kubernetes-fleet.io/parent-CRP=test-rp 
NAME                              WORKSYNCHRONIZED   RESOURCESAPPLIED   AGE
test-rp-kind-cluster-1-be990c3e   True               True               33s
test-rp-kind-cluster-2-ec4d953c   True               True               33s
```

The `ResourceBinding` resource name uses the following format: `{RPName}-{clusterName}-{suffix}`.
Find the `ResourceBinding` for the target cluster you are looking for based on the `clusterName`.

## How can I find the latest ResourceSnapshot resource?

To find the latest ResourceSnapshot resource, run the following command:

```bash
kubectl get resourcesnapshot -n <namespace> -l kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP={RPName}
```

> NOTE: In this command, replace `{RPName}` with your `ResourcePlacement` name and `<namespace>` with the namespace where the ResourcePlacement exists.

## How can I find the correct work resource that's associated with ResourcePlacement?

To find the correct work resource, follow these steps:

1. Identify the member cluster namespace and the `ResourcePlacement` name. The format for the namespace is `fleet-member-{clusterName}`.
2. To get the work resource, run the following command:

```bash
kubectl get work -n fleet-member-{clusterName} -l kubernetes-fleet.io/parent-CRP={RPName}
```

> NOTE: In this command, replace `{clusterName}` and `{RPName}` with the names that you identified in the first step.

## Important Considerations for ResourcePlacement

### Namespace Prerequisites

**Important**: ResourcePlacement can only place namespace-scoped resources to clusters that already have the target namespace. Before creating a ResourcePlacement:

1. Ensure the target namespace exists on the member clusters, either:
   - Created by a `ClusterResourcePlacement` (CRP) using namespace-only mode
   - Pre-existing on the member clusters

2. If the namespace doesn't exist on a member cluster, the ResourcePlacement will fail to apply resources to that cluster.

### Coordination with ClusterResourcePlacement

When using both ResourcePlacement (RP) and ClusterResourcePlacement (CRP) together:

- **CRP in namespace-only mode**: Use CRP to create and manage the namespace itself across clusters
- **RP for resources**: Use RP to manage specific resources within that namespace
- **Avoid conflicts**: Ensure that CRP and RP don't select the same resources to prevent conflicts

### Resource Scope Limitations

ResourcePlacement can only select and manage namespace-scoped resources within the same namespace where the RP object resides:

- ✅ **Supported**: ConfigMaps, Secrets, Services, Deployments, StatefulSets, Jobs, etc. within the RP's namespace
- ❌ **Not Supported**: Cluster-scoped resources (use ClusterResourcePlacement instead)
- ❌ **Not Supported**: Resources in other namespaces
