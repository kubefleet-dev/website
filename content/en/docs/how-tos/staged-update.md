---
title: How to Roll Out and Roll Back Changes in Stage
description: How to roll out and roll back changes with staged update APIs
weight: 13
---

This how-to guide demonstrates how to use staged updates to rollout resources to member clusters in a staged manner and rollback resources to a previous version. We'll cover both cluster-scoped and namespace-scoped approaches to serve different organizational needs.

## Overview of Staged Update Approaches

Kubefleet provides two staged update approaches:

**Cluster-Scoped**: Use `ClusterStagedUpdateRun` with `ClusterResourcePlacement` (CRP) for fleet administrators managing infrastructure-level changes.

**Namespace-Scoped**: Use `StagedUpdateRun` with `ResourcePlacement` for application teams managing rollouts within their specific namespaces.

## Prerequisite

This tutorial is based on a demo fleet environment with 3 member clusters:

| cluster name | labels                      |
| ------------ | --------------------------- |
| member1      | environment=canary, order=2 |
| member2      | environment=staging         |
| member3      | environment=canary, order=1 |

We'll demonstrate both cluster-scoped and namespace-scoped staged updates using different scenarios.

## Cluster-Scoped Staged Updates

### Setup for Cluster-Scoped Updates

To demonstrate cluster-scoped rollout and rollback behavior, we create a demo namespace and a sample configmap with very simple data on the hub cluster. The namespace with configmap will be deployed to the member clusters.

```bash
kubectl create ns test-namespace
kubectl create cm test-cm --from-literal=key=value1 -n test-namespace
```

Now we create a `ClusterResourcePlacement` to deploy the resources:

```bash
kubectl apply -f - << EOF
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
    type: External
EOF
```

**Note that `spec.strategy.type` is set to `External` to allow rollout triggered with a ClusterStagedUpdateRun.**
All clusters should be scheduled since we use the `PickAll` policy but at the moment no resource should be deployed on the member clusters because we haven't created a `ClusterStagedUpdateRun` yet. The CRP is not **AVAILABLE** yet.

```bash
kubectl get crp example-placement
NAME                GEN   SCHEDULED   SCHEDULED-GEN   AVAILABLE   AVAILABLE-GEN   AGE
example-placement   1     True        1                                           8s
```

### Check cluster resource snapshot versions

Fleet keeps a list of resource snapshots for version control and audit, (for more details, please refer to [api-reference](docs/api-reference)).

To check current resource snapshots:

```text
kubectl get clusterresourcesnapshots --show-labels
NAME                           GEN   AGE     LABELS
example-placement-0-snapshot   1     7m31s   kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP=example-placement,kubernetes-fleet.io/resource-index=0
```

We only have one version of the snapshot. It is the current latest (`kubernetes-fleet.io/is-latest-snapshot=true`) and has resource-index 0 (`kubernetes-fleet.io/resource-index=0`).

Now we modify the our configmap with a new value `value2`:

```text
kubectl edit cm test-cm -n test-namespace

kubectl get configmap test-cm -n test-namespace -o yaml
apiVersion: v1
data:
  key: value2     # value updated here, old value: value1
kind: ConfigMap
metadata:
  creationTimestamp: ...
  name: test-cm
  namespace: test-namespace
  resourceVersion: ...
  uid: ...
```

It now shows 2 versions of resource snapshots with index 0 and 1 respectively:

```text
kubectl get clusterresourcesnapshots --show-labels
NAME                           GEN   AGE    LABELS
example-placement-0-snapshot   1     17m    kubernetes-fleet.io/is-latest-snapshot=false,kubernetes-fleet.io/parent-CRP=example-placement,kubernetes-fleet.io/resource-index=0
example-placement-1-snapshot   1     2m2s   kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP=example-placement,kubernetes-fleet.io/resource-index=1
```

The `latest` label set to `example-placement-1-snapshot` which contains the latest configmap data:

```text
kubectl get clusterresourcesnapshots example-placement-1-snapshot -o yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourceSnapshot
metadata:
  ...
  labels:
    kubernetes-fleet.io/is-latest-snapshot: "true"
    kubernetes-fleet.io/parent-CRP: example-placement
    kubernetes-fleet.io/resource-index: "1"
  name: example-placement-1-snapshot
  ...
spec:
  selectedResources:
  - apiVersion: v1
    kind: Namespace
    metadata:
      labels:
        kubernetes.io/metadata.name: test-namespace
      name: test-namespace
    spec:
      finalizers:
      - kubernetes
  - apiVersion: v1
    data:
      key: value2 # latest value: value2, old value: value1
    kind: ConfigMap
    metadata:
      name: test-cm
      namespace: test-namespace
```

### Deploy a ClusterStagedUpdateStrategy

A `ClusterStagedUpdateStrategy` defines the orchestration pattern that groups clusters into stages and specifies the rollout sequence.
It selects member clusters by labels. For our demonstration, we create one with two stages:

```bash
kubectl apply -f - << EOF
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
      maxConcurrency: 30%  # Update clusters sequentially in staging, 30% of 1 clusters is 0.3, we usually round down but if value is less than 1 we set maxConcurrency to 1
      afterStageTasks:
        - type: TimedWait
          waitTime: 1m
    - name: canary
      labelSelector:
        matchLabels:
          environment: canary
      sortingLabelKey: order
      maxConcurrency: 2  # Update 2 canary clusters concurrently
      beforeStageTasks:
        - type: Approval  # Require approval before starting canary
      afterStageTasks:
        - type: Approval  # Require approval after canary completes
EOF
```

### Deploy a ClusterStagedUpdateRun to rollout latest change

A `ClusterStagedUpdateRun` executes the rollout of a `ClusterResourcePlacement` following a `ClusterStagedUpdateStrategy`. To trigger the staged update run for our CRP, we create a `ClusterStagedUpdateRun` specifying the CRP name, updateRun strategy name, and the latest resource snapshot index ("1"):

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateRun
metadata:
  name: example-run
spec:
  placementName: example-placement
  resourceSnapshotIndex: "1"
  stagedRolloutStrategyName: example-strategy
  state: Initialize  # Initialize but don't start execution yet
EOF
```

The UpdateRun starts in `Initialize` state, which computes the stages without executing. This allows you to review the computed stages before starting:

```bash
kubectl get csur example-run -o yaml  # Review computed stages in status
```

Output:

``` yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateRun
metadata:
  ...
  generation: 1
  name: example-run
  ...
spec:
  placementName: example-placement
  resourceSnapshotIndex: "1"
  stagedRolloutStrategyName: example-strategy
  state: Initialize
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: ...
    message: ...
    observedGeneration: 1
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
  deletionStageStatus:
    clusters: []
    stageName: kubernetes-fleet.io/deleteStage
  policyObservedClusterCount: 3
  policySnapshotIndexUsed: "0"
  resourceSnapshotIndexUsed: "1"
  stagedUpdateStrategySnapshot:
    stages:
    - afterStageTasks:
      - type: TimedWait
        waitTime: 1m0s
      labelSelector:
        matchLabels:
          environment: staging
      maxConcurrency: 30%
      name: staging
    - afterStageTasks:
      - type: Approval
      beforeStageTasks:
      - type: Approval
      labelSelector:
        matchLabels:
          environment: canary
      maxConcurrency: 2
      name: canary
      sortingLabelKey: order
  stagesStatus:
  - afterStageTaskStatus:
    - type: TimedWait
    clusters:
    - clusterName: kind-cluster-2
    stageName: staging
  - afterStageTaskStatus:
    - approvalRequestName: example-run-after-canary
      type: Approval
    beforeStageTaskStatus:
    - approvalRequestName: example-run-before-canary
      type: Approval
    clusters:
    - clusterName: kind-cluster-3
    - clusterName: kind-cluster-1
    stageName: canary
```

Once satisfied with the plan, start the rollout by changing the state to `Run`:

```bash
kubectl patch csur example-run --type='merge' -p '{"spec":{"state":"Run"}}'
```

The staged update run is initialized and running:

```text
kubectl get csur example-run
NAME          PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
example-run   example-placement   1                         0                       True          True                      62s
```

A more detailed look at the status:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateRun
metadata:
  ...
  name: example-run
  generation: 2 # state changed from Initialize -> Run
  ...
spec:
  placementName: example-placement
  resourceSnapshotIndex: "1"
  stagedRolloutStrategyName: example-strategy
  state: Run
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: ...
    message: ...
    observedGeneration: 2
    reason: UpdateRunInitializedSuccessfully
    status: "True" # the updateRun is initialized successfully
    type: Initialized
  - lastTransitionTime: ...
    message: ...
    observedGeneration: 2
    reason: UpdateRunWaiting
    status: "False" # the updateRun is waiting
    type: Progressing
  deletionStageStatus:
    clusters: [] # no clusters need to be cleaned up
    stageName: kubernetes-fleet.io/deleteStage
  policyObservedClusterCount: 3 # number of clusters to be updated
  policySnapshotIndexUsed: "0"
  resourceSnapshotIndexUsed: "1"
  stagedUpdateStrategySnapshot: # snapshot of the strategy
    stages:
    - afterStageTasks:
      - type: TimedWait
        waitTime: 1m0s
      labelSelector:
        matchLabels:
          environment: staging
      maxConcurrency: 1
      name: staging
    - afterStageTasks:
      - type: Approval
      beforeStageTasks:
      - type: Approval
      labelSelector:
        matchLabels:
          environment: canary
      maxConcurrency: 2
      name: canary
      sortingLabelKey: order
  stagesStatus: # detailed status for each stage
  - afterStageTaskStatus:
    - conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 2
        reason: AfterStageTaskWaitTimeElapsed
        status: "True" # the wait after-stage task has completed
        type: WaitTimeElapsed
      type: TimedWait
    clusters:
    - clusterName: member2 # stage staging contains member2 cluster only
      conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 2
        reason: ClusterUpdatingStarted
        status: "True"
        type: Started
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 2
        reason: ClusterUpdatingSucceeded
        status: "True" # member2 is updated successfully
        type: Succeeded
    conditions:
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 2
      reason: StageUpdatingSucceeded
      status: "False"
      type: Progressing
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 2
      reason: StageUpdatingSucceeded
      status: "True" # stage staging has completed successfully
      type: Succeeded
    endTime: ...
    stageName: staging
    startTime: ...
  - afterStageTaskStatus:
    - approvalRequestName: example-run-after-canary
      type: Approval
    beforeStageTaskStatus:
    - approvalRequestName: example-run-before-canary
      conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 2
        reason: StageTaskApprovalRequestCreated
        status: "True" # before stage cluster approval task has been created
        type: ApprovalRequestCreated
      type: Approval
    clusters:
    - clusterName: member3
    - clusterName: member1
    conditions:
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 2
      reason: StageUpdatingWaiting
      status: "False"
      type: Progressing
    stageName: canary
```

After stage `staging` completes, the canary stage requires approval **before** it starts (due to beforeStageTasks). Check for the before-stage approval request:

```text
kubectl get clusterapprovalrequest -A
NAME                        UPDATE-RUN    STAGE    APPROVED   AGE
example-run-before-canary   example-run   canary              6m55s
```

Approve the before-stage task to allow canary stage to start:

```bash
kubectl patch clusterapprovalrequests example-run-before-canary --type='merge' \
  -p '{"status":{"conditions":[{"type":"Approved","status":"True","reason":"approved","message":"approved","lastTransitionTime":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","observedGeneration":1}]}}' \
  --subresource=status
```

Once approved, the canary stage begins updating clusters. With `maxConcurrency: 2`, it updates up to 2 clusters concurrently.

Wait for the canary stage to finish cluster updates. It will then wait for the after-stage Approval task:

```text
kubectl get clusterapprovalrequest -A
NAME                        UPDATE-RUN    STAGE    APPROVED   AGE
example-run-after-canary    example-run   canary              3s
example-run-before-canary   example-run   canary   True       15m
```

> Note: Observed generation in the Approved condition should match the generation of the approvalRequest object.

Approve the after-stage task to complete the rollout:

```bash
kubectl patch clusterapprovalrequests example-run-after-canary --type='merge' \
  -p '{"status":{"conditions":[{"type":"Approved","status":"True","reason":"approved","message":"approved","lastTransitionTime":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","observedGeneration":1}]}}' \
  --subresource=status
```

Alternatively, you can approve using a json patch file:

```bash
cat << EOF > approval.json
"status": {
    "conditions": [
        {
            "lastTransitionTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
            "message": "approved",
            "observedGeneration": 1,
            "reason": "approved",
            "status": "True",
            "type": "Approved"
        }
    ]
}
EOF
kubectl patch clusterapprovalrequests example-run-after-canary --type='merge' --subresource=status --patch-file approval.json
```

Verify both approvals are accepted:

```text
kubectl get clusterapprovalrequest -A
NAME                        UPDATE-RUN    STAGE    APPROVED   AGE
example-run-after-canary    example-run   canary   True       2m12s
example-run-before-canary   example-run   canary   True       17m
```

The updateRun now is able to proceed and complete:

```text
kubectl get csur example-run
NAME          PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
example-run   example-placement   1                         0                       True          False         True        20m
```

The CRP also shows rollout has completed and resources are available on all member clusters:

```text
kubectl get crp example-placement
NAME                GEN   SCHEDULED   SCHEDULED-GEN   AVAILABLE   AVAILABLE-GEN   AGE
example-placement   1     True        1               True        1               36m
```

The configmap `test-cm` should be deployed on all 3 member clusters, with latest data:

```yaml
data:
  key: value2
```

### Using Latest Snapshot Automatically

Instead of specifying a resource snapshot index, you can omit `resourceSnapshotIndex` to automatically use the latest snapshot. This is useful for continuous delivery workflows:

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateRun
metadata:
  name: example-run-latest
spec:
  placementName: example-placement
  # resourceSnapshotIndex omitted - uses latest automatically
  stagedRolloutStrategyName: example-strategy
  state: Run  # Start immediately
EOF
```

The system will determine the latest snapshot at initialization time. Check which snapshot was used:

```bash
kubectl get csur example-run-latest -o jsonpath='{.status.resourceSnapshotIndexUsed}'
```

If we are following the instructions so far, the resourceSnapshotIndexUsed would be 1 since we updated the configmap with value2,

```text
1
```

### Pausing and Resuming a Rollout

You can pause an in-progress rollout to investigate issues or wait for off-peak hours:

```bash
# Pause the rollout
kubectl patch csur example-run --type='merge' -p '{"spec":{"state":"Stop"}}'
```

Verify the rollout is stopped:

```text
kubectl get csur example-run
NAME          PLACEMENT           RESOURCE-SNAPSHOT   POLICY-SNAPSHOT   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
example-run   example-placement   1                   0                 True          False                     8m
```

The rollout pauses at its current position (current cluster/stage). Resume when ready:

```bash
# Resume the rollout
kubectl patch csur example-run --type='merge' -p '{"spec":{"state":"Run"}}'
```

The rollout continues from where it was paused.

### Deploy a second ClusterStagedUpdateRun to rollback to a previous version

Now suppose the workload admin wants to rollback the configmap change, reverting the value `value2` back to `value1`.
Instead of manually updating the configmap from hub, they can create a new `ClusterStagedUpdateRun` with a previous resource snapshot index, "0" in our context and they can reuse the same strategy:

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateRun
metadata:
  name: example-run-2
spec:
  placementName: example-placement
  resourceSnapshotIndex: "0"  # Rollback to previous version
  stagedRolloutStrategyName: example-strategy
  state: Run  # Start rollback immediately
EOF
```

Following the same step as [deploying the first updateRun](#deploy-a-clusterstagedupdaterun-to-rollout-latest-change), the second updateRun should succeed also. Complete status shown as below:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterStagedUpdateRun
metadata:
  ...
  name: example-run-2
  generation: 1
  ...
spec:
  placementName: example-placement
  resourceSnapshotIndex: "0"
  stagedRolloutStrategyName: example-strategy
  state: Run
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: ...
    message: ...
    observedGeneration: 1
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
  - lastTransitionTime: ...
    message: ...
    observedGeneration: 1
    reason: UpdateRunSucceeded
    status: "False"
    type: Progressing
  - lastTransitionTime: ...
    message: ...
    observedGeneration: 1
    reason: UpdateRunSucceeded # updateRun succeeded
    status: "True"
    type: Succeeded
  deletionStageStatus:
    clusters: []
    conditions:
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 1
      reason: StageUpdatingSucceeded
      status: "False"
      type: Progressing
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 1
      reason: StageUpdatingSucceeded
      status: "True" # no clusters in the deletion stage, it completes directly
      type: Succeeded
    endTime: ...
    stageName: kubernetes-fleet.io/deleteStage
    startTime: ...
  policyObservedClusterCount: 3
  policySnapshotIndexUsed: "0"
  resourceSnapshotIndexUsed: "0"
  stagedUpdateStrategySnapshot:
    stages:
    - afterStageTasks:
      - type: TimedWait
        waitTime: 1m0s
      labelSelector:
        matchLabels:
          environment: staging
      maxConcurrency: 1
      name: staging
    - afterStageTasks:
      - type: Approval
      beforeStageTasks:
      - type: Approval
      labelSelector:
        matchLabels:
          environment: canary
      maxConcurrency: 2
      name: canary
      sortingLabelKey: order
  stagesStatus:
  - afterStageTaskStatus:
    - conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: AfterStageTaskWaitTimeElapsed
        status: "True"
        type: WaitTimeElapsed
      type: TimedWait
    clusters:
    - clusterName: member2
      conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: ClusterUpdatingStarted
        status: "True"
        type: Started
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: ClusterUpdatingSucceeded
        status: "True"
        type: Succeeded
    conditions:
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 1
      reason: StageUpdatingSucceeded
      status: "False"
      type: Progressing
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 1
      reason: StageUpdatingSucceeded
      status: "True"
      type: Succeeded
    endTime: ...
    stageName: staging
    startTime: ...
  - afterStageTaskStatus:
    - approvalRequestName: example-run-2-after-canary
      conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: StageTaskApprovalRequestCreated
        status: "True"
        type: ApprovalRequestCreated
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: StageTaskApprovalRequestApproved
        status: "True"
        type: ApprovalRequestApproved
      type: Approval
    beforeStageTaskStatus:
    - approvalRequestName: example-run-2-before-canary
      conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: StageTaskApprovalRequestCreated
        status: "True"
        type: ApprovalRequestCreated
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: StageTaskApprovalRequestApproved
        status: "True"
        type: ApprovalRequestApproved
      type: Approval
    clusters:
    - clusterName: member3
      conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: ClusterUpdatingStarted
        status: "True"
        type: Started
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: ClusterUpdatingSucceeded
        status: "True"
        type: Succeeded
    - clusterName: member1
      conditions:
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: ClusterUpdatingStarted
        status: "True"
        type: Started
      - lastTransitionTime: ...
        message: ...
        observedGeneration: 1
        reason: ClusterUpdatingSucceeded
        status: "True"
        type: Succeeded
    conditions:
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 1
      reason: StageUpdatingSucceeded
      status: "False"
      type: Progressing
    - lastTransitionTime: ...
      message: ...
      observedGeneration: 1
      reason: StageUpdatingSucceeded
      status: "True"
      type: Succeeded
    endTime: ...
    stageName: canary
    startTime: ...
```

The configmap `test-cm` should be updated on all 3 member clusters, with old data:

```yaml
data:
  key: value1
```

## Namespace-Scoped Staged Updates

Namespace-scoped staged updates allow application teams to manage rollouts independently within their namespaces using `StagedUpdateRun` and `StagedUpdateStrategy` resources.

### Setup for Namespace-Scoped Updates

Let's demonstrate namespace-scoped staged updates by deploying an application within a specific namespace.

Create a namespace,

```bash
kubectl create ns my-app-namespace
```

Create a CRP that only propagates the namespace (i.e. with selectionScope set to NamespaceOnly, the namespace resource is propagated without any resources within the namespace) to all the clusters.

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: ns-only-crp
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      name: my-app-namespace
      version: v1
      selectionScope: NamespaceOnly
  policy:
    placementType: PickAll
  strategy:
    type: RollingUpdate
EOF
```

Create application to rollout,

```bash
kubectl create deployment web-app --image=nginx:1.20 --port=80 -n my-app-namespace
kubectl expose deployment web-app --port=80 --target-port=80 -n my-app-namespace
```

Create a namespace-scoped `ResourcePlacement` to deploy the application:

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourcePlacement
metadata:
  name: web-app-placement
  namespace: my-app-namespace
spec:
  resourceSelectors:
    - group: "apps"
      kind: Deployment
      name: web-app
      version: v1
    - group: ""
      kind: Service
      name: web-app
      version: v1
  policy:
    placementType: PickAll
  strategy:
    type: External # enables namespace-scoped staged updates
EOF
```

### Check namespace-scoped resource snapshots

Check the resource snapshots for the namespace-scoped placement:

```text
kubectl get resourcesnapshots -n my-app-namespace
NAME                           GEN   AGE
web-app-placement-0-snapshot   1     30s
```

Update the deployment to a new version:

```bash
kubectl set image deployment/web-app nginx=nginx:1.21 -n my-app-namespace
```

Verify the new snapshot is created:

```text
kubectl get resourcesnapshots -n my-app-namespace --show-labels
NAME                           GEN   AGE     LABELS
web-app-placement-0-snapshot   1     5m24s   kubernetes-fleet.io/is-latest-snapshot=false,kubernetes-fleet.io/parent-CRP=web-app-placement,kubernetes-fleet.io/resource-index=0
web-app-placement-1-snapshot   1     16s     kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP=web-app-placement,kubernetes-fleet.io/resource-index=1
```

### Deploy a StagedUpdateStrategy

Create a namespace-scoped staged update strategy:

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: StagedUpdateStrategy
metadata:
  name: app-rollout-strategy
  namespace: my-app-namespace
spec:
  stages:
    - name: dev
      labelSelector:
        matchLabels:
          environment: staging
      maxConcurrency: 2  # Update 2 dev clusters concurrently
      afterStageTasks:
        - type: TimedWait
          waitTime: 30s
    - name: prod
      labelSelector:
        matchLabels:
          environment: canary
      sortingLabelKey: order
      maxConcurrency: 1  # Sequential production updates
      beforeStageTasks:
        - type: Approval  # Require approval before production
      afterStageTasks:
        - type: Approval  # Require approval after production
EOF
```

### Deploy a StagedUpdateRun

Create a namespace-scoped staged update run to rollout the new image version:

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: StagedUpdateRun
metadata:
  name: web-app-rollout-v1-21
  namespace: my-app-namespace
spec:
  placementName: web-app-placement
  resourceSnapshotIndex: "1"  # Latest snapshot with nginx:1.21
  stagedRolloutStrategyName: app-rollout-strategy
  state: Run  # Start rollout immediately
EOF
```

### Monitor namespace-scoped staged rollout

Check the status of the staged update run:

```bash
kubectl get sur web-app-rollout-v1-21 -n my-app-namespace
```

Wait for the first stage to complete. The prod before stage requires approval before starting:

```text
kubectl get approvalrequests -n my-app-namespace
NAME                                UPDATE-RUN              STAGE   APPROVED   AGE
web-app-rollout-v1-21-before-prod   web-app-rollout-v1-21   prod               2s
```

Approve the before-stage task to start production rollout:

```bash
kubectl patch approvalrequests web-app-rollout-v1-21-before-prod -n my-app-namespace --type='merge' \
  -p '{"status":{"conditions":[{"type":"Approved","status":"True","reason":"approved","message":"approved","lastTransitionTime":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","observedGeneration":1}]}}' \
  --subresource=status
```

After production clusters complete updates, approve the after-stage task:

```text
kubectl get approvalrequests -n my-app-namespace
NAME                                UPDATE-RUN              STAGE   APPROVED   AGE
web-app-rollout-v1-21-after-prod    web-app-rollout-v1-21   prod               18s
web-app-rollout-v1-21-before-prod   web-app-rollout-v1-21   prod    True       2m22s

kubectl patch approvalrequests web-app-rollout-v1-21-after-prod  -n my-app-namespace --type='merge' \
  -p '{"status":{"conditions":[{"type":"Approved","status":"True","reason":"approved","message":"approved","lastTransitionTime":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","observedGeneration":1}]}}' \
  --subresource=status
```

Verify the rollout completion:

```bash
kubectl get sur web-app-rollout-v1-21 -n my-app-namespace
kubectl get resourceplacement web-app-placement -n my-app-namespace
```

### Rollback with namespace-scoped staged updates

To rollback to the previous version (nginx:1.20), create another staged update run referencing the earlier snapshot:

```bash
kubectl apply -f - << EOF
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: StagedUpdateRun
metadata:
  name: web-app-rollback-v1-20
  namespace: my-app-namespace
spec:
  placementName: web-app-placement
  resourceSnapshotIndex: "0"  # Previous snapshot with nginx:1.20
  stagedRolloutStrategyName: app-rollout-strategy
  state: Run  # Start rollback immediately
EOF
```

Follow the same monitoring and approval process as above to complete the rollback.

## Best Practices and Tips

### MaxConcurrency Guidelines

- **Development/Staging**: Use higher values (e.g., `maxConcurrency: 3` or `50%`) to speed up rollouts
- **Production**: Use `maxConcurrency: 1` for sequential updates to minimize risk and allow early detection of issues
- **Large fleets**: Use percentages (e.g., `10%`, `25%`) to scale with cluster growth automatically
- **Small fleets**: Use absolute numbers for predictable behavior

### State Management

- **Initialize state**: Use to review computed stages before execution. Useful for validating strategy configuration
- **Run state**: Start execution or resume from stopped state
- **Stop state**: Pause rollout to investigate issues, wait for maintenance windows, or coordinate with other activities

### Approval Strategies

- **Before-stage approvals**: Use when stage selection requires validation (e.g., ensure all production prerequisites are met)
- **After-stage approvals**: Use to validate rollout success before proceeding (e.g., check metrics, run tests)
- **Both**: Combine for critical stages requiring validation at both entry and exit points

## Key Differences Summary

| Aspect                 | Cluster-Scoped                                 | Namespace-Scoped                       |
| ---------------------- | ---------------------------------------------- | -------------------------------------- |
| **Strategy Resource**  | `ClusterStagedUpdateStrategy`                  | `StagedUpdateStrategy`                 |
| **UpdateRun Resource** | `ClusterStagedUpdateRun`                       | `StagedUpdateRun`                      |
| **Target Placement**   | `ClusterResourcePlacement`                     | `ResourcePlacement`                    |
| **Approval Resource**  | `ClusterApprovalRequest` (short name: `careq`) | `ApprovalRequest` (short name: `areq`) |
| **Scope**              | Cluster-wide                                   | Namespace-bound                        |
| **Use Case**           | Infrastructure rollouts                        | Application rollouts                   |
| **Permissions**        | Cluster-admin level                            | Namespace-level                        |
