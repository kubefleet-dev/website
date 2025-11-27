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

## Important Considerations for ResourcePlacement

### Namespace Prerequisites

**Important**: ResourcePlacement can only place namespace-scoped resources to clusters that already have the target namespace. 
Before creating a ResourcePlacement:
- Ensure the target namespace exists on the member clusters, either:
   - Created by a `ClusterResourcePlacement` (CRP) using namespace-only mode
   - Pre-existing on the member clusters

- If the namespace doesn't exist on a member cluster, the `ResourcePlacement` will fail to apply resources to that cluster.

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

## Complete Progress of the ResourcePlacement

Understanding the progression and the status of the `ResourcePlacement` custom resource is crucial for diagnosing and identifying failures.
You can view the status of the `ResourcePlacement` custom resource by using the following command:

```bash
kubectl describe resourceplacement <name> -n <namespace>
```

The complete progression of `ResourcePlacement` is as follows:

1. `ResourcePlacementScheduled`: Indicates a resource has been scheduled for placement.
   - If this condition is false, refer to [Scheduling Failure TSG](PlacementScheduled.md).
2. `ResourcePlacementRolloutStarted`: Indicates the rollout process has begun.
   - If this condition is false, refer to [Rollout Failure TSG](PlacementRolloutStarted.md).
   - If you are triggering a rollout with a staged update run, refer to [ClusterStagedUpdateRun TSG](ClusterStagedUpdateRun.md).
3. `ResourcePlacementOverridden`: Indicates the resource has been overridden.
   - If this condition is false, refer to [Override Failure TSG](PlacementOverridden.md).
4. `ResourcePlacementWorkSynchronized`: Indicates the work objects have been synchronized.
   - If this condition is false, refer to [Work Synchronization Failure TSG](PlacementWorkSynchronized.md).
5. `ResourcePlacementApplied`: Indicates the resource has been applied. This condition will only be populated if the
apply strategy in use is of the type `ClientSideApply` (default) or `ServerSideApply`.
   - If this condition is false, refer to [Work-Application Failure TSG](PlacementApplied.md).
6. `ResourcePlacementAvailable`: Indicates the resource is available. This condition will only be populated if the
apply strategy in use is of the type `ClientSideApply` (default) or `ServerSideApply`.
   - If this condition is false, refer to [Availability Failure TSG](PlacementAvailable.md).
7. `ResourcePlacementDiffreported`: Indicates whether diff reporting has completed on all resources. This condition
will only be populated if the apply strategy in use is of the type `ReportDiff`.
   - If this condition is false, refer to the [Diff Reporting Failure TSG](PlacementDiffReported.md) for more information.

> **Note**: ResourcePlacement and ClusterResourcePlacement share the same underlying architecture with a 1-to-1 mapping of condition types. 
> The condition types follow a naming convention where RP conditions use the `ResourcePlacement` prefix while CRP conditions use the 
> `ClusterResourcePlacement` prefix. For example:
> - `ResourcePlacementScheduled` ↔ `ClusterResourcePlacementScheduled`
> - `ResourcePlacementApplied` ↔ `ClusterResourcePlacementApplied`
> - `ResourcePlacementAvailable` ↔ `ClusterResourcePlacementAvailable`
>
> The troubleshooting approaches documented in the CRP TSG files are applicable to ResourcePlacement as well. The main difference is that 
> ResourcePlacement is namespace-scoped and works with namespace-scoped resources, while ClusterResourcePlacement is cluster-scoped. 
> When following CRP TSG guidance, substitute the appropriate RP condition names and commands (e.g., use 
> `kubectl get resourceplacement -n <namespace>` instead of `kubectl get clusterresourceplacement`).

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
  - Check to see if the overall `ResourcePlacementApplied` condition is set to **unknown**, **false** or **true**.
  - If `unknown`, wait for the process to finish, as the resources are still being applied to the member clusters. If the state remains unknown for a while, create an [issue](https://github.com/kubefleet-dev/kubefleet/issues), as this is an unusual behavior.
  - If `false`, the resources failed to apply on one or more clusters. Check the `Placement Statuses` section in the status for cluster-specific details.
  - If `true`, verify that the resource exists on the hub cluster in the same namespace as the ResourcePlacement.

To pinpoint issues on specific clusters, examine the `Placement Statuses` section in `ResourcePlacement` status. For each cluster, you can find:
- The cluster name
- Conditions specific to that cluster (e.g., `Applied`, `Available`)
- `Failed Placements` section which lists the resources that failed to apply along with the reasons

## How can I debug if the drift detection result or the configuration difference check result are different from my expectations?

See the [Drift Detection and Configuration Difference Check Unexpected Result TSG](DriftAndDiffDetection.md) for more information.

## How can I find the latest ResourceBinding resource?

The following command lists all `ResourceBindings` instances that are associated with `ResourcePlacement`:

```bash
kubectl get resourcebinding -n <namespace> -l kubernetes-fleet.io/parent-CRP={RPName}
```

> NOTE: In this command, replace `{RPName}` with your `ResourcePlacement` name and `<namespace>` with the namespace where the ResourcePlacement exists.

### Example

In this case we have `ResourcePlacement` called test-rp in namespace `test-ns`.

1. Get the `ResourcePlacement` to get a basic overview of the RP,

```bash
kubectl get rp test-rp -n test-ns
NAME       GEN   SCHEDULED   SCHEDULEDGEN   AVAILABLE   AVAILABLE-GEN   AGE
test-rp    1     True        1              True        1               15s
```

2. The following command is run to view the status of the `ResourcePlacement`.

```bash
kubectl describe resourceplacement test-rp -n test-ns
```

**Here's an example output:**

```yaml
Status:
  Conditions:
    Last Transition Time:   2025-11-13T22:25:45Z
    Message:                found all cluster needed as specified by the scheduling policy, found 2 cluster(s)
    Observed Generation:    2
    Reason:                 SchedulingPolicyFulfilled
    Status:                 True
    Type:                   ResourcePlacementScheduled
    Last Transition Time:   2025-11-13T22:25:45Z
    Message:                All 2 cluster(s) start rolling out the latest resource
    Observed Generation:    2
    Reason:                 RolloutStarted
    Status:                 True
    Type:                   ResourcePlacementRolloutStarted
    Last Transition Time:   2025-11-13T22:25:45Z
    Message:                No override rules are configured for the selected resources
    Observed Generation:    2
    Reason:                 NoOverrideSpecified
    Status:                 True
    Type:                   ResourcePlacementOverridden
    Last Transition Time:   2025-11-13T22:25:45Z
    Message:                Works(s) are succcesfully created or updated in 2 target cluster(s)' namespaces
    Observed Generation:    2
    Reason:                 WorkSynchronized
    Status:                 True
    Type:                   ResourcePlacementWorkSynchronized
    Last Transition Time:   2025-11-13T22:25:45Z
    Message:                The selected resources are successfully applied to 2 cluster(s)
    Observed Generation:    2
    Reason:                 ApplySucceeded
    Status:                 True
    Type:                   ResourcePlacementApplied
    Last Transition Time:   2025-11-13T22:25:45Z
    Message:                The selected resources in 2 cluster(s) are available now
    Observed Generation:    2
    Reason:                 ResourceAvailable
    Status:                 True
    Type:                   ResourcePlacementAvailable
  Observed Resource Index:  0
  Placement Statuses:
    Cluster Name:  kind-cluster-1
    Conditions:
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                Successfully scheduled resources for placement in "kind-cluster-1": picked by scheduling policy
      Observed Generation:    2
      Reason:                 Scheduled
      Status:                 True
      Type:                   Scheduled
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                Detected the new changes on the resources and started the rollout process
      Observed Generation:    2
      Reason:                 RolloutStarted
      Status:                 True
      Type:                   RolloutStarted
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                No override rules are configured for the selected resources
      Observed Generation:    2
      Reason:                 NoOverrideSpecified
      Status:                 True
      Type:                   Overridden
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                All of the works are synchronized to the latest
      Observed Generation:    2
      Reason:                 AllWorkSynced
      Status:                 True
      Type:                   WorkSynchronized
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                All corresponding work objects are applied
      Observed Generation:    2
      Reason:                 AllWorkHaveBeenApplied
      Status:                 True
      Type:                   Applied
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                All corresponding work objects are available
      Observed Generation:    2
      Reason:                 AllWorkAreAvailable
      Status:                 True
      Type:                   Available
    Observed Resource Index:  0
    Cluster Name:             kind-cluster-2
    Conditions:
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                Successfully scheduled resources for placement in "kind-cluster-2": picked by scheduling policy
      Observed Generation:    2
      Reason:                 Scheduled
      Status:                 True
      Type:                   Scheduled
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                Detected the new changes on the resources and started the rollout process
      Observed Generation:    2
      Reason:                 RolloutStarted
      Status:                 True
      Type:                   RolloutStarted
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                No override rules are configured for the selected resources
      Observed Generation:    2
      Reason:                 NoOverrideSpecified
      Status:                 True
      Type:                   Overridden
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                All of the works are synchronized to the latest
      Observed Generation:    2
      Reason:                 AllWorkSynced
      Status:                 True
      Type:                   WorkSynchronized
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                All corresponding work objects are applied
      Observed Generation:    2
      Reason:                 AllWorkHaveBeenApplied
      Status:                 True
      Type:                   Applied
      Last Transition Time:   2025-11-13T22:25:45Z
      Message:                All corresponding work objects are available
      Observed Generation:    2
      Reason:                 AllWorkAreAvailable
      Status:                 True
      Type:                   Available
    Observed Resource Index:  0
  Selected Resources:
    Kind:       ConfigMap
    Name:       app-config
    Namespace:  my-app
    Version:    v1
    Kind:       ConfigMap
    Name:       feature-flags
    Namespace:  my-app
    Version:    v1
```

From the status output, you can see:
- **Overall Conditions**: Show the aggregated state across all clusters (e.g., `ResourcePlacementApplied`, `ResourcePlacementAvailable`)
- **Placement Statuses**: Contains per-cluster details for `kind-cluster-1` and `kind-cluster-2`, each with their own conditions (`Scheduled`, `Applied`, `Available`, etc.)
- **Selected Resources**: Lists the ConfigMaps (`app-config` and `feature-flags`) that were selected for placement

2. To get the `ResourceBindings`, run the following command:

```bash
    kubectl get resourcebinding -n test-ns -l kubernetes-fleet.io/parent-CRP=test-rp 
```

This lists all `ResourceBindings` instances that are associated with `test-rp`.

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
