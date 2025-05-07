---
title: ClusterResourcePlacementEviction TSG
description: Identify and fix KubeFleet issues associated with the ClusterResourcePlacementEviction API
weight: 8
---

This guide provides troubleshooting steps for issues related to placement eviction.

An eviction object when created is ideally only reconciled once and reaches a terminal state. List of terminal states 
for eviction are:
- Eviction is Invalid
- Eviction is Valid, Eviction failed to Execute
- Eviction is Valid, Eviction executed successfully

> **Note:** If an eviction object doesn't reach a terminal state i.e. neither valid condition nor executed condition is 
> set it is likely due to a failure in the reconciliation process where the controller is unable to reach the api server.

The first step in troubleshooting is to check the status of the eviction object to understand if the eviction reached
a terminal state or not.

## Invalid eviction

### Missing/Deleting CRP object

Example status with missing `CRP` object:
```
status:
  conditions:
  - lastTransitionTime: "2025-04-17T22:16:59Z"
    message: Failed to find ClusterResourcePlacement targeted by eviction
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionInvalid
    status: "False"
    type: Valid
```

Example status with deleting `CRP` object:
```
status:
  conditions:
  - lastTransitionTime: "2025-04-21T19:53:42Z"
    message: Found deleting ClusterResourcePlacement targeted by eviction
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionInvalid
    status: "False"
    type: Valid
```

In both cases the Eviction object reached a terminal state, its status has `Valid` condition set to `False`. 
The user should verify if the `ClusterResourcePlacement` object is missing or if it is being deleted and recreate the 
`ClusterResourcePlacement` object if needed and retry eviction.

### Missing CRB object

Example status with missing `CRB` object:
```
status:
  conditions:
  - lastTransitionTime: "2025-04-17T22:21:51Z"
    message: Failed to find scheduler decision for placement in cluster targeted by
      eviction
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionInvalid
    status: "False"
    type: Valid
```

> **Note:** The user can find the corresponding `ClusterResourceBinding` object by listing all `ClusterResourceBinding`
> objects for the `ClusterResourcePlacement` object
> ```
> kubectl get rb -l kubernetes-fleet.io/parent-CRP=<CRPName>
> ```
> The `ClusterResourceBinding` object name is formatted as `<CRPName>-<ClusterName>-randomsuffix`

In this case the Eviction object reached a terminal state, its status has `Valid` condition set to `False`, because the
`ClusterResourceBinding` object or Placement for target cluster is not found. The user should verify to see if the 
`ClusterResourcePlacement` object is propagating resources to the target cluster,

- If yes, the next step is to check if the `ClusterResourceBinding` object is present for the target cluster or why it 
was not created and try to create an eviction object once `ClusterResourceBinding` is created.
- If no, the cluster is not picked by the scheduler and hence no need to retry eviction.

### Multiple CRB is present

Example status with multiple `CRB` objects:
```
status:
  conditions:
  - lastTransitionTime: "2025-04-17T23:48:08Z"
    message: Found more than one scheduler decision for placement in cluster targeted
      by eviction
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionInvalid
    status: "False"
    type: Valid
```

In this case the Eviction object reached a terminal state, its status has `Valid` condition set to `False`, because
there is more than one `ClusterResourceBinding` object or Placement present for the `ClusterResourcePlacement` object 
targeting the member cluster. This is a rare scenario, it's an in-between state where bindings are being-recreated due 
to the member cluster being selected again, and it will normally resolve quickly.

### PickFixed CRP is targeted by CRP Eviction

Example status for `ClusterResourcePlacementEviction` object targeting a PickFixed `ClusterResourcePlacement` object:
```
status:
  conditions:
  - lastTransitionTime: "2025-04-21T23:19:06Z"
    message: Found ClusterResourcePlacement with PickFixed placement type targeted
      by eviction
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionInvalid
    status: "False"
    type: Valid
```

In this case the Eviction object reached a terminal state, its status has `Valid` condition set to `False`, because
the `ClusterResourcePlacement` object is of type `PickFixed`. Users cannot use `ClusterResourcePlacementEviction` 
objects to evict resources propagated by `ClusterResourcePlacement` objects of type `PickFixed`. The user can instead 
remove the member cluster name from the `clusterNames` field in the policy of the `ClusterResourcePlacement` object.

## Failed to execute eviction

### Eviction blocked because placement is missing

```
status:
  conditions:
  - lastTransitionTime: "2025-04-23T23:54:03Z"
    message: Eviction is valid
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionValid
    status: "True"
    type: Valid
  - lastTransitionTime: "2025-04-23T23:54:03Z"
    message: Eviction is blocked, placement has not propagated resources to target
      cluster yet
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionNotExecuted
    status: "False"
    type: Executed
```

In this case the Eviction object reached a terminal state, its status has `Executed` condition set to `False`, because
for the targeted `ClusterResourcePlacement` the corresponding `ClusterResourceBinding` object's spec is set to 
`Scheduled` meaning the rollout of resources is not started yet.

> **Note:** The user can find the corresponding `ClusterResourceBinding` object by listing all `ClusterResourceBinding`
> objects for the `ClusterResourcePlacement` object
> ```
> kubectl get rb -l kubernetes-fleet.io/parent-CRP=<CRPName>
> ```
> The `ClusterResourceBinding` object name is formatted as `<CRPName>-<ClusterName>-randomsuffix`.

```
spec:
  applyStrategy:
    type: ClientSideApply
  clusterDecision:
    clusterName: kind-cluster-3
    clusterScore:
      affinityScore: 0
      priorityScore: 0
    reason: 'Successfully scheduled resources for placement in "kind-cluster-3" (affinity
      score: 0, topology spread score: 0): picked by scheduling policy'
    selected: true
  resourceSnapshotName: ""
  schedulingPolicySnapshotName: test-crp-1
  state: Scheduled
  targetCluster: kind-cluster-3
```

Here the user can wait for the `ClusterResourceBinding` object to be updated to `Bound` state which means that
resources have been propagated to the target cluster and then retry eviction. In some cases this can take a while or not
happen at all, in that case the user should verify if rollout is stuck for `ClusterResourcePlacement` object.

### Eviction blocked by Invalid CRPDB

Example status for `ClusterResourcePlacementEviction` object with invalid `ClusterResourcePlacementDisruptionBudget`,
```
status:
  conditions:
  - lastTransitionTime: "2025-04-21T23:39:42Z"
    message: Eviction is valid
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionValid
    status: "True"
    type: Valid
  - lastTransitionTime: "2025-04-21T23:39:42Z"
    message: Eviction is blocked by misconfigured ClusterResourcePlacementDisruptionBudget,
      either MaxUnavailable is specified or MinAvailable is specified as a percentage
      for PickAll ClusterResourcePlacement
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionNotExecuted
    status: "False"
    type: Executed
```

In this cae the Eviction object reached a terminal state, its status has `Executed` condition set to `False`, because
the `ClusterResourcePlacementDisruptionBudget` object is invalid. For `ClusterResourcePlacement` objects of type 
`PickAll`, when specifying a `ClusterResourcePlacementDisruptionBudget` the `minAvailable` field should be set to an 
absolute number and not a percentage and the `maxUnavailable` field should not be set since the total number of 
placements is non-deterministic.

### Eviction blocked by specified CRPDB

Example status for `ClusterResourcePlacementEviction` object blocked by a `ClusterResourcePlacementDisruptionBudget` 
object,
```
status:
  conditions:
  - lastTransitionTime: "2025-04-24T18:54:30Z"
    message: Eviction is valid
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionValid
    status: "True"
    type: Valid
  - lastTransitionTime: "2025-04-24T18:54:30Z"
    message: 'Eviction is blocked by specified ClusterResourcePlacementDisruptionBudget,
      availablePlacements: 2, totalPlacements: 2'
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionNotExecuted
    status: "False"
    type: Executed
```

In this cae the Eviction object reached a terminal state, its status has `Executed` condition set to `False`, because 
the `ClusterResourcePlacementDisruptionBudget` object is blocking the eviction. The message from `Executed` condition
reads available placements is 2 and total placements is 2, which means that the `ClusterResourcePlacementDisruptionBudget`
is protecting all placements propagated by the `ClusterResourcePlacement` object.

Taking a look at the `ClusterResourcePlacementDisruptionBudget` object,

```
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacementDisruptionBudget
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"placement.kubernetes-fleet.io/v1beta1","kind":"ClusterResourcePlacementDisruptionBudget","metadata":{"annotations":{},"name":"pick-all-crp"},"spec":{"minAvailable":2}}
  creationTimestamp: "2025-04-24T18:47:22Z"
  generation: 1
  name: pick-all-crp
  resourceVersion: "1749"
  uid: 7d3a0ac5-0225-4fb6-b5e9-fc28d58cefdc
spec:
  minAvailable: 2
```

We can see that the `minAvailable` is set to `2`, which means that at least 2 placements should be available for the 
`ClusterResourcePlacement` object.

Let's take a look at the `ClusterResourcePlacement` object's status to verify the list of available placements,

```
status:
  conditions:
  - lastTransitionTime: "2025-04-24T18:46:38Z"
    message: found all cluster needed as specified by the scheduling policy, found
      2 cluster(s)
    observedGeneration: 1
    reason: SchedulingPolicyFulfilled
    status: "True"
    type: ClusterResourcePlacementScheduled
  - lastTransitionTime: "2025-04-24T18:50:19Z"
    message: All 2 cluster(s) start rolling out the latest resource
    observedGeneration: 1
    reason: RolloutStarted
    status: "True"
    type: ClusterResourcePlacementRolloutStarted
  - lastTransitionTime: "2025-04-24T18:50:19Z"
    message: No override rules are configured for the selected resources
    observedGeneration: 1
    reason: NoOverrideSpecified
    status: "True"
    type: ClusterResourcePlacementOverridden
  - lastTransitionTime: "2025-04-24T18:50:19Z"
    message: Works(s) are succcesfully created or updated in 2 target cluster(s)'
      namespaces
    observedGeneration: 1
    reason: WorkSynchronized
    status: "True"
    type: ClusterResourcePlacementWorkSynchronized
  - lastTransitionTime: "2025-04-24T18:50:19Z"
    message: The selected resources are successfully applied to 2 cluster(s)
    observedGeneration: 1
    reason: ApplySucceeded
    status: "True"
    type: ClusterResourcePlacementApplied
  - lastTransitionTime: "2025-04-24T18:50:19Z"
    message: The selected resources in 2 cluster(s) are available now
    observedGeneration: 1
    reason: ResourceAvailable
    status: "True"
    type: ClusterResourcePlacementAvailable
  observedResourceIndex: "0"
  placementStatuses:
  - clusterName: kind-cluster-1
    conditions:
    - lastTransitionTime: "2025-04-24T18:50:19Z"
      message: 'Successfully scheduled resources for placement in "kind-cluster-1"
        (affinity score: 0, topology spread score: 0): picked by scheduling policy'
      observedGeneration: 1
      reason: Scheduled
      status: "True"
      type: Scheduled
    - lastTransitionTime: "2025-04-24T18:50:19Z"
      message: Detected the new changes on the resources and started the rollout process
      observedGeneration: 1
      reason: RolloutStarted
      status: "True"
      type: RolloutStarted
    - lastTransitionTime: "2025-04-24T18:50:19Z"
      message: No override rules are configured for the selected resources
      observedGeneration: 1
      reason: NoOverrideSpecified
      status: "True"
      type: Overridden
    - lastTransitionTime: "2025-04-24T18:50:19Z"
      message: All of the works are synchronized to the latest
      observedGeneration: 1
      reason: AllWorkSynced
      status: "True"
      type: WorkSynchronized
    - lastTransitionTime: "2025-04-24T18:50:19Z"
      message: All corresponding work objects are applied
      observedGeneration: 1
      reason: AllWorkHaveBeenApplied
      status: "True"
      type: Applied
    - lastTransitionTime: "2025-04-24T18:50:19Z"
      message: All corresponding work objects are available
      observedGeneration: 1
      reason: AllWorkAreAvailable
      status: "True"
      type: Available
  - clusterName: kind-cluster-2
    conditions:
    - lastTransitionTime: "2025-04-24T18:46:38Z"
      message: 'Successfully scheduled resources for placement in "kind-cluster-2"
        (affinity score: 0, topology spread score: 0): picked by scheduling policy'
      observedGeneration: 1
      reason: Scheduled
      status: "True"
      type: Scheduled
    - lastTransitionTime: "2025-04-24T18:46:38Z"
      message: Detected the new changes on the resources and started the rollout process
      observedGeneration: 1
      reason: RolloutStarted
      status: "True"
      type: RolloutStarted
    - lastTransitionTime: "2025-04-24T18:46:38Z"
      message: No override rules are configured for the selected resources
      observedGeneration: 1
      reason: NoOverrideSpecified
      status: "True"
      type: Overridden
    - lastTransitionTime: "2025-04-24T18:46:38Z"
      message: All of the works are synchronized to the latest
      observedGeneration: 1
      reason: AllWorkSynced
      status: "True"
      type: WorkSynchronized
    - lastTransitionTime: "2025-04-24T18:46:38Z"
      message: All corresponding work objects are applied
      observedGeneration: 1
      reason: AllWorkHaveBeenApplied
      status: "True"
      type: Applied
    - lastTransitionTime: "2025-04-24T18:46:38Z"
      message: All corresponding work objects are available
      observedGeneration: 1
      reason: AllWorkAreAvailable
      status: "True"
      type: Available
  selectedResources:
  - kind: Namespace
    name: test-ns
    version: v1
```

from the status we can see that the `ClusterResourcePlacement` object has 2 placements available, where resources have 
been successfully applied and are available in kind-cluster-1 and kind-cluster-2. The users can check the individual
member clusters to verify the resources are available but the users are recommended to check the`ClusterResourcePlacement` 
object status to verify placement availability since the status is aggregated and updated by the controller.

Here the user can either remove the `ClusterResourcePlacementDisruptionBudget` object or update the `minAvailable` to
`1` to allow `ClusterResourcePlacementEviction` object to execute successfully. In general the user should carefully 
check the availability of placements and act accordingly when changing the `ClusterResourcePlacementDisruptionBudget`
object.
