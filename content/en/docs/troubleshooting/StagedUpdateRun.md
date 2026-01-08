---
title: Staged Update Run TSG
description: Identify and fix KubeFleet issues associated with both ClusterStagedUpdateRun and StagedUpdateRun APIs
weight: 10
---

This guide provides troubleshooting steps for common issues related to both cluster-scoped and namespace-scoped Staged Update Runs.

> Note: To get more information about failures, you can check the [updateRun controller](https://github.com/kubefleet-dev/kubefleet/blob/main/pkg/controllers/updaterun/controller.go) logs.

### Things to keep in mind when using updateRun

If updateRun is created with Initialized/Stop state updateRun won't start execution. In both cases updateRun will be initialized.

State set to `Initialize`,
```yaml
spec:
  placementName: example-placement
  resourceSnapshotIndex: "0"
  stagedRolloutStrategyName: example-strategy
  state: Initialize
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: "2026-01-09T01:21:18Z"
    message: The UpdateRun initialized successfully
    observedGeneration: 1
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
```

State set to `Stop`,
```yaml
spec:
  placementName: example-placement
  resourceSnapshotIndex: "0"
  stagedRolloutStrategyName: example-strategy
  state: Stop
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: "2026-01-09T01:22:55Z"
    message: The UpdateRun initialized successfully
    observedGeneration: 1
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
  - lastTransitionTime: "2026-01-09T01:22:55Z"
    message: The update run has been stopped
    observedGeneration: 1
    reason: UpdateRunStopped
    status: "False"
    type: Progressing
```

## Cluster-Scoped Troubleshooting

### CRP status without Staged Update Run

When a `ClusterResourcePlacement` is created with `spec.strategy.type` set to `External`, the rollout does not start immediately.

A sample status of such `ClusterResourcePlacement` is as follows:

```yaml
$ kubectl describe crp example-placement
...
Status:
  Conditions:
    Last Transition Time:  2026-01-08T00:19:58Z
    Message:               found all cluster needed as specified by the scheduling policy, found 2 cluster(s)
    Observed Generation:   1
    Reason:                SchedulingPolicyFulfilled
    Status:                True
    Type:                  ClusterResourcePlacementScheduled
    Last Transition Time:  2026-01-08T00:19:58Z
    Message:               Rollout is controlled by an external controller and no resource snapshot name is observed across clusters, probably rollout has not started yet
    Observed Generation:   1
    Reason:                RolloutControlledByExternalController
    Status:                Unknown
    Type:                  ClusterResourcePlacementRolloutStarted
  Placement Statuses:
    Cluster Name:  member1
    Conditions:
      Last Transition Time:  2026-01-08T00:19:58Z
      Message:               Successfully scheduled resources for placement in "member1" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2026-01-08T00:19:58Z
      Message:               In the process of deciding whether to roll out some version of the resources or not
      Observed Generation:   1
      Reason:                RolloutStartedUnknown
      Status:                Unknown
      Type:                  RolloutStarted
    Cluster Name:            member2
    Conditions:
      Last Transition Time:  2026-01-08T00:19:58Z
      Message:               Successfully scheduled resources for placement in "member2" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2026-01-08T00:19:58Z
      Message:               In the process of deciding whether to roll out some version of the resources or not
      Observed Generation:   1
      Reason:                RolloutStartedUnknown
      Status:                Unknown
      Type:                  RolloutStarted
Events:         <none>
```

`ClusterResourcePlacementScheduled` condition indicates the CRP has been fully scheduled, while `ClusterResourcePlacementRolloutStarted` condition shows that the rollout has not started.

In the `Placement Statuses` section, it displays the detailed status of each cluster. Both selected clusters are in the `Scheduled` state, but the `RolloutStarted` condition is still `Unknown` because the rollout has not kicked off yet.

### Investigate ClusterStagedUpdateRun initialization failure

An updateRun initialization failure can be easily detected by getting the resource:
```yaml
$ kubectl get csur example-run 
NAME          PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
example-run   example-placement   1                         0                       False                                   4s
```

The `INITIALIZED` field is `False`, indicating the initialization failed.

Describe the updateRun to get more details:
```yaml
$ kubectl describe csur example-run
...
  Applied Strategy:
    Comparison Option:  PartialComparison
    Type:               ClientSideApply
    When To Apply:      Always
    When To Take Over:  Always
  Conditions:
    Last Transition Time:  2026-01-08T00:35:09Z
    Message:               cannot continue the updateRun: failed to validate the updateRun: failed to process the request due to a client error: no resourceSnapshots with index `1` found for placement `/example-placement`
    Observed Generation:   1
    Reason:                UpdateRunInitializedFailed
    Status:                False
    Type:                  Initialized
  Deletion Stage Status:
    Clusters:
    Stage Name:                   kubernetes-fleet.io/deleteStage
  Policy Observed Cluster Count:  2
  Policy Snapshot Index Used:     0
...
```

The condition clearly indicates the initialization failed. The condition message gives more details about the failure.
In this case, a non-existing resource snapshot index `1` was used for the updateRun.

### Investigate ClusterStagedUpdateRun execution failure

An updateRun execution failure can be easily detected by getting the resource:
```yaml
$ kubectl get csur example-run
NAME          PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   SUCCEEDED   AGE
example-run   example-placement   0                         0                       True          False       24m
```

The `SUCCEEDED` field is `False`, indicating the execution failure.

An updateRun execution failure can be caused by mainly 2 scenarios:

1. When the updateRun controller is triggered to reconcile an in-progress updateRun, it starts by doing a bunch of validations 
including retrieving the CRP and checking its rollout strategy, gathering all the bindings and regenerating the execution plan.
If any failure happens during validation, the updateRun execution fails with the corresponding validation error.
    ```yaml
    status:
      appliedStrategy:
        comparisonOption: PartialComparison
        type: ClientSideApply
        whenToApply: Always
        whenToTakeOver: Always
      conditions:
      - lastTransitionTime: "2026-01-08T00:40:53Z"
        message: The UpdateRun initialized successfully
        observedGeneration: 2
        reason: UpdateRunInitializedSuccessfully
        status: "True"
        type: Initialized
      - lastTransitionTime: "2026-01-08T00:41:34Z"
        message: The stages are aborted due to a non-recoverable error
        observedGeneration: 2
        reason: UpdateRunFailed
        status: "False"
        type: Progressing
      - lastTransitionTime: "2026-01-08T00:41:34Z"
        message: 'cannot continue the updateRun: failed to validate the updateRun: failed
          to process the request due to a client error: parent placement not found'
        observedGeneration: 2
        reason: UpdateRunFailed
        status: "False"
        type: Succeeded
    ```
    In above case, the CRP referenced by the updateRun is deleted during the execution. The updateRun controller detects and aborts the release.
2. The updateRun controller triggers update to a member cluster by updating the corresponding binding spec and setting its 
status to `RolloutStarted`. It then waits for default 15 seconds and check whether the resources have been successfully applied 
by checking the binding again. In case that there are multiple concurrent updateRuns, and during the 15-second wait, some other
updateRun preempts and updates the binding with new configuration, current updateRun detects and fails with clear error message.
    ```yaml
    status:
      appliedStrategy:
        comparisonOption: PartialComparison
        type: ClientSideApply
        whenToApply: Always
        whenToTakeOver: Always
      conditions:
      - lastTransitionTime: "2026-01-08T00:57:38Z"
        message: The UpdateRun initialized successfully
        observedGeneration: 1
        reason: UpdateRunInitializedSuccessfully
        status: "True"
        type: Initialized
      - lastTransitionTime: "2026-01-08T00:57:53Z"
        message: The stages are aborted due to a non-recoverable error
        observedGeneration: 1
        reason: UpdateRunFailed
        status: "False"
        type: Progressing
      - lastTransitionTime: "2026-01-08T00:57:53Z"
        message: 'cannot continue the updateRun: failed to process the request due to
          a client error: the binding of the updating cluster `member2` in the
          stage `staging` is not up-to-date with the desired status, please check the
          status of binding `example-placement-member2-e1a567da` and see if there
          is a concurrent updateRun referencing the same placement and
          updating the same cluster'
        observedGeneration: 1
        reason: UpdateRunFailed
        status: "False"
        type: Succeeded
      ```
    The `Succeeded` condition is set to `False` with reason `UpdateRunFailed`. In the `message`, we show `member2` cluster in `staging` stage gets preempted, and the user is prompted to check `example-placement-member2-e1a567da` binding to verfiy if there is a concurrent updateRun referencing the same clusterResourcePlacement and updating the same cluster
      ```yaml
      kubectl get clusterresourcebindings
      NAME                                        WORKSYNCHRONIZED   RESOURCESAPPLIED   AGE
      example-placement-member1-9a1ee3a0                                                20m
      example-placement-member2-e1a567da          True               True               20m
      ```
    Since the error message specifies `example-placement-member2-e1a567da`, we can check the binding:
      ```yaml
      kubectl get clusterresourcebinding example-placement-member2-e1a567da -o yaml
      ...
      spec:
        applyStrategy:
          comparisonOption: PartialComparison
          type: ClientSideApply
          whenToApply: Always
          whenToTakeOver: Always
        clusterDecision:
          clusterName: member2
          clusterScore:
            affinityScore: 0
            priorityScore: 0
          reason: 'Successfully scheduled resources for placement in "member2" (affinity
            score: 0, topology spread score: 0): picked by scheduling policy'
          selected: true
        resourceSnapshotName: example-placement-1-snapshot
        schedulingPolicySnapshotName: example-placement-0
        state: Bound
        targetCluster: member2
      status:
        conditions:
        - lastTransitionTime: "2026-01-08T00:57:39Z"
          message: 'Detected the new changes on the resources and started the rollout process,
            resourceSnapshotIndex: 1, updateRun: example-run-1'
          observedGeneration: 3
          reason: RolloutStarted
          status: "True"
          type: RolloutStarted
      ...
    ```
    As the binding `RolloutStarted` condition shows, it's updated by another updateRun `example-run-1`.

The updateRun abortion due to execution failures is not recoverable at the moment. If failure happens due to validation error,
one can fix the issue and create a new updateRun. If preemption happens, in most cases the user is releasing a new resource
version, and they can just let the new updateRun run to complete.

### Investigate ClusterStagedUpdateRun rollout stuck

A `ClusterStagedUpdateRun` can get stuck when resource placement fails on some clusters. Getting the updateRun will show the cluster name and stage that is in stuck state:
```yaml
$ kubectl get csur example-run -o yaml
...
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: "2026-01-12T22:42:52Z"
    message: The UpdateRun initialized successfully
    observedGeneration: 2
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
  - lastTransitionTime: "2026-01-12T22:49:51Z"
    message: The updateRun is stuck waiting for 1 cluster(s) in stage staging to finish
      updating, please check placement status for potential errors
    observedGeneration: 2
    reason: UpdateRunStuck
    status: "False"
    type: Progressing
  ...
  stagesStatus:
  - clusters:
    - clusterName: member2
      conditions:
      - lastTransitionTime: "2026-01-12T22:44:08Z"
        message: Cluster update started
        observedGeneration: 2
        reason: ClusterUpdatingStarted
        status: "True"
        type: Started
    conditions:
    - lastTransitionTime: "2026-01-12T22:44:08Z"
      message: Clusters in the stage started updating
      observedGeneration: 2
      reason: StageUpdatingStarted
      status: "True"
      type: Progressing
    stageName: staging # stage name mentioned in message.
    startTime: "2026-01-12T22:44:08Z"
  - clusters:
    - clusterName: member1
    stageName: canary
...
```
The message shows that the updateRun is stuck waiting for 1 cluster in stage `staging` to finish releasing. 
From the stagesStatus we can see `member2` is the cluster in stage `staging`. The updateRun controller rolls 
resources to a member cluster by updating its corresponding binding. It then checks periodically whether the 
update has completed or not. If the binding is still not available after current default 5 minutes, updateRun 
controller decides the rollout has stuck and reports the condition.

This usually indicates something wrong happened on the cluster or the resources have some issue. To further investigate, you can check the `ClusterResourcePlacement` status:
```yaml
$ kubectl describe crp example-placement
...
 Placement Statuses:
    ...
    Cluster Name:            member2
    Conditions:
      Last Transition Time:  2026-01-12T22:37:57Z
      Message:               Successfully scheduled resources for placement in "member2" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2026-01-12T22:44:08Z
      Message:               Detected the new changes on the resources and started the rollout process, resourceSnapshotIndex: 1, updateRun: example-run
      Observed Generation:   1
      Reason:                RolloutStarted
      Status:                True
      Type:                  RolloutStarted
      Last Transition Time:  2026-01-12T22:44:08Z
      Message:               No override rules are configured for the selected resources
      Observed Generation:   1
      Reason:                NoOverrideSpecified
      Status:                True
      Type:                  Overridden
      Last Transition Time:  2026-01-12T22:44:08Z
      Message:               All of the works are synchronized to the latest
      Observed Generation:   1
      Reason:                AllWorkSynced
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2026-01-12T22:44:08Z
      Message:               All corresponding work objects are applied
      Observed Generation:   1
      Reason:                AllWorkHaveBeenApplied
      Status:                True
      Type:                  Applied
      Last Transition Time:  2026-01-12T22:44:08Z
      Message:               Work object example-placement-work is not yet available
      Observed Generation:   1
      Reason:                NotAllWorkAreAvailable
      Status:                False
      Type:                  Available
    Failed Placements:
      Condition:
        Last Transition Time:  2026-01-12T22:44:08Z
        Message:               Manifest is not yet available; Fleet will check again later
        Observed Generation:   1
        Reason:                ManifestNotAvailableYet
        Status:                False
        Type:                  Available
      Group:                   apps
      Kind:                    Deployment
      Name:                    nginx-deployment
      Namespace:               test-namespace
      Version:                 v1
...
```

The `Available` condition is `False` and we show reason as `NotAllWorkAreAvailable`. And in the "failed placements" section, it shows
the `nginx-deployment` deployment is not available. Check from `member2` cluster and we can see
there's image pull failure:
```yaml
kubectl config use-context member2

kubectl get deployment -n test-namespace
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   0/3     3            0           9m54s

kubectl get pods -n test-namespace
NAME                                READY   STATUS             RESTARTS   AGE
nginx-deployment-5d9874b8b9-gnmm2   0/1     InvalidImageName   0          10m
nginx-deployment-5d9874b8b9-p9zsx   0/1     InvalidImageName   0          10m
nginx-deployment-5d9874b8b9-wxmd7   0/1     InvalidImageName   0          10m
```

> Note: A similar scenario can occur when updateRun's state is set to `Stop` since we allow ongoing resource placement on a cluster to continue even when State is `Stop`.

For more debugging instructions, you can refer to [ClusterResourcePlacement TSG](ClusterResourcePlacement).

After resolving the issue, you can create always create a new updateRun to restart the rollout. Stuck updateRuns can be deleted.

### ClusterApprovalRequest Troubleshooting

A `ClusterStagedUpdateRun` is not progressing after approval from user,

Getting the ClusterStagedUpdateRun should give us some insight,

```yaml
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: "2026-01-09T01:49:06Z"
    message: The UpdateRun initialized successfully
    observedGeneration: 1
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
  - lastTransitionTime: "2026-01-09T01:55:36Z"
    message: The updateRun is waiting for after-stage tasks in stage staging to complete
    observedGeneration: 1
    reason: UpdateRunWaiting
    status: "False"
    type: Progressing
```

Looks like updateRun is still waiting for approval from user. Lets get the `ClusterApprovalRequest` to verify,

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterApprovalRequest
metadata:
  creationTimestamp: "2026-01-09T01:49:36Z"
  generation: 1
  labels:
    kubernetes-fleet.io/isLatestUpdateRunApproval: "true"
    kubernetes-fleet.io/targetUpdateRun: example-run
    kubernetes-fleet.io/targetUpdatingStage: staging
    kubernetes-fleet.io/taskType: afterStage
  name: example-run-after-staging
  resourceVersion: "20752"
  uid: 9eae4ea0-3c4c-4182-a1d6-b7f1761caa6a
spec:
  parentStageRollout: example-run
  targetStage: staging
status:
  conditions:
  - lastTransitionTime: "2026-01-09T01:53:53Z"
    message: approved
    observedGeneration: 0
    reason: approved
    status: "True"
    type: Approved
```

We can notice that user has approved the request but we don't see the `ApprovalAccepted` Condition set on the object. Taking a closer look we can clearly see that the `observedGeneration` for the `Approved` condition doesn't match the object's `generation`. This applies to both before and after stage tasks.

Please refer to [Deploy a ClusterStagedUpdateRun to rollout latest change](../how-tos/staged-update#deploy-a-clusterstagedupdaterun-to-rollout-latest-change) to approve the ClusterApprovalRequest correctly.

## Namespace-Scoped Troubleshooting

Namespace-scoped `StagedUpdateRun` troubleshooting is a mirror image of cluster-scoped `ClusterStagedUpdateRun` troubleshooting. The concepts, failure patterns, and diagnostic approaches are exactly the same - only the resource names, scopes, and kubectl commands differ.

Both follow identical troubleshooting patterns:

- **Initialization failures**: Missing resource snapshots, invalid configurations
- **Execution failures**: Validation errors, concurrent updateRun conflicts
- **Rollout stuck scenarios**: Resource placement failures, cluster connectivity issues
- **Status investigation**: Using `kubectl get`, `kubectl describe`, and checking placement status
- **Recovery approaches**: Creating new updateRuns, cleaning up stuck resources

The key differences are:

- **Resource scope**: Namespace-scoped vs cluster-scoped resources
- **Commands**: Use `sur` (StagedUpdateRun) instead of `csur` (ClusterStagedUpdateRun)
- **Target resources**: `ResourcePlacement` instead of `ClusterResourcePlacement`
- **Bindings**: `resourcebindings` instead of `clusterresourcebindings`
- **Approvals**: `approvalrequests` instead of `clusterapprovalrequests`

### ResourcePlacement status without Staged Update Run

When a namespace-scoped `ResourcePlacement` is created with `spec.strategy.type` set to `External`, the rollout does not start immediately.

A sample status of such `ResourcePlacement` is as follows:

```yaml
$ kubectl describe rp web-app-placement -n my-app-namespace
...
Status:
  Conditions:
    Last Transition Time:  2026-01-08T20:24:59Z
    Message:               found all cluster needed as specified by the scheduling policy, found 2 cluster(s)
    Observed Generation:   1
    Reason:                SchedulingPolicyFulfilled
    Status:                True
    Type:                  ResourcePlacementScheduled
    Last Transition Time:  2026-01-08T20:24:59Z
    Message:               Rollout is controlled by an external controller and no resource snapshot name is observed across clusters, probably rollout has not started yet
    Observed Generation:   1
    Reason:                RolloutControlledByExternalController
    Status:                Unknown
    Type:                  ResourcePlacementRolloutStarted
  Placement Statuses:
    Cluster Name:  member1
    Conditions:
      Last Transition Time:  2026-01-08T20:24:59Z
      Message:               Successfully scheduled resources for placement in "member1" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2026-01-08T20:24:59Z
      Message:               In the process of deciding whether to roll out some version of the resources or not
      Observed Generation:   1
      Reason:                RolloutStartedUnknown
      Status:                Unknown
      Type:                  RolloutStarted
...
Events:         <none>
```

`SchedulingPolicyFulfilled` condition indicates the ResourcePlacement has been fully scheduled, while `ResourcePlacementRolloutStarted` condition shows that the rollout is unknown.

### Investigate StagedUpdateRun initialization failure

A namespace-scoped updateRun initialization failure can be easily detected by getting the resource:
```yaml
$ kubectl get sur web-app-rollout -n my-app-namespace
NAME              PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   SUCCEEDED   AGE
web-app-rollout   web-app-placement   1                         0                       False                     2s
```

The `INITIALIZED` field is `False`, indicating the initialization failed.

Describe the updateRun to get more details:
```yaml
$ kubectl describe sur web-app-rollout -n my-app-namespace
...
Status:
  Applied Strategy:
    Comparison Option:  PartialComparison
    Type:               ClientSideApply
    When To Apply:      Always
    When To Take Over:  Always
  Conditions:
    Last Transition Time:  2026-01-08T20:29:56Z
    Message:               cannot continue the updateRun: failed to validate the updateRun: failed to process the request due to a client error: no resourceSnapshots with index `1` found for placement `my-app-namespace/web-app-placement`
    Observed Generation:   1
    Reason:                UpdateRunInitializedFailed
    Status:                False
    Type:                  Initialized
  Deletion Stage Status:
    Clusters:
    Stage Name:                   kubernetes-fleet.io/deleteStage
  Policy Observed Cluster Count:  2
  Policy Snapshot Index Used:     0
...
```

The condition clearly indicates the initialization failed. The condition message gives more details about the failure.
In this case, a non-existing resource snapshot index `1` was used for the updateRun.

### Investigate StagedUpdateRun execution failure

A namespace-scoped updateRun execution failure can be easily detected by getting the resource:
```yaml
$ kubectl get sur web-app-rollout -n my-app-namespace
NAME              PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   SUCCEEDED   AGE
web-app-rollout   web-app-placement   0                         0                       True          False       24m
```

The `SUCCEEDED` field is `False`, indicating the execution failure.

The execution failure scenarios are similar to cluster-scoped updateRuns:

1. **Validation errors during reconciliation**: The updateRun controller validates the ResourcePlacement, gathers bindings, and regenerates the execution plan. If any failure occurs, the updateRun execution fails:
    ```yaml
    status:
      appliedStrategy:
        comparisonOption: PartialComparison
        type: ClientSideApply
        whenToApply: Always
        whenToTakeOver: Always
      conditions:
      - lastTransitionTime: "2026-01-08T20:53:11Z"
        message: The UpdateRun initialized successfully
        observedGeneration: 2
        reason: UpdateRunInitializedSuccessfully
        status: "True"
        type: Initialized
      - lastTransitionTime: "2026-01-08T20:54:12Z"
        message: The stages are aborted due to a non-recoverable error
        observedGeneration: 2
        reason: UpdateRunFailed
        status: "False"
        type: Progressing
      - lastTransitionTime: "2026-01-08T20:54:12Z"
        message: 'cannot continue the updateRun: failed to validate the updateRun: failed
          to process the request due to a client error: parent placement not found'
        observedGeneration: 2
        reason: UpdateRunFailed
        status: "False"
        type: Succeeded
    ```

2. **Concurrent updateRun preemption**: When multiple updateRuns target the same ResourcePlacement, they may conflict:
    ```yaml
    status:
      appliedStrategy:
        comparisonOption: PartialComparison
        type: ClientSideApply
        whenToApply: Always
        whenToTakeOver: Always
      conditions:
      - lastTransitionTime: "2026-01-08T21:18:35Z"
        message: The UpdateRun initialized successfully
        observedGeneration: 1
        reason: UpdateRunInitializedSuccessfully
        status: "True"
        type: Initialized
      - lastTransitionTime: "2026-01-08T21:18:50Z"
        message: The stages are aborted due to a non-recoverable error
        observedGeneration: 1
        reason: UpdateRunFailed
        status: "False"
        type: Progressing
      - lastTransitionTime: "2026-01-08T21:18:50Z"
        message: 'cannot continue the updateRun: failed to process the request due to
          a client error: the binding of the updating cluster `member2` in the
          stage `dev` is not up-to-date with the desired status, please check the status
          of binding `my-app-namespace/web-app-placement-member2-43991b15` and
          see if there is a concurrent updateRun referencing the same placement
          and updating the same cluster'
        observedGeneration: 1
        reason: UpdateRunFailed
        status: "False"
        type: Succeeded
    ```

   To investigate concurrent updateRuns, check the namespace-scoped resource bindings:
   ```yaml
   $ kubectl get resourcebindings -n my-app-namespace
   NAME                                 WORKSYNCHRONIZED   RESOURCESAPPLIED   AGE
   web-app-placement-member1-2afc7d7f                                         51m
   web-app-placement-member2-43991b15   True               True               51m
   ```

### Investigate StagedUpdateRun rollout stuck

A `StagedUpdateRun` can get stuck when resource placement fails on some clusters:
```yaml
$ kubectl get sur web-app-rollout -n my-app-namespace -o yaml
...
status:
  appliedStrategy:
    comparisonOption: PartialComparison
    type: ClientSideApply
    whenToApply: Always
    whenToTakeOver: Always
  conditions:
  - lastTransitionTime: "2026-01-08T22:39:51Z"
    message: The UpdateRun initialized successfully
    observedGeneration: 1
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
  - lastTransitionTime: "2026-01-08T22:45:34Z"
    message: The updateRun is stuck waiting for 1 cluster(s) in stage dev to finish
      updating, please check placement status for potential errors
    observedGeneration: 1
    reason: UpdateRunStuck
    status: "False"
    type: Progressing
...
```

To investigate further, check the `ResourcePlacement` status:
```yaml
$ kubectl describe rp web-app-placement -n my-app-namespace
...
 Placement Statuses:
    ...
    Cluster Name:              member2
    Conditions:
      Last Transition Time:  2026-01-08T22:34:44Z
      Message:               Successfully scheduled resources for placement in "member2" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2026-01-08T22:35:56Z
      Message:               Detected the new changes on the resources and started the rollout process, resourceSnapshotIndex: 1, updateRun: web-app-rollout-v1-21
      Observed Generation:   1
      Reason:                RolloutStarted
      Status:                True
      Type:                  RolloutStarted
      Last Transition Time:  2026-01-08T22:39:51Z
      Message:               No override rules are configured for the selected resources
      Observed Generation:   1
      Reason:                NoOverrideSpecified
      Status:                True
      Type:                  Overridden
      Last Transition Time:  2026-01-08T22:39:51Z
      Message:               All of the works are synchronized to the latest
      Observed Generation:   1
      Reason:                AllWorkSynced
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2026-01-08T22:39:51Z
      Message:               All corresponding work objects are applied
      Observed Generation:   1
      Reason:                AllWorkHaveBeenApplied
      Status:                True
      Type:                  Applied
      Last Transition Time:  2026-01-08T22:39:51Z
      Message:               Work object my-app-namespace.web-app-placement-work is not yet available
      Observed Generation:   1
      Reason:                NotAllWorkAreAvailable
      Status:                False
      Type:                  Available
    Failed Placements:
      Condition:
        Last Transition Time:  2026-01-08T22:39:51Z
        Message:               Manifest is not yet available; Fleet will check again later
        Observed Generation:   2
        Reason:                ManifestNotAvailableYet
        Status:                False
        Type:                  Available
      Group:                   apps
      Kind:                    Deployment
      Name:                    web-app
      Namespace:               my-app-namespace
      Version:                 v1
...
```

Check the target cluster to diagnose the specific issue:
```yaml
kubectl config use-context member2

kubectl get deploy web-app -n my-app-namespace
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
web-app   0/1     1            1           9m51s

kubectl get pods -n my-app-namespace
NAME                       READY   STATUS             RESTARTS   AGE
web-app-578cf755cd-rz2f4   0/1     InvalidImageName   0          9m51s
```

> Note: A similar scenario can occur when updateRun's state is set to `Stop` since we allow ongoing resource placement on a cluster to continue even when State is `Stop`.

### Namespace-Scoped Approval Troubleshooting

For namespace-scoped staged updates with approval gates, check for `ApprovalRequest` objects:

```yaml
# List approval requests in the namespace
$ kubectl get approvalrequests -n my-app-namespace
NAME                         UPDATE-RUN        STAGE   APPROVED   AGE
web-app-rollout-before-dev   web-app-rollout   dev     True       92s
```

Lets get the before stage approval request object,

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ApprovalRequest
metadata:
  creationTimestamp: "2026-01-09T02:31:57Z"
  generation: 1
  labels:
    kubernetes-fleet.io/isLatestUpdateRunApproval: "true"
    kubernetes-fleet.io/targetUpdateRun: web-app-rollout
    kubernetes-fleet.io/targetUpdatingStage: dev
    kubernetes-fleet.io/taskType: beforeStage
  name: web-app-rollout-before-dev
  namespace: my-app-namespace
  resourceVersion: "25386"
  uid: 6442e1ef-b694-4d59-8691-a3f5200c29ad
spec:
  parentStageRollout: web-app-rollout
  targetStage: dev
status:
  conditions:
  - lastTransitionTime: "2026-01-09T02:33:15Z"
    message: approved
    observedGeneration: 0
    reason: approved
    status: "True"
    type: Approved
```

The generation and observedGeneration don't match in this scenario.

Please refer to [Monitor namespace-scoped staged rollout](../how-tos/staged-update#monitor-namespace-scoped-staged-rollout) to approve the ApprovalRequest correctly.

After resolving issues, create a new updateRun to restart the rollout. Stuck updateRuns can be deleted safely.
