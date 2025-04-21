# Placement Eviction Troubleshooting Guide

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
if it is being deleted and recreate the `ClusterResourcePlacement` object if needed.

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

### More than one CRB is present

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
  - lastTransitionTime: "2025-04-18T00:18:55Z"
    message: Eviction is valid
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionValid
    status: "True"
    type: Valid
  - lastTransitionTime: "2025-04-18T00:18:55Z"
    message: 'Eviction is blocked by specified ClusterResourcePlacementDisruptionBudget,
      availablePlacements: 1, totalPlacements: 1'
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionNotExecuted
    status: "False"
    type: Executed
```