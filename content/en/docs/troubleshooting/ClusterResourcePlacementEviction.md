# Placement Eviction & Placement Disruption Budget Troubleshooting Guide

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
`Scheduled` meaning the rollout of resources is not started yet. The user should check the status of the 
`ClusterResourceBinding` to verify.

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
resources have been propagated to the target cluster and then retry eviction.

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
  - lastTransitionTime: "2025-04-21T22:01:57Z"
    message: Eviction is valid
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionValid
    status: "True"
    type: Valid
  - lastTransitionTime: "2025-04-21T22:01:57Z"
    message: 'Eviction is blocked by specified ClusterResourcePlacementDisruptionBudget,
      availablePlacements: 2, totalPlacements: 2'
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionNotExecuted
    status: "False"
    type: Executed
```

In this cae the Eviction object reached a terminal state, its status has `Executed` condition set to `False`, because 
the `ClusterResourcePlacementDisruptionBudget` object is blocking the eviction.

Taking a look at the `ClusterResourcePlacementDisruptionBudget` object,

```
kubectl get crpdb pick-all-crp -o YAML
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacementDisruptionBudget
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"placement.kubernetes-fleet.io/v1beta1","kind":"ClusterResourcePlacementDisruptionBudget","metadata":{"annotations":{},"name":"pick-all-crp"},"spec":{"minAvailable":2}}
  creationTimestamp: "2025-04-21T21:55:44Z"
  generation: 1
  name: pick-all-crp
  resourceVersion: "2748"
  uid: efc73250-b6dd-4e2d-8387-e7d0e9b5328d
spec:
  minAvailable: 2
```

We can see that the `minAvailable` is set to `2`, which means that at least 2 placements should be available for the 
`ClusterResourcePlacement` object.

Taking a look at the clusters connected to the Fleet,

```
kubectl get cluster -A
NAME             JOINED   AGE   MEMBER-AGENT-LAST-SEEN   NODE-COUNT   AVAILABLE-CPU   AVAILABLE-MEMORY
kind-cluster-1   True     32m   43s                      2            20750m          15440136Ki
kind-cluster-2   True     32m   59s                      2            20750m          15440136Ki
```

We see that there are 2 clusters connected to the Fleet.

Let's take a look at the `ClusterResourceBinding` objects for the `ClusterResourcePlacement` object,

```
kubectl get rb -l kubernetes-fleet.io/parent-CRP=pick-all-crp
NAME                                   WORKSYNCHRONIZED   RESOURCESAPPLIED   AGE
pick-all-crp-kind-cluster-1-a8a9e870   True               True               23m
pick-all-crp-kind-cluster-2-5c5bf113   True               True               23m
```

We see that there are 2 Placements for the `ClusterResourcePlacement` object which are both protected by the
`ClusterResourcePlacementDisruptionBudget` object specified.

Here the user can either remove the `ClusterResourcePlacementDisruptionBudget` object or update the `minAvailable` to
`1` to allow `ClusterResourcePlacementEviction` object to execute successfully.
