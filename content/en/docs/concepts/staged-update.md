---
title: Staged Update
description: Concept about Staged Update
weight: 13
---

While users can rely on the `RollingUpdate` rollout strategy in the placement to safely roll out their workloads,
many organizations require more sophisticated deployment control mechanisms for their fleet operations.
Standard rolling updates, while effective for individual rollout, lack the granular control and coordination capabilities needed for complex, multi-cluster environments.

## Why Staged Rollouts?

Staged rollouts address critical deployment challenges that organizations face when managing workloads across distributed environments:

### Strategic Grouping and Ordering

Traditional rollout strategies treat all target clusters uniformly, but real-world deployments often require strategic sequencing. Staged rollouts enable you to:

- **Group clusters by environment** (development → staging → production)
- **Prioritize by criticality** (test clusters before business-critical systems)
- **Sequence by dependencies** (deploy foundational services before dependent applications)

This grouping capability ensures that updates follow your organization's risk management and operational requirements rather than arbitrary ordering.

### Enhanced Control and Approval Gates

Automated rollouts provide speed but can propagate issues rapidly across your entire fleet. Staged rollouts introduce deliberate checkpoints that give teams control over the rollout progression:

- **Manual approval gates** between stages allow human validation of rollout health
- **Automated wait periods** provide time for monitoring and observation


## Dual-Scope Architecture

Kubefleet provides staged update capabilities at two different scopes to address different organizational roles and operational requirements:

1. **Cluster-scoped staged updates** for fleet administrators who need to manage rollouts across entire clusters
2. **Namespace-scoped staged updates** for application teams who need to manage rollouts within their specific namespaces

This dual approach enables fleet administrators maintain oversight of infrastructure-level changes while empowering application teams with autonomous control over their specific workloads.

![](/images/en/docs/concepts/staged-update/updaterun.jpg)

## Overview

Kubefleet provides staged update capabilities at two scopes to serve different organizational needs:

**Cluster-Scoped**: `ClusterStagedUpdateStrategy` and `ClusterStagedUpdateRun` for fleet administrators managing infrastructure-level changes across clusters.

**Namespace-Scoped**: `StagedUpdateStrategy` and `StagedUpdateRun` for application teams managing rollouts within their specific namespaces.

Both systems follow the same pattern:
1. **Strategy** resources define reusable orchestration patterns with stages, ordering, and approval gates
2. **UpdateRun** resources execute the strategy for specific rollouts using a target placement, resource snapshot, and strategy name
3. **External rollout** strategy must be set on the target placement to enable staged updates

### Key Differences by Persona

| Aspect | Fleet Administrators (Cluster-Scoped) | Application Teams (Namespace-Scoped) |
|--------|---------------------------------------|-------------------------------------|
| **Scope** | Entire clusters and infrastructure | Individual applications within namespaces |
| **Resources** | `ClusterStagedUpdateStrategy`, `ClusterStagedUpdateRun` | `StagedUpdateStrategy`, `StagedUpdateRun` |
| **Target** | `ClusterResourcePlacement` | `ResourcePlacement` (namespace-scoped) |
| **Use Cases** | Fleet-wide updates, infrastructure changes | Application rollouts, service updates |
| **Autonomy** | Requires cluster-admin permissions | Operates within namespace boundaries |

## Configure External Rollout Strategy

Both placement types require setting the rollout strategy to `External` to enable staged updates:

**Cluster-scoped example:**
```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: example-placement
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      name: test-namespace
      version: v1
  policy:
    placementType: PickAll
  strategy:
    type: External # enables staged updates
```

**Namespace-scoped example:**
```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourcePlacement
metadata:
  name: example-namespace-placement
  namespace: my-app-namespace
spec:
  resourceSelectors:
    - group: "apps"
      kind: Deployment
      name: my-application
      version: v1
  policy:
    placementType: PickAll
  strategy:
    type: External # enables staged updates
```

## Define Staged Update Strategies

Staged update strategies define reusable orchestration patterns that organize targets into stages with specific rollout sequences and approval gates. Both scopes use similar configurations but operate at different levels.

### Cluster-Scoped Strategy

`ClusterStagedUpdateStrategy` organizes member clusters into stages:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateStrategy
metadata:
  name: example-strategy
spec:
  stages:
    - name: staging
      labelSelector:
        matchLabels:
          environment: staging
      afterStageTasks:
        - type: TimedWait
          waitTime: 1h
    - name: canary
      labelSelector:
        matchLabels:
          environment: canary
      afterStageTasks:
        - type: Approval
    - name: production
      labelSelector:
        matchLabels:
          environment: production
      sortingLabelKey: order
      afterStageTasks:
        - type: Approval
        - type: TimedWait
          waitTime: 1h
```

### Namespace-Scoped Strategy

`StagedUpdateStrategy` follows the same pattern but operates within namespace boundaries:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: StagedUpdateStrategy
metadata:
  name: app-rollout-strategy
  namespace: my-app-namespace
spec:
  stages:
    - name: dev-clusters
      labelSelector:
        matchLabels:
          environment: development
      afterStageTasks:
        - type: TimedWait
          waitTime: 30m
    - name: production-clusters
      labelSelector:
        matchLabels:
          environment: production
      sortingLabelKey: deployment-order
      afterStageTasks:
        - type: Approval
```

### Stage Configuration

Each stage includes:
- **name**: Unique identifier for the stage
- **labelSelector**: Selects target clusters for this stage
- **sortingLabelKey** (optional): Label whose integer value determines update sequence within the stage
- **afterStageTasks** (optional): Tasks that must complete before proceeding to the next stage

### After-Stage Tasks

Two task types control stage progression:
- **TimedWait**: Waits for a specified duration before proceeding
- **Approval**: Requires manual approval via an approval request object

For approval tasks, the system automatically creates an approval request object named `<updateRun-name>-<stage-name>`. The approval request type depends on the scope:

- **Cluster-scoped**: Creates `ClusterApprovalRequest` (short name: `careq`)
- **Namespace-scoped**: Creates `ApprovalRequest` (short name: `areq`) within the same namespace

Approve manually using kubectl patch:

```bash
# For cluster-scoped approvals
kubectl patch clusterapprovalrequests example-run-canary --type='merge' \
  -p '{"status":{"conditions":[{"type":"Approved","status":"True","reason":"approved","message":"approved"}]}}' \
  --subresource=status

# For namespace-scoped approvals
kubectl patch approvalrequests app-run-canary -n my-app-namespace --type='merge' \
  -p '{"status":{"conditions":[{"type":"Approved","status":"True","reason":"approved","message":"approved"}]}}' \
  --subresource=status
```

## Trigger Staged Rollouts

UpdateRun resources execute strategies for specific rollouts. Both scopes follow the same pattern with three required parameters:

**Cluster-scoped example:**
```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateRun
metadata:
  name: example-run
spec:
  placementName: example-placement              # Target ClusterResourcePlacement
  resourceSnapshotIndex: "0"                    # Resource version to deploy
  stagedRolloutStrategyName: example-strategy   # Strategy to execute
```

**Namespace-scoped example:**
```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: StagedUpdateRun
metadata:
  name: app-rollout-v1-2-3
  namespace: my-app-namespace
spec:
  placementName: example-namespace-placement    # Target ResourcePlacement
  resourceSnapshotIndex: "5"                    # Resource version to deploy
  stagedRolloutStrategyName: app-rollout-strategy # Strategy to execute
```

### UpdateRun Execution

UpdateRuns execute in two phases:
1. **Initialization**: Captures strategy snapshot, collects target bindings, generates cluster update sequence
2. **Execution**: Processes stages sequentially, updates clusters within each stage, enforces after-stage tasks

### Important Constraints and Validation

**Immutable Fields**: Once created, the following UpdateRun spec fields cannot be modified:
- `placementName`: Target placement resource name
- `resourceSnapshotIndex`: Resource version to deploy
- `stagedRolloutStrategyName`: Strategy to execute

**State Management**: UpdateRuns have lifecycle states with restricted transitions:
- `NotStarted` (default) → `Started` or `Abandoned`
- `Started` → `Stopped` or `Abandoned`
- `Stopped` → `Started` or `Abandoned`
- `Abandoned` (terminal state, cannot transition to other states)

**Strategy Limits**: Each strategy can define a maximum of 31 stages to ensure reasonable execution times.

## Monitor UpdateRun Status

UpdateRun status provides detailed information about rollout progress across stages and clusters. The status includes:

- **Overall conditions**: Initialization, progression, and completion status
- **Stage status**: Progress and timing for each stage
- **Cluster status**: Individual cluster update results
- **After-stage task status**: Approval and wait task progress

Use `kubectl describe` to view detailed status:
```bash
# Cluster-scoped (can use short name 'csur')
kubectl describe clusterstagedupdaterun example-run
kubectl describe csur example-run

# Namespace-scoped (can use short name 'sur')
kubectl describe stagedupdaterun app-rollout-v1-2-3 -n my-app-namespace
kubectl describe sur app-rollout-v1-2-3 -n my-app-namespace
```

## UpdateRun and Placement Relationship

UpdateRuns serve as triggers for their respective placement resources:

- **Cluster-scoped**: `ClusterStagedUpdateRun` triggers `ClusterResourcePlacement`
- **Namespace-scoped**: `StagedUpdateRun` triggers `ResourcePlacement`

The placement resource remains in a scheduled state until triggered by an UpdateRun. During rollout:
- **UpdateRun status** shows stage progression and cluster update completion
- **Placement status** provides detailed rollout information including resource creation success/failure and error messages

## Concurrent UpdateRuns

Multiple UpdateRuns can execute concurrently for the same placement with one constraint: all concurrent runs must use identical strategy configurations to ensure consistent behavior.

## Next Steps
* Learn how to [rollout and rollback CRP resources with Staged Update Run](docs/how-tos/staged-update)
* Learn how to [troubleshoot a Staged Update Run](docs/troubleshooting/ClusterStagedUpdateRun)
