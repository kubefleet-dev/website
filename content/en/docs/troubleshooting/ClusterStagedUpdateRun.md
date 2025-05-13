---
title: ClusterStagedUpdateRun TSG
description: Identify and fix KubeFleet issues associated with the ClusterStagedUpdateRun API
weight: 9
---

This guide provides troubleshooting steps for common issues related to Staged Update Run.
> Note: To get more information about why the scheduling fails, you can check the [updateRun controller](https://github.com/kubefleet-dev/kubefleet/blob/main/pkg/controllers/updaterun/controller.go) logs.

## CRP status without Staged Update Run

When a `ClusterResourcePlacement` is created with `spec.strategy.type` set to `External`, the rollout does not start immediately.

A sample status of such `ClusterResourcePlacement` is as follows:

```bash
$ kubectl describe crp example-placement
...
Status:
  Conditions:
    Last Transition Time:   2025-03-12T23:01:32Z
    Message:                found all cluster needed as specified by the scheduling policy, found 2 cluster(s)
    Observed Generation:    1
    Reason:                 SchedulingPolicyFulfilled
    Status:                 True
    Type:                   ClusterResourcePlacementScheduled
    Last Transition Time:   2025-03-12T23:01:32Z
    Message:                There are still 2 cluster(s) in the process of deciding whether to roll out the latest resources or not
    Observed Generation:    1
    Reason:                 RolloutStartedUnknown
    Status:                 Unknown
    Type:                   ClusterResourcePlacementRolloutStarted
  Observed Resource Index:  0
  Placement Statuses:
    Cluster Name:  member1
    Conditions:
      Last Transition Time:  2025-03-12T23:01:32Z
      Message:               Successfully scheduled resources for placement in "member1" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2025-03-12T23:01:32Z
      Message:               In the process of deciding whether to roll out the latest resources or not
      Observed Generation:   1
      Reason:                RolloutStartedUnknown
      Status:                Unknown
      Type:                  RolloutStarted
    Cluster Name:            member2
    Conditions:
      Last Transition Time:  2025-03-12T23:01:32Z
      Message:               Successfully scheduled resources for placement in "member2" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2025-03-12T23:01:32Z
      Message:               In the process of deciding whether to roll out the latest resources or not
      Observed Generation:   1
      Reason:                RolloutStartedUnknown
      Status:                Unknown
      Type:                  RolloutStarted
  Selected Resources:
    ...
Events:         <none>
```

`SchedulingPolicyFulfilled` condition indicates the CRP has been fully scheduled, while `RolloutStartedUnknown` condition shows that the rollout has not started.

In the `Placement Statuses` section, it displays the detailed status of each cluster. Both selected clusters are in the `Scheduled` state, but the `RolloutStarted` condition is still `Unknown` because the rollout has not kicked off yet.

## Investigate ClusterStagedUpdateRun initialization failure

An updateRun initialization failure can be easily detected by getting the resource:
```bash
$ kubectl get csur example-run 
NAME          PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   SUCCEEDED   AGE
example-run   example-placement   1                         0                       False                     2s
```
The `INITIALIZED` field is `False`, indicating the initialization failed.

Describe the updateRun to get more details:
```bash
$ kubectl describe csur example-run
...
Status:
  Conditions:
    Last Transition Time:  2025-03-13T07:28:29Z
    Message:               cannot continue the ClusterStagedUpdateRun: failed to initialize the clusterStagedUpdateRun: failed to process the request due to a client error: no clusterResourceSnapshots with index `1` found for clusterResourcePlacement `example-placement`
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
The condition clearly indicates the initialization failed. And the condition message gives more details about the failure. 
In this case, I used a not-existing resource snapshot index `1` for the updateRun.

## Investigate ClusterStagedUpdateRun execution failure

An updateRun execution failure can be easily detected by getting the resource:
```bash
$ kubectl get csur example-run
NAME          PLACEMENT           RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   SUCCEEDED   AGE
example-run   example-placement   0                         0                       True          False       24m
```
The `SUCCEEDED` field is `False`, indicating the execution failure.

An updateRun execution failure can be caused by mainly 2 scenarios:  
1. When the updateRun controller is triggered to reconcile an in-progress updateRun, it starts by doing a bunch of validations 
including retrieving the CRP and checking its rollout strategy, gathering all the bindings and regenerating the execution plan.
If any failure happens during validation, the updateRun execution fails with the corresponding validation error.
   ```
   status:
     conditions:
     - lastTransitionTime: "2025-05-13T21:11:06Z"
       message: ClusterStagedUpdateRun initialized successfully
       observedGeneration: 1
       reason: UpdateRunInitializedSuccessfully
       status: "True"
       type: Initialized
     - lastTransitionTime: "2025-05-13T21:11:21Z"
       message: The stages are aborted due to a non-recoverable error
       observedGeneration: 1
       reason: UpdateRunFailed
       status: "False"
       type: Progressing
     - lastTransitionTime: "2025-05-13T22:15:23Z"
       message: 'cannot continue the ClusterStagedUpdateRun: failed to initialize the
         clusterStagedUpdateRun: failed to process the request due to a client error:
         parent clusterResourcePlacement not found'
       observedGeneration: 1
       reason: UpdateRunFailed
       status: "False"
       type: Succeeded
   ```
   In above case, the CRP referenced by the updateRun is deleted during the execution. The updateRun controller detects and aborts the release.
2. The updateRun controller triggers update to a member cluster by updating the corresponding binding spec and setting its 
status to `RolloutStarted`. It then waits for default 15 seconds and check whether the resources have been successfully applied 
by checking the binding again. In case that there are multiple concurrent updateRuns, and during the 15-second wait, some other
updateRun preempts and updates the binding with new configuration, current updateRun detects and fails with clear error message.
   ```
   status:
    conditions:
    - lastTransitionTime: "2025-05-13T21:10:58Z"
      message: ClusterStagedUpdateRun initialized successfully
      observedGeneration: 1
      reason: UpdateRunInitializedSuccessfully
      status: "True"
      type: Initialized
    - lastTransitionTime: "2025-05-13T21:11:13Z"
      message: The stages are aborted due to a non-recoverable error
      observedGeneration: 1
      reason: UpdateRunFailed
      status: "False"
      type: Progressing
    - lastTransitionTime: "2025-05-13T21:11:13Z"
      message: 'cannot continue the ClusterStagedUpdateRun: unexpected behavior which
        cannot be handled by the controller: the clusterResourceBinding of the updating
        cluster `member1` in the stage `staging` does not have expected status: binding
        spec diff: binding has different resourceSnapshotName, want: example-placement-0-snapshot,
        got: example-placement-1-snapshot; binding state (want Bound): Bound; binding
        RolloutStarted (want true): true, please check if there is concurrent clusterStagedUpdateRun'
      observedGeneration: 1
      reason: UpdateRunFailed
      status: "False"
      type: Succeeded
   ```
   The `Succeeded` condition is set to `False` with reason `UpdateRunFailed`. In the `message`, we show `member1` cluster in `staging` stage gets preempted, and the `resourceSnapshotName` field is changed from `example-placement-0-snapshot` to `example-placement-1-snapshot` which means probably some other updateRun is rolling out a newer resource version. The message also prints current binding state and if `RolloutStarted` condition is set to true. The message gives a hint about whether these is a concurrent clusterStagedUpdateRun running. Upon such failure, the user can list updateRuns or check the binding state:
   ```bash
   kubectl get clusterresourcebindings
   NAME                                 WORKSYNCHRONIZED   RESOURCESAPPLIED   AGE
   example-placement-member1-2afc7d7f   True               True               51m
   example-placement-member2-fc081413                                         51m
   ```
   The binding is named as `<crp-name>-<cluster-name>-<suffix>`. Since the error message says `member1` cluster fails the updateRun, we can check its binding:
   ```bash
   kubectl get clusterresourcebindings example-placement-member1-2afc7d7f -o yaml
   ...
   spec:
     ...
     resourceSnapshotName: example-placement-1-snapshot
     schedulingPolicySnapshotName: example-placement-0
     state: Bound
     targetCluster: member1
   status:
     conditions:
     - lastTransitionTime: "2025-05-13T21:11:06Z"
       message: 'Detected the new changes on the resources and started the rollout process,
         resourceSnapshotIndex: 1, clusterStagedUpdateRun: example-run-1'
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

## Investigate ClusterStagedUpdateRun rollout stuck

A `ClusterStagedUpdateRun` can get stuck when resource placement fails on some clusters. Getting the updateRun will show the cluster name and stage that is in stuck state:
```bash
$ kubectl get csur example-run -o yaml
...
status:
  conditions:
  - lastTransitionTime: "2025-05-13T23:15:35Z"
    message: ClusterStagedUpdateRun initialized successfully
    observedGeneration: 1
    reason: UpdateRunInitializedSuccessfully
    status: "True"
    type: Initialized
  - lastTransitionTime: "2025-05-13T23:21:18Z"
    message: The updateRun is stuck waiting for cluster member1 in stage staging to
      finish updating, please check crp status for potential errors
    observedGeneration: 1
    reason: UpdateRunStuck
    status: "False"
    type: Progressing
...
```
The message shows that the updateRun is stuck waiting for the cluster `member1` in stage `staging` to finish releasing.
The updateRun controller rolls resources to a member cluster by updating its corresponding binding. It then checks periodically
whether the update has completed or not. If the binding is still not available after current default 5 minutes, updateRun 
controller decides the rollout has stuck and reports the condition.

This usually indicates something wrong happened on the cluster or the resources have some issue. To further investigate, you can check the `ClusterResourcePlacement` status:
```bash
$ kubectl describe crp example-placement
...
 Placement Statuses:
    Cluster Name:  member1
    Conditions:
      Last Transition Time:  2025-05-13T23:11:14Z
      Message:               Successfully scheduled resources for placement in "member1" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2025-05-13T23:15:35Z
      Message:               Detected the new changes on the resources and started the rollout process, resourceSnapshotIndex: 0, clusterStagedUpdateRun: example-run
      Observed Generation:   1
      Reason:                RolloutStarted
      Status:                True
      Type:                  RolloutStarted
      Last Transition Time:  2025-05-13T23:15:35Z
      Message:               No override rules are configured for the selected resources
      Observed Generation:   1
      Reason:                NoOverrideSpecified
      Status:                True
      Type:                  Overridden
      Last Transition Time:  2025-05-13T23:15:35Z
      Message:               All of the works are synchronized to the latest
      Observed Generation:   1
      Reason:                AllWorkSynced
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2025-05-13T23:15:35Z
      Message:               All corresponding work objects are applied
      Observed Generation:   1
      Reason:                AllWorkHaveBeenApplied
      Status:                True
      Type:                  Applied
      Last Transition Time:  2025-05-13T23:15:35Z
      Message:               Work object example-placement-work-configmap-c5971133-2779-4f6f-8681-3e05c4458c82 is not yet available
      Observed Generation:   1
      Reason:                NotAllWorkAreAvailable
      Status:                False
      Type:                  Available
    Failed Placements:
      Condition:
        Last Transition Time:  2025-05-13T23:15:35Z
        Message:               Manifest is trackable but not available yet
        Observed Generation:   1
        Reason:                ManifestNotAvailableYet
        Status:                False
        Type:                  Available
      Envelope:
        Name:       envelope-nginx-deploy
        Namespace:  test-namespace
        Type:       ConfigMap
      Group:        apps
      Kind:         Deployment
      Name:         nginx
      Namespace:    test-namespace
      Version:      v1
...
```

The `Applied` condition is `False` and says not all work have been applied. And in the "failed placements" section, it shows
the `nginx` deployment wrapped by `envelope-nginx-deploy` configMap is not ready. Check from `member1` cluster and we can see
there's image pull failure:
```bash
kubectl config use-context member1

kubectl get deploy -n test-namespace
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   0/1     1            0           16m

kubectl get pods -n test-namespace
NAME                     READY   STATUS         RESTARTS   AGE
nginx-69b9cb5485-sw24b   0/1     ErrImagePull   0          16m
```

For more debugging instructions, you can refer to [ClusterResourcePlacement TSG](ClusterResourcePlacement).

After resolving the issue, you can create always create a new updateRun to restart the rollout. Stuck updateRuns can be deleted.
