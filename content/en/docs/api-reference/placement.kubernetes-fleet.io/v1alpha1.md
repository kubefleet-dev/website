---
title: API Reference
description: v1alpha1 Reference for placement.kubernetes-fleet.io KubeFleet APIs
weight: 9
---


## placement.kubernetes-fleet.io/v1alpha1


### Resource Types
- [ClusterApprovalRequest](#clusterapprovalrequest)
- [ClusterResourceOverride](#clusterresourceoverride)
- [ClusterResourceOverrideSnapshot](#clusterresourceoverridesnapshot)
- [ClusterResourcePlacementDisruptionBudget](#clusterresourceplacementdisruptionbudget)
- [ClusterResourcePlacementEviction](#clusterresourceplacementeviction)
- [ClusterStagedUpdateRun](#clusterstagedupdaterun)
- [ClusterStagedUpdateStrategy](#clusterstagedupdatestrategy)
- [ResourceOverride](#resourceoverride)
- [ResourceOverrideSnapshot](#resourceoverridesnapshot)



#### AfterStageTask



AfterStageTask is the collection of post-stage tasks that ALL need to be completed before moving to the next stage.



_Appears in:_
- [StageConfig](#stageconfig)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `type` _[AfterStageTaskType](#afterstagetasktype)_ | The type of the after-stage task. |  | Enum: [TimedWait Approval] <br />Required: \{\} <br /> |
| `waitTime` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#duration-v1-meta)_ | The time to wait after all the clusters in the current stage complete the update before moving to the next stage. |  | Optional: \{\} <br />Pattern: `^0\|([0-9]+(\.[0-9]+)?(s\|m\|h))+$` <br />Type: string <br /> |




#### AfterStageTaskStatus







_Appears in:_
- [StageUpdatingStatus](#stageupdatingstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `type` _[AfterStageTaskType](#afterstagetasktype)_ | The type of the post-update task. |  | Enum: [TimedWait Approval] <br />Required: \{\} <br /> |
| `approvalRequestName` _string_ | The name of the approval request object that is created for this stage.<br />Only valid if the AfterStageTaskType is Approval. |  | Optional: \{\} <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for the specific type of post-update task.<br />Known conditions are "ApprovalRequestCreated", "WaitTimeElapsed", and "ApprovalRequestApproved". |  | Optional: \{\} <br /> |


#### AfterStageTaskType

_Underlying type:_ _string_

AfterStageTaskType identifies a specific type of the AfterStageTask.



_Appears in:_
- [AfterStageTask](#afterstagetask)
- [AfterStageTaskStatus](#afterstagetaskstatus)

| Field | Description |
| --- | --- |
| `TimedWait` | AfterStageTaskTypeTimedWait indicates the post-stage task is a timed wait.<br /> |
| `Approval` | AfterStageTaskTypeApproval indicates the post-stage task is an approval.<br /> |




#### ApprovalRequestSpec



ApprovalRequestSpec defines the desired state of the update run approval request.
The entire spec is immutable.



_Appears in:_
- [ClusterApprovalRequest](#clusterapprovalrequest)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `parentStageRollout` _string_ | The name of the staged update run that this approval request is for. |  | Required: \{\} <br /> |
| `targetStage` _string_ | The name of the update stage that this approval request is for. |  | Required: \{\} <br /> |


#### ApprovalRequestStatus



ApprovalRequestStatus defines the observed state of the ClusterApprovalRequest.



_Appears in:_
- [ClusterApprovalRequest](#clusterapprovalrequest)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for the specific type of post-update task.<br />Known conditions are "Approved" and "ApprovalAccepted". |  | Optional: \{\} <br /> |


#### ClusterApprovalRequest



ClusterApprovalRequest defines a request for user approval for cluster staged update run.
The request object MUST have the following labels:
  - `TargetUpdateRun`: Points to the cluster staged update run that this approval request is for.
  - `TargetStage`: The name of the stage that this approval request is for.
  - `IsLatestUpdateRunApproval`: Indicates whether this approval request is the latest one related to this update run.



_Appears in:_
- [ClusterApprovalRequestList](#clusterapprovalrequestlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ClusterApprovalRequest` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ApprovalRequestSpec](#approvalrequestspec)_ | The desired state of ClusterApprovalRequest. |  | Required: \{\} <br /> |
| `status` _[ApprovalRequestStatus](#approvalrequeststatus)_ | The observed state of ClusterApprovalRequest. |  | Optional: \{\} <br /> |




#### ClusterResourceOverride



ClusterResourceOverride defines a group of override policies about how to override the selected cluster scope resources
to target clusters.



_Appears in:_
- [ClusterResourceOverrideList](#clusterresourceoverridelist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ClusterResourceOverride` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ClusterResourceOverrideSpec](#clusterresourceoverridespec)_ | The desired state of ClusterResourceOverrideSpec. |  |  |




#### ClusterResourceOverrideSnapshot



ClusterResourceOverrideSnapshot is used to store a snapshot of ClusterResourceOverride.
Its spec is immutable.
We assign an ever-increasing index for snapshots.
The naming convention of a ClusterResourceOverrideSnapshot is {ClusterResourceOverride}-{resourceIndex}.
resourceIndex will begin with 0.
Each snapshot MUST have the following labels:
  - `OverrideTrackingLabel` which points to its owner ClusterResourceOverride.
  - `IsLatestSnapshotLabel` which indicates whether the snapshot is the latest one.



_Appears in:_
- [ClusterResourceOverrideSnapshotList](#clusterresourceoverridesnapshotlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ClusterResourceOverrideSnapshot` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ClusterResourceOverrideSnapshotSpec](#clusterresourceoverridesnapshotspec)_ | The desired state of ClusterResourceOverrideSnapshotSpec. |  |  |




#### ClusterResourceOverrideSnapshotSpec



ClusterResourceOverrideSnapshotSpec defines the desired state of ClusterResourceOverride.



_Appears in:_
- [ClusterResourceOverrideSnapshot](#clusterresourceoverridesnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `overrideSpec` _[ClusterResourceOverrideSpec](#clusterresourceoverridespec)_ | OverrideSpec stores the spec of ClusterResourceOverride. |  |  |
| `overrideHash` _integer array_ | OverrideHash is the sha-256 hash value of the OverrideSpec field. |  |  |


#### ClusterResourceOverrideSpec



ClusterResourceOverrideSpec defines the desired state of the Override.
The ClusterResourceOverride create or update will fail when the resource has been selected by the existing ClusterResourceOverride.
If the resource is selected by both ClusterResourceOverride and ResourceOverride, ResourceOverride will win when resolving
conflicts.



_Appears in:_
- [ClusterResourceOverride](#clusterresourceoverride)
- [ClusterResourceOverrideSnapshotSpec](#clusterresourceoverridesnapshotspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `placement` _[PlacementRef](#placementref)_ | Placement defines whether the override is applied to a specific placement or not.<br />If set, the override will trigger the placement rollout immediately when the rollout strategy type is RollingUpdate.<br />Otherwise, it will be applied to the next rollout.<br />The recommended way is to set the placement so that the override can be rolled out immediately. |  |  |
| `clusterResourceSelectors` _[ClusterResourceSelector](#clusterresourceselector) array_ | ClusterResourceSelectors is an array of selectors used to select cluster scoped resources. The selectors are `ORed`.<br />If a namespace is selected, ALL the resources under the namespace are selected automatically.<br />LabelSelector is not supported.<br />You can have 1-20 selectors.<br />We only support Name selector for now. |  | MaxItems: 20 <br />MinItems: 1 <br />Required: \{\} <br /> |
| `policy` _[OverridePolicy](#overridepolicy)_ | Policy defines how to override the selected resources on the target clusters. |  |  |


#### ClusterResourcePlacementDisruptionBudget



ClusterResourcePlacementDisruptionBudget is the policy applied to a ClusterResourcePlacement
object that specifies its disruption budget, i.e., how many placements (clusters) can be
down at the same time due to voluntary disruptions (e.g., evictions). Involuntary
disruptions are not subject to this budget, but will still count against it.


To apply a ClusterResourcePlacementDisruptionBudget to a ClusterResourcePlacement, use the
same name for the ClusterResourcePlacementDisruptionBudget object as the ClusterResourcePlacement
object. This guarantees a 1:1 link between the two objects.



_Appears in:_
- [ClusterResourcePlacementDisruptionBudgetList](#clusterresourceplacementdisruptionbudgetlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ClusterResourcePlacementDisruptionBudget` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[PlacementDisruptionBudgetSpec](#placementdisruptionbudgetspec)_ | Spec is the desired state of the ClusterResourcePlacementDisruptionBudget. |  |  |




#### ClusterResourcePlacementEviction



ClusterResourcePlacementEviction is an eviction attempt on a specific placement from
a ClusterResourcePlacement object; one may use this API to force the removal of specific
resources from a cluster.


An eviction is a voluntary disruption; its execution is subject to the disruption budget
linked with the target ClusterResourcePlacement object (if present).


Beware that an eviction alone does not guarantee that a placement will not re-appear; i.e.,
after an eviction, the Fleet scheduler might still pick the previous target cluster for
placement. To prevent this, considering adding proper taints to the target cluster before running
an eviction that will exclude it from future placements; this is especially true in scenarios
where one would like to perform a cluster replacement.


For safety reasons, Fleet will only execute an eviction once; the spec in this object is immutable,
and once executed, the object will be ignored after. To trigger another eviction attempt on the
same placement from the same ClusterResourcePlacement object, one must re-create (delete and
create) the same Eviction object. Note also that an Eviction object will be
ignored once it is deemed invalid (e.g., such an object might be targeting a CRP object or
a placement that does not exist yet), even if it does become valid later
(e.g., the CRP object or the placement appears later). To fix the situation, re-create the
Eviction object.


Note: Eviction of resources from a cluster propagated by a PickFixed CRP is not allowed.
If the user wants to remove resources from a cluster propagated by a PickFixed CRP simply
remove the cluster name from cluster names field from the CRP spec.


Executed evictions might be kept around for a while for auditing purposes; the Fleet controllers might
have a TTL set up for such objects and will garbage collect them automatically. For further
information, see the Fleet documentation.



_Appears in:_
- [ClusterResourcePlacementEvictionList](#clusterresourceplacementevictionlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ClusterResourcePlacementEviction` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[PlacementEvictionSpec](#placementevictionspec)_ | Spec is the desired state of the ClusterResourcePlacementEviction.<br /><br />Note that all fields in the spec are immutable. |  |  |
| `status` _[PlacementEvictionStatus](#placementevictionstatus)_ | Status is the observed state of the ClusterResourcePlacementEviction. |  |  |




#### ClusterStagedUpdateRun



ClusterStagedUpdateRun represents a stage by stage update process that applies ClusterResourcePlacement
selected resources to specified clusters.
Resources from unselected clusters are removed after all stages in the update strategy are completed.
Each ClusterStagedUpdateRun object corresponds to a single release of a specific resource version.
The release is abandoned if the ClusterStagedUpdateRun object is deleted or the scheduling decision changes.
The name of the ClusterStagedUpdateRun must conform to RFC 1123.



_Appears in:_
- [ClusterStagedUpdateRunList](#clusterstagedupdaterunlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ClusterStagedUpdateRun` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[StagedUpdateRunSpec](#stagedupdaterunspec)_ | The desired state of ClusterStagedUpdateRun. The spec is immutable. |  | Required: \{\} <br /> |
| `status` _[StagedUpdateRunStatus](#stagedupdaterunstatus)_ | The observed status of ClusterStagedUpdateRun. |  | Optional: \{\} <br /> |




#### ClusterStagedUpdateStrategy



ClusterStagedUpdateStrategy defines a reusable strategy that specifies the stages and the sequence
in which the selected cluster resources will be updated on the member clusters.



_Appears in:_
- [ClusterStagedUpdateStrategyList](#clusterstagedupdatestrategylist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ClusterStagedUpdateStrategy` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[StagedUpdateStrategySpec](#stagedupdatestrategyspec)_ | The desired state of ClusterStagedUpdateStrategy. |  | Required: \{\} <br /> |




#### ClusterUpdatingStatus



ClusterUpdatingStatus defines the status of the update run on a cluster.



_Appears in:_
- [StageUpdatingStatus](#stageupdatingstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterName` _string_ | The name of the cluster. |  | Required: \{\} <br /> |
| `resourceOverrideSnapshots` _[NamespacedName](#namespacedname) array_ | ResourceOverrideSnapshots is a list of ResourceOverride snapshots associated with the cluster.<br />The list is computed at the beginning of the update run and not updated during the update run.<br />The list is empty if there are no resource overrides associated with the cluster. |  | Optional: \{\} <br /> |
| `clusterResourceOverrideSnapshots` _string array_ | ClusterResourceOverrides contains a list of applicable ClusterResourceOverride snapshot names<br />associated with the cluster.<br />The list is computed at the beginning of the update run and not updated during the update run.<br />The list is empty if there are no cluster overrides associated with the cluster. |  | Optional: \{\} <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for clusters. Empty if the cluster has not started updating.<br />Known conditions are "Started", "Succeeded". |  | Optional: \{\} <br /> |




#### JSONPatchOverride



JSONPatchOverride applies a JSON patch on the selected resources following [RFC 6902](https://datatracker.ietf.org/doc/html/rfc6902).



_Appears in:_
- [OverrideRule](#overriderule)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `op` _[JSONPatchOverrideOperator](#jsonpatchoverrideoperator)_ | Operator defines the operation on the target field. |  | Enum: [add remove replace] <br /> |
| `path` _string_ | Path defines the target location.<br />Note: override will fail if the resource path does not exist. |  |  |
| `value` _[JSON](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#json-v1-apiextensions-k8s-io)_ | Value defines the content to be applied on the target location.<br />Value should be empty when operator is `remove`.<br />We have reserved a few variables in this field that will be replaced by the actual values.<br />Those variables all start with `$` and are case sensitive.<br />Here is the list of currently supported variables:<br />`$\{MEMBER-CLUSTER-NAME\}`:  this will be replaced by the name of the memberCluster CR that represents this cluster. |  |  |


#### JSONPatchOverrideOperator

_Underlying type:_ _string_

JSONPatchOverrideOperator defines the supported JSON patch operator.



_Appears in:_
- [JSONPatchOverride](#jsonpatchoverride)

| Field | Description |
| --- | --- |
| `add` | JSONPatchOverrideOpAdd adds the value to the target location.<br />An example target JSON document:<br />  \{ "foo": [ "bar", "baz" ] \}<br />  A JSON Patch override:<br />  [<br />    \{ "op": "add", "path": "/foo/1", "value": "qux" \}<br />  ]<br />  The resulting JSON document:<br />  \{ "foo": [ "bar", "qux", "baz" ] \}<br /> |
| `remove` | JSONPatchOverrideOpRemove removes the value from the target location.<br />An example target JSON document:<br />  \{<br />    "baz": "qux",<br />    "foo": "bar"<br />  \}<br />  A JSON Patch override:<br />  [<br />    \{ "op": "remove", "path": "/baz" \}<br />  ]<br />  The resulting JSON document:<br />  \{ "foo": "bar" \}<br /> |
| `replace` | JSONPatchOverrideOpReplace replaces the value at the target location with a new value.<br />An example target JSON document:<br />  \{<br />    "baz": "qux",<br />    "foo": "bar"<br />  \}<br />  A JSON Patch override:<br />  [<br />    \{ "op": "replace", "path": "/baz", "value": "boo" \}<br />  ]<br />  The resulting JSON document:<br />  \{<br />    "baz": "boo",<br />    "foo": "bar"<br />  \}<br /> |


#### OverridePolicy



OverridePolicy defines how to override the selected resources on the target clusters.
More is to be added.



_Appears in:_
- [ClusterResourceOverrideSpec](#clusterresourceoverridespec)
- [ResourceOverrideSpec](#resourceoverridespec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `overrideRules` _[OverrideRule](#overriderule) array_ | OverrideRules defines an array of override rules to be applied on the selected resources.<br />The order of the rules determines the override order.<br />When there are two rules selecting the same fields on the target cluster, the last one will win.<br />You can have 1-20 rules. |  | MaxItems: 20 <br />MinItems: 1 <br />Required: \{\} <br /> |


#### OverrideRule



OverrideRule defines how to override the selected resources on the target clusters.



_Appears in:_
- [OverridePolicy](#overridepolicy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterSelector` _[ClusterSelector](#clusterselector)_ | ClusterSelectors selects the target clusters.<br />The resources will be overridden before applying to the matching clusters.<br />An empty clusterSelector selects ALL the member clusters.<br />A nil clusterSelector selects NO member clusters.<br />For now, only labelSelector is supported. |  |  |
| `overrideType` _[OverrideType](#overridetype)_ | OverrideType defines the type of the override rules. | JSONPatch | Enum: [JSONPatch Delete] <br /> |
| `jsonPatchOverrides` _[JSONPatchOverride](#jsonpatchoverride) array_ | JSONPatchOverrides defines a list of JSON patch override rules.<br />This field is only allowed when OverrideType is JSONPatch. |  | MaxItems: 20 <br />MinItems: 1 <br /> |


#### OverrideType

_Underlying type:_ _string_

OverrideType defines the type of Override



_Appears in:_
- [OverrideRule](#overriderule)

| Field | Description |
| --- | --- |
| `JSONPatch` | JSONPatchOverrideType applies a JSON patch on the selected resources following [RFC 6902](https://datatracker.ietf.org/doc/html/rfc6902).<br /> |
| `Delete` | DeleteOverrideType deletes the selected resources on the target clusters.<br /> |


#### PlacementDisruptionBudgetSpec



PlacementDisruptionBudgetSpec is the desired state of the PlacementDisruptionBudget.



_Appears in:_
- [ClusterResourcePlacementDisruptionBudget](#clusterresourceplacementdisruptionbudget)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `maxUnavailable` _[IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#intorstring-intstr-util)_ | MaxUnavailable is the maximum number of placements (clusters) that can be down at the<br />same time due to voluntary disruptions. For example, a setting of 1 would imply that<br />a voluntary disruption (e.g., an eviction) can only happen if all placements (clusters)<br />from the linked Placement object are applied and available.<br /><br />This can be either an absolute value (e.g., 1) or a percentage (e.g., 10%).<br /><br />If a percentage is specified, Fleet will calculate the corresponding absolute values<br />as follows:<br />* if the linked Placement object is of the PickFixed placement type,<br />  we don't perform any calculation because eviction is not allowed for PickFixed CRP.<br />* if the linked Placement object is of the PickAll placement type, MaxUnavailable cannot<br />  be specified since we cannot derive the total number of clusters selected.<br />* if the linked Placement object is of the PickN placement type,<br />  the percentage is against the number of clusters specified in the placement (i.e., the<br />  value of the NumberOfClusters fields in the placement policy).<br />The end result will be rounded up to the nearest integer if applicable.<br /><br />One may use a value of 0 for this field; in this case, no voluntary disruption would be<br />allowed.<br /><br />This field is mutually exclusive with the MinAvailable field in the spec; exactly one<br />of them can be set at a time. |  | XIntOrString: \{\} <br /> |
| `minAvailable` _[IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#intorstring-intstr-util)_ | MinAvailable is the minimum number of placements (clusters) that must be available at any<br />time despite voluntary disruptions. For example, a setting of 10 would imply that<br />a voluntary disruption (e.g., an eviction) can only happen if there are at least 11<br />placements (clusters) from the linked Placement object are applied and available.<br /><br />This can be either an absolute value (e.g., 1) or a percentage (e.g., 10%).<br /><br />If a percentage is specified, Fleet will calculate the corresponding absolute values<br />as follows:<br />* if the linked Placement object is of the PickFixed placement type,<br />  we don't perform any calculation because eviction is not allowed for PickFixed CRP.<br />* if the linked Placement object is of the PickAll placement type, MinAvailable can be<br />  specified but only as an integer since we cannot derive the total number of clusters selected.<br />* if the linked Placement object is of the PickN placement type,<br />  the percentage is against the number of clusters specified in the placement (i.e., the<br />  value of the NumberOfClusters fields in the placement policy).<br />The end result will be rounded up to the nearest integer if applicable.<br /><br />One may use a value of 0 for this field; in this case, voluntary disruption would be<br />allowed at any time.<br /><br />This field is mutually exclusive with the MaxUnavailable field in the spec; exactly one<br />of them can be set at a time. |  | XIntOrString: \{\} <br /> |




#### PlacementEvictionSpec



PlacementEvictionSpec is the desired state of the parent PlacementEviction.



_Appears in:_
- [ClusterResourcePlacementEviction](#clusterresourceplacementeviction)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `placementName` _string_ | PlacementName is the name of the Placement object which<br />the Eviction object targets. |  | MaxLength: 255 <br />Required: \{\} <br /> |
| `clusterName` _string_ | ClusterName is the name of the cluster that the Eviction object targets. |  | MaxLength: 255 <br />Required: \{\} <br /> |


#### PlacementEvictionStatus



PlacementEvictionStatus is the observed state of the parent PlacementEviction.



_Appears in:_
- [ClusterResourcePlacementEviction](#clusterresourceplacementeviction)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is the list of currently observed conditions for the<br />PlacementEviction object.<br /><br />Available condition types include:<br />* Valid: whether the Eviction object is valid, i.e., it targets at a valid placement.<br />* Executed: whether the Eviction object has been executed. |  |  |


#### PlacementRef



PlacementRef is the reference to a placement.
For now, we only support ClusterResourcePlacement.



_Appears in:_
- [ClusterResourceOverrideSpec](#clusterresourceoverridespec)
- [ResourceOverrideSpec](#resourceoverridespec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | Name is the reference to the name of placement. |  |  |


#### ResourceOverride



ResourceOverride defines a group of override policies about how to override the selected namespaced scope resources
to target clusters.



_Appears in:_
- [ResourceOverrideList](#resourceoverridelist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ResourceOverride` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ResourceOverrideSpec](#resourceoverridespec)_ | The desired state of ResourceOverrideSpec. |  |  |




#### ResourceOverrideSnapshot



ResourceOverrideSnapshot is used to store a snapshot of ResourceOverride.
Its spec is immutable.
We assign an ever-increasing index for snapshots.
The naming convention of a ResourceOverrideSnapshot is {ResourceOverride}-{resourceIndex}.
resourceIndex will begin with 0.
Each snapshot MUST have the following labels:
  - `OverrideTrackingLabel` which points to its owner ResourceOverride.
  - `IsLatestSnapshotLabel` which indicates whether the snapshot is the latest one.



_Appears in:_
- [ResourceOverrideSnapshotList](#resourceoverridesnapshotlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1alpha1` | | |
| `kind` _string_ | `ResourceOverrideSnapshot` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ResourceOverrideSnapshotSpec](#resourceoverridesnapshotspec)_ | The desired state of ResourceOverrideSnapshot. |  |  |




#### ResourceOverrideSnapshotSpec



ResourceOverrideSnapshotSpec defines the desired state of ResourceOverride.



_Appears in:_
- [ResourceOverrideSnapshot](#resourceoverridesnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `overrideSpec` _[ResourceOverrideSpec](#resourceoverridespec)_ | OverrideSpec stores the spec of ResourceOverride. |  |  |
| `overrideHash` _integer array_ | OverrideHash is the sha-256 hash value of the OverrideSpec field. |  |  |


#### ResourceOverrideSpec



ResourceOverrideSpec defines the desired state of the Override.
The ResourceOverride create or update will fail when the resource has been selected by the existing ResourceOverride.
If the resource is selected by both ClusterResourceOverride and ResourceOverride, ResourceOverride will win when resolving
conflicts.



_Appears in:_
- [ResourceOverride](#resourceoverride)
- [ResourceOverrideSnapshotSpec](#resourceoverridesnapshotspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `placement` _[PlacementRef](#placementref)_ | Placement defines whether the override is applied to a specific placement or not.<br />If set, the override will trigger the placement rollout immediately when the rollout strategy type is RollingUpdate.<br />Otherwise, it will be applied to the next rollout.<br />The recommended way is to set the placement so that the override can be rolled out immediately. |  |  |
| `resourceSelectors` _[ResourceSelector](#resourceselector) array_ | ResourceSelectors is an array of selectors used to select namespace scoped resources. The selectors are `ORed`.<br />You can have 1-20 selectors. |  | MaxItems: 20 <br />MinItems: 1 <br />Required: \{\} <br /> |
| `policy` _[OverridePolicy](#overridepolicy)_ | Policy defines how to override the selected resources on the target clusters. |  |  |


#### ResourceSelector



ResourceSelector is used to select namespace scoped resources as the target resources to be placed.
All the fields are `ANDed`. In other words, a resource must match all the fields to be selected.
The resource namespace will inherit from the parent object scope.



_Appears in:_
- [ResourceOverrideSpec](#resourceoverridespec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group name of the namespace-scoped resource.<br />Use an empty string to select resources under the core API group (e.g., services). |  |  |
| `version` _string_ | Version of the namespace-scoped resource. |  |  |
| `kind` _string_ | Kind of the namespace-scoped resource. |  |  |
| `name` _string_ | Name of the namespace-scoped resource. |  |  |


#### StageConfig



StageConfig describes a single update stage.
The clusters in each stage are updated sequentially.
The update stops if any of the updates fail.



_Appears in:_
- [StagedUpdateStrategySpec](#stagedupdatestrategyspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | The name of the stage. This MUST be unique within the same StagedUpdateStrategy. |  | MaxLength: 63 <br />Pattern: `^[a-z0-9]+$` <br />Required: \{\} <br /> |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#labelselector-v1-meta)_ | LabelSelector is a label query over all the joined member clusters. Clusters matching the query are selected<br />for this stage. There cannot be overlapping clusters between stages when the stagedUpdateRun is created.<br />If the label selector is absent, the stage includes all the selected clusters. |  | Optional: \{\} <br /> |
| `sortingLabelKey` _string_ | The label key used to sort the selected clusters.<br />The clusters within the stage are updated sequentially following the rule below:<br />  - primary: Ascending order based on the value of the label key, interpreted as integers if present.<br />  - secondary: Ascending order based on the name of the cluster if the label key is absent or the label value is the same. |  | Optional: \{\} <br /> |
| `afterStageTasks` _[AfterStageTask](#afterstagetask) array_ | The collection of tasks that each stage needs to complete successfully before moving to the next stage.<br />Each task is executed in parallel and there cannot be more than one task of the same type. |  | MaxItems: 2 <br />Optional: \{\} <br /> |




#### StageUpdatingStatus



StageUpdatingStatus defines the status of the update run in a stage.



_Appears in:_
- [StagedUpdateRunStatus](#stagedupdaterunstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `stageName` _string_ | The name of the stage. |  | Required: \{\} <br /> |
| `clusters` _[ClusterUpdatingStatus](#clusterupdatingstatus) array_ | The list of each cluster's updating status in this stage. |  | Required: \{\} <br /> |
| `afterStageTaskStatus` _[AfterStageTaskStatus](#afterstagetaskstatus) array_ | The status of the post-update tasks associated with the current stage.<br />Empty if the stage has not finished updating all the clusters. |  | MaxItems: 2 <br />Optional: \{\} <br /> |
| `startTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | The time when the update started on the stage. Empty if the stage has not started updating. |  | Format: date-time <br />Optional: \{\} <br />Type: string <br /> |
| `endTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | The time when the update finished on the stage. Empty if the stage has not started updating. |  | Format: date-time <br />Optional: \{\} <br />Type: string <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed updating conditions for the stage. Empty if the stage has not started updating.<br />Known conditions are "Progressing", "Succeeded". |  | Optional: \{\} <br /> |




#### StagedUpdateRunSpec



StagedUpdateRunSpec defines the desired rollout strategy and the snapshot indices of the resources to be updated.
It specifies a stage-by-stage update process across selected clusters for the given ResourcePlacement object.



_Appears in:_
- [ClusterStagedUpdateRun](#clusterstagedupdaterun)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `placementName` _string_ | PlacementName is the name of placement that this update run is applied to.<br />There can be multiple active update runs for each placement, but<br />it's up to the DevOps team to ensure they don't conflict with each other. |  | MaxLength: 255 <br />Required: \{\} <br /> |
| `resourceSnapshotIndex` _string_ | The resource snapshot index of the selected resources to be updated across clusters.<br />The index represents a group of resource snapshots that includes all the resources a ResourcePlacement selected. |  | Required: \{\} <br /> |
| `stagedRolloutStrategyName` _string_ | The name of the update strategy that specifies the stages and the sequence<br />in which the selected resources will be updated on the member clusters. The stages<br />are computed according to the referenced strategy when the update run starts<br />and recorded in the status field. |  | Required: \{\} <br /> |


#### StagedUpdateRunStatus



StagedUpdateRunStatus defines the observed state of the ClusterStagedUpdateRun.



_Appears in:_
- [ClusterStagedUpdateRun](#clusterstagedupdaterun)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `policySnapshotIndexUsed` _string_ | PolicySnapShotIndexUsed records the policy snapshot index of the ClusterResourcePlacement (CRP) that<br />the update run is based on. The index represents the latest policy snapshot at the start of the update run.<br />If a newer policy snapshot is detected after the run starts, the staged update run is abandoned.<br />The scheduler must identify all clusters that meet the current policy before the update run begins.<br />All clusters involved in the update run are selected from the list of clusters scheduled by the CRP according<br />to the current policy. |  | Optional: \{\} <br /> |
| `policyObservedClusterCount` _integer_ | PolicyObservedClusterCount records the number of observed clusters in the policy snapshot.<br />It is recorded at the beginning of the update run from the policy snapshot object.<br />If the `ObservedClusterCount` value is updated during the update run, the update run is abandoned. |  | Optional: \{\} <br /> |
| `appliedStrategy` _[ApplyStrategy](#applystrategy)_ | ApplyStrategy is the apply strategy that the stagedUpdateRun is using.<br />It is the same as the apply strategy in the CRP when the staged update run starts.<br />The apply strategy is not updated during the update run even if it changes in the CRP. |  | Optional: \{\} <br /> |
| `stagedUpdateStrategySnapshot` _[StagedUpdateStrategySpec](#stagedupdatestrategyspec)_ | StagedUpdateStrategySnapshot is the snapshot of the StagedUpdateStrategy used for the update run.<br />The snapshot is immutable during the update run.<br />The strategy is applied to the list of clusters scheduled by the CRP according to the current policy.<br />The update run fails to initialize if the strategy fails to produce a valid list of stages where each selected<br />cluster is included in exactly one stage. |  | Optional: \{\} <br /> |
| `stagesStatus` _[StageUpdatingStatus](#stageupdatingstatus) array_ | StagesStatus lists the current updating status of each stage.<br />The list is empty if the update run is not started or failed to initialize. |  | Optional: \{\} <br /> |
| `deletionStageStatus` _[StageUpdatingStatus](#stageupdatingstatus)_ | DeletionStageStatus lists the current status of the deletion stage. The deletion stage<br />removes all the resources from the clusters that are not selected by the<br />current policy after all the update stages are completed. |  | Optional: \{\} <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for StagedUpdateRun.<br />Known conditions are "Initialized", "Progressing", "Succeeded". |  | Optional: \{\} <br /> |


#### StagedUpdateStrategySpec



StagedUpdateStrategySpec defines the desired state of the StagedUpdateStrategy.



_Appears in:_
- [ClusterStagedUpdateStrategy](#clusterstagedupdatestrategy)
- [StagedUpdateRunStatus](#stagedupdaterunstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `stages` _[StageConfig](#stageconfig) array_ | Stage specifies the configuration for each update stage. |  | MaxItems: 31 <br />Required: \{\} <br /> |
