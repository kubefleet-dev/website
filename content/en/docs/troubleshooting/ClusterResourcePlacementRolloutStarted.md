---
title: CRP Rollout Failure TSG
description: Troubleshooting guide for CRP status "ClusterResourcePlacementRolloutStarted" condition set to false
weight: 3
---

When using the `ClusterResourcePlacement` API object in Azure Kubernetes Fleet Manager to propagate resources, the selected resources aren't rolled out in all scheduled clusters and the `ClusterResourcePlacementRolloutStarted` condition status shows as `False`.

*This TSG only applies to the `RollingUpdate` rollout strategy, which is the default strategy if you don't specify in the `ClusterResourcePlacement`.*
*To troubleshoot the update run strategy as you specify `External` in the `ClusterResourcePlacement`, please refer to the [Staged Update Run Troubleshooting Guide](ClusterStagedUpdateRun).*

> Note: To get more information about why the rollout doesn't start, you can check the [rollout controller](https://github.com/kubefleet-dev/kubefleet/blob/main/pkg/controllers/rollout/controller.go) to get more information on why the rollout did not start.

## Common scenarios
Instances where this condition may arise:
- The Cluster Resource Placement rollout strategy is blocked because the `RollingUpdate` configuration is too strict.

## Troubleshooting Steps

1. In the `ClusterResourcePlacement` status section, check the `placementStatuses` to identify clusters with the `RolloutStarted` status set to `False`.
2. Locate the corresponding `ClusterResourceBinding` for the identified cluster. For more information, see [How can I find the latest ClusterResourceBinding resource?](README.md#how-can-i-find-the-latest-clusterresourcebinding-resource). 
This resource should indicate the status of the `Work` whether it was created or updated.
3. Verify the values of `maxUnavailable` and `maxSurge` to ensure they align with your expectations.

## Case Study

In the following example, the `ClusterResourcePlacement` is trying to propagate a namespace to three member clusters. 
However, during the initial creation of the `ClusterResourcePlacement`, the namespace didn't exist on the hub cluster, 
and the fleet currently comprises two member clusters named `kind-cluster-1` and `kind-cluster-2`.

### ClusterResourcePlacement spec
```
spec:
  policy:
    numberOfClusters: 3
    placementType: PickN
  resourceSelectors:
  - group: ""
    kind: Namespace
    name: test-ns
    version: v1
  revisionHistoryLimit: 10
  strategy:
    type: RollingUpdate
```

### ClusterResourcePlacement status
```
status:
  conditions:
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: could not find all the clusters needed as specified by the scheduling
      policy
    observedGeneration: 1
    reason: SchedulingPolicyUnfulfilled
    status: "False"
    type: ClusterResourcePlacementScheduled
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: All 2 cluster(s) start rolling out the latest resource
    observedGeneration: 1
    reason: RolloutStarted
    status: "True"
    type: ClusterResourcePlacementRolloutStarted
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: No override rules are configured for the selected resources
    observedGeneration: 1
    reason: NoOverrideSpecified
    status: "True"
    type: ClusterResourcePlacementOverridden
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: Works(s) are succcesfully created or updated in the 2 target clusters'
      namespaces
    observedGeneration: 1
    reason: WorkSynchronized
    status: "True"
    type: ClusterResourcePlacementWorkSynchronized
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: The selected resources are successfully applied to 2 clusters
    observedGeneration: 1
    reason: ApplySucceeded
    status: "True"
    type: ClusterResourcePlacementApplied
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: The selected resources in 2 cluster are available now
    observedGeneration: 1
    reason: ResourceAvailable
    status: "True"
    type: ClusterResourcePlacementAvailable
  observedResourceIndex: "0"
  placementStatuses:
  - clusterName: kind-cluster-2
    conditions:
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: 'Successfully scheduled resources for placement in kind-cluster-2 (affinity
        score: 0, topology spread score: 0): picked by scheduling policy'
      observedGeneration: 1
      reason: Scheduled
      status: "True"
      type: Scheduled
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: Detected the new changes on the resources and started the rollout process
      observedGeneration: 1
      reason: RolloutStarted
      status: "True"
      type: RolloutStarted
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: No override rules are configured for the selected resources
      observedGeneration: 1
      reason: NoOverrideSpecified
      status: "True"
      type: Overridden
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: All of the works are synchronized to the latest
      observedGeneration: 1
      reason: AllWorkSynced
      status: "True"
      type: WorkSynchronized
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: All corresponding work objects are applied
      observedGeneration: 1
      reason: AllWorkHaveBeenApplied
      status: "True"
      type: Applied
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: All corresponding work objects are available
      observedGeneration: 1
      reason: AllWorkAreAvailable
      status: "True"
      type: Available
  - clusterName: kind-cluster-1
    conditions:
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: 'Successfully scheduled resources for placement in kind-cluster-1 (affinity
        score: 0, topology spread score: 0): picked by scheduling policy'
      observedGeneration: 1
      reason: Scheduled
      status: "True"
      type: Scheduled
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: Detected the new changes on the resources and started the rollout process
      observedGeneration: 1
      reason: RolloutStarted
      status: "True"
      type: RolloutStarted
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: No override rules are configured for the selected resources
      observedGeneration: 1
      reason: NoOverrideSpecified
      status: "True"
      type: Overridden
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: All of the works are synchronized to the latest
      observedGeneration: 1
      reason: AllWorkSynced
      status: "True"
      type: WorkSynchronized
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: All corresponding work objects are applied
      observedGeneration: 1
      reason: AllWorkHaveBeenApplied
      status: "True"
      type: Applied
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: All corresponding work objects are available
      observedGeneration: 1
      reason: AllWorkAreAvailable
      status: "True"
      type: Available
```

The previous output indicates that the resource `test-ns` namespace never exists on the hub cluster and shows the following `ClusterResourcePlacement` condition statuses:
- `ClusterResourcePlacementScheduled` is set to `False`, as the specified policy aims to pick three clusters, but the scheduler can only accommodate placement in two currently available and joined clusters.
- `ClusterResourcePlacementRolloutStarted` is set to `True`, as the rollout process has commenced with 2 clusters being selected.
- `ClusterResourcePlacementOverridden` is set to `True`, as no override rules are configured for the selected resources.
- `ClusterResourcePlacementWorkSynchronized` is set to `True`.
- `ClusterResourcePlacementApplied` is set to `True`.
- `ClusterResourcePlacementAvailable` is set to `True`.


To ensure seamless propagation of the namespace across the relevant clusters, proceed to create the `test-ns` namespace on the hub cluster.

### ClusterResourcePlacement status after namespace test-ns is created on the hub cluster
```
status:
  conditions:
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: could not find all the clusters needed as specified by the scheduling
      policy
    observedGeneration: 1
    reason: SchedulingPolicyUnfulfilled
    status: "False"
    type: ClusterResourcePlacementScheduled
  - lastTransitionTime: "2024-05-07T23:13:51Z"
    message: The rollout is being blocked by the rollout strategy in 2 cluster(s)
    observedGeneration: 1
    reason: RolloutNotStartedYet
    status: "False"
    type: ClusterResourcePlacementRolloutStarted
  observedResourceIndex: "1"
  placementStatuses:
  - clusterName: kind-cluster-2
    conditions:
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: 'Successfully scheduled resources for placement in kind-cluster-2 (affinity
        score: 0, topology spread score: 0): picked by scheduling policy'
      observedGeneration: 1
      reason: Scheduled
      status: "True"
      type: Scheduled
    - lastTransitionTime: "2024-05-07T23:13:51Z"
      message: The rollout is being blocked by the rollout strategy
      observedGeneration: 1
      reason: RolloutNotStartedYet
      status: "False"
      type: RolloutStarted
  - clusterName: kind-cluster-1
    conditions:
    - lastTransitionTime: "2024-05-07T23:08:53Z"
      message: 'Successfully scheduled resources for placement in kind-cluster-1 (affinity
        score: 0, topology spread score: 0): picked by scheduling policy'
      observedGeneration: 1
      reason: Scheduled
      status: "True"
      type: Scheduled
    - lastTransitionTime: "2024-05-07T23:13:51Z"
      message: The rollout is being blocked by the rollout strategy
      observedGeneration: 1
      reason: RolloutNotStartedYet
      status: "False"
      type: RolloutStarted
  selectedResources:
  - kind: Namespace
    name: test-ns
    version: v1
```

Upon examination, the `ClusterResourcePlacementScheduled` condition status is shown as `False`. 
The `ClusterResourcePlacementRolloutStarted` status is also shown as `False` with the message `The rollout is being blocked by the rollout strategy in 2 cluster(s)`.

Let's check the latest `ClusterResourceSnapshot`.

Check the latest `ClusterResourceSnapshot` by running the command in [How can I find the latest ClusterResourceSnapshot resource?](README.md#how-can-I-find-the-latest-ClusterResourceSnapshot-resource).

### Latest ClusterResourceSnapshot
```
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourceSnapshot
metadata:
  annotations:
    kubernetes-fleet.io/number-of-enveloped-object: "0"
    kubernetes-fleet.io/number-of-resource-snapshots: "1"
    kubernetes-fleet.io/resource-hash: 72344be6e268bc7af29d75b7f0aad588d341c228801aab50d6f9f5fc33dd9c7c
  creationTimestamp: "2024-05-07T23:13:51Z"
  generation: 1
  labels:
    kubernetes-fleet.io/is-latest-snapshot: "true"
    kubernetes-fleet.io/parent-CRP: crp-3
    kubernetes-fleet.io/resource-index: "1"
  name: crp-3-1-snapshot
  ownerReferences:
  - apiVersion: placement.kubernetes-fleet.io/v1beta1
    blockOwnerDeletion: true
    controller: true
    kind: ClusterResourcePlacement
    name: crp-3
    uid: b4f31b9a-971a-480d-93ac-93f093ee661f
  resourceVersion: "14434"
  uid: 85ee0e81-92c9-4362-932b-b0bf57d78e3f
spec:
  selectedResources:
  - apiVersion: v1
    kind: Namespace
    metadata:
      labels:
        kubernetes.io/metadata.name: test-ns
      name: test-ns
    spec:
      finalizers:
      - kubernetes
```

Upon inspecting `ClusterResourceSnapshot` spec, the `selectedResources` section now shows the namespace `test-ns`.

Let's check the `ClusterResourceBinding` for `kind-cluster-1` to see if it was updated after the namespace `test-ns` was created.
Check the `ClusterResourceBinding` for `kind-cluster-1` by running the command in [How can I find the latest ClusterResourceBinding resource?](README.md#how-can-i-find-the-latest-clusterresourcebinding-resource).

### ClusterResourceBinding for kind-cluster-1
```
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourceBinding
metadata:
  creationTimestamp: "2024-05-07T23:08:53Z"
  finalizers:
  - kubernetes-fleet.io/work-cleanup
  generation: 2
  labels:
    kubernetes-fleet.io/parent-CRP: crp-3
  name: crp-3-kind-cluster-1-7114c253
  resourceVersion: "14438"
  uid: 0db4e480-8599-4b40-a1cc-f33bcb24b1a7
spec:
  applyStrategy:
    type: ClientSideApply
  clusterDecision:
    clusterName: kind-cluster-1
    clusterScore:
      affinityScore: 0
      priorityScore: 0
    reason: picked by scheduling policy
    selected: true
  resourceSnapshotName: crp-3-0-snapshot
  schedulingPolicySnapshotName: crp-3-0
  state: Bound
  targetCluster: kind-cluster-1
status:
  conditions:
  - lastTransitionTime: "2024-05-07T23:13:51Z"
    message: The resources cannot be updated to the latest because of the rollout
      strategy
    observedGeneration: 2
    reason: RolloutNotStartedYet
    status: "False"
    type: RolloutStarted
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: No override rules are configured for the selected resources
    observedGeneration: 2
    reason: NoOverrideSpecified
    status: "True"
    type: Overridden
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: All of the works are synchronized to the latest
    observedGeneration: 2
    reason: AllWorkSynced
    status: "True"
    type: WorkSynchronized
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: All corresponding work objects are applied
    observedGeneration: 2
    reason: AllWorkHaveBeenApplied
    status: "True"
    type: Applied
  - lastTransitionTime: "2024-05-07T23:08:53Z"
    message: All corresponding work objects are available
    observedGeneration: 2
    reason: AllWorkAreAvailable
    status: "True"
    type: Available
```

Upon inspection, it is observed that the `ClusterResourceBinding` remains unchanged. Notably, in the spec, the `resourceSnapshotName` still references the old `ClusterResourceSnapshot` name.

This issue arises due to the absence of explicit `rollingUpdate` input from the user. Consequently, the default values are applied:

- The `maxUnavailable` value is configured to 25% x 3 (desired number), rounded to `1`
- The `maxSurge` value is configured to 25% x 3 (desired number), rounded to `1`

### Why ClusterResourceBinding isn't updated?
Initially, when the `ClusterResourcePlacement` was created, two `ClusterResourceBindings` were generated. 
However, since the rollout didn't apply to the initial phase, the `ClusterResourcePlacementRolloutStarted` condition was set to `True`.

Upon creating the `test-ns` namespace on the hub cluster, the rollout controller attempted to update the two existing `ClusterResourceBindings`. 
However, `maxUnavailable` was set to `1` due to the lack of member clusters, which caused the `RollingUpdate` configuration to be too strict.
> NOTE: During the update, if one of the bindings fails to apply, it will also violate the `RollingUpdate` configuration, which causes `maxUnavailable` to be set to `1`.

### Resolution
In this situation, to address this issue, consider manually setting `maxUnavailable` to a value greater than `1` to relax the `RollingUpdate` configuration. 
Alternatively, you can join a third member cluster.
