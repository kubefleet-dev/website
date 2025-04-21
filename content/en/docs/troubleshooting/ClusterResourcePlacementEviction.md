# Placement Eviction & Placement Disruption Budget Troubleshooting Guide

This guide provides troubleshooting steps for issues related to placement eviction in the system.

An eviction object when created is only reconciled once and reaches a terminal state. List of terminal states for 
eviction are:
- Eviction is invalid - terminal state
- Eviction is valid, Eviction failed to execute
- Eviction is valid, Eviction executed 

> **Note:** If an eviction object doesn't reach a terminal state, it is likely due to a failure in the reconciliation
> process where the controller is unable to reach the api server.

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

In this case the Eviction object reached a terminal state, it's status has `valid` condition set to `False`, because the 
`ClusterResourcePlacement` object is not found. The user should verify if the `ClusterResourcePlacement` object is missing or
if it is being deleted and recreate the `ClusterResourcePlacement` object if needed and retry eviction.

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

In this case the Eviction object reached a terminal state, it's status has `valid` condition set to `False`, because the
`ClusterResourceBinding` object is not found.

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

In this case the Eviction object reached a terminal state, it's status has `valid` condition set to `False`, because 
there is more than one `ClusterResourceBinding` object present for the `ClusterResourcePlacement` object. This is a rare
scenario, the user cac retrying the eviction again shortly to successfully evict resources.

## Failed to execute eviction

### Due to specified CRPDB

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

In this cae the Eviction object reached a terminal state, it's status has `executed` condition set to `False`, because 
the `ClusterResourcePlacementDisruptionBudget` object is blocking the eviction.

Taking a look at the `ClusterResourcePlacementDisruptionBudget` object,

```
arvindthirumurugan@Arvinds-MacBook-Pro kubefleet % kubectl get crpdb pick-all-crp -o YAML
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
