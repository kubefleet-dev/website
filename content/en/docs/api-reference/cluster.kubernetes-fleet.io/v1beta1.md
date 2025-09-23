---
title: API Reference
description: v1beta1 Reference for cluster.kubernetes-fleet.io KubeFleet APIs
weight: 9
---


## cluster.kubernetes-fleet.io/v1beta1



### Resource Types
- [InternalMemberCluster](#internalmembercluster)
- [InternalMemberClusterList](#internalmemberclusterlist)
- [MemberCluster](#membercluster)
- [MemberClusterList](#memberclusterlist)





#### AgentStatus



AgentStatus defines the observed status of the member agent of the given type.



_Appears in:_
- [InternalMemberClusterStatus](#internalmemberclusterstatus)
- [MemberClusterStatus](#memberclusterstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `type` _[AgentType](#agenttype)_ | Type of the member agent. |  |  |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for the member agent. |  |  |
| `lastReceivedHeartbeat` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | Last time we received a heartbeat from the member agent. |  |  |


#### AgentType

_Underlying type:_ _string_

AgentType defines a type of agent/binary running in a member cluster.



_Appears in:_
- [AgentStatus](#agentstatus)

| Field | Description |
| --- | --- |
| `MemberAgent` | MemberAgent (core) handles member cluster joining/leaving as well as k8s object placement from hub to member clusters.<br /> |
| `MultiClusterServiceAgent` | MultiClusterServiceAgent (networking) is responsible for exposing multi-cluster services via L4 load<br />balancer.<br /> |
| `ServiceExportImportAgent` | ServiceExportImportAgent (networking) is responsible for export or import services across multi-clusters.<br /> |


#### ClusterState

_Underlying type:_ _string_





_Appears in:_
- [InternalMemberClusterSpec](#internalmemberclusterspec)

| Field | Description |
| --- | --- |
| `Join` |  |
| `Leave` |  |






#### InternalMemberCluster



InternalMemberCluster is used by hub agent to notify the member agents about the member cluster state changes, and is used by the member agents to report their status.



_Appears in:_
- [InternalMemberClusterList](#internalmemberclusterlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `InternalMemberCluster` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[InternalMemberClusterSpec](#internalmemberclusterspec)_ | The desired state of InternalMemberCluster. |  |  |
| `status` _[InternalMemberClusterStatus](#internalmemberclusterstatus)_ | The observed status of InternalMemberCluster. |  |  |


#### InternalMemberClusterList



InternalMemberClusterList contains a list of InternalMemberCluster.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `InternalMemberClusterList` | | |
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `items` _[InternalMemberCluster](#internalmembercluster) array_ |  |  |  |


#### InternalMemberClusterSpec



InternalMemberClusterSpec defines the desired state of InternalMemberCluster. Set by the hub agent.



_Appears in:_
- [InternalMemberCluster](#internalmembercluster)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `state` _[ClusterState](#clusterstate)_ | The desired state of the member cluster. Possible values: Join, Leave. |  |  |
| `heartbeatPeriodSeconds` _integer_ | How often (in seconds) for the member cluster to send a heartbeat to the hub cluster. Default: 60 seconds. Min: 1 second. Max: 10 minutes. | 60 | Maximum: 600 <br />Minimum: 1 <br /> |


#### InternalMemberClusterStatus



InternalMemberClusterStatus defines the observed state of InternalMemberCluster.



_Appears in:_
- [InternalMemberCluster](#internalmembercluster)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for the member cluster. |  |  |
| `properties` _object (keys:[PropertyName](#propertyname), values:[PropertyValue](#propertyvalue))_ | Properties is an array of properties observed for the member cluster.<br /><br />This field is beta-level; it is for the property-based scheduling feature and is only<br />populated when a property provider is enabled in the deployment. |  |  |
| `resourceUsage` _[ResourceUsage](#resourceusage)_ | The current observed resource usage of the member cluster. It is populated by the member agent. |  |  |
| `agentStatus` _[AgentStatus](#agentstatus) array_ | AgentStatus is an array of current observed status, each corresponding to one member agent running in the member cluster. |  |  |


#### MemberCluster



MemberCluster is a resource created in the hub cluster to represent a member cluster within a fleet.



_Appears in:_
- [MemberClusterList](#memberclusterlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `MemberCluster` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[MemberClusterSpec](#memberclusterspec)_ | The desired state of MemberCluster. |  |  |
| `status` _[MemberClusterStatus](#memberclusterstatus)_ | The observed status of MemberCluster. |  |  |




#### MemberClusterList



MemberClusterList contains a list of MemberCluster.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `MemberClusterList` | | |
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `items` _[MemberCluster](#membercluster) array_ |  |  |  |


#### MemberClusterSpec



MemberClusterSpec defines the desired state of MemberCluster.



_Appears in:_
- [MemberCluster](#membercluster)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `identity` _[Subject](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#subject-v1-rbac)_ | The identity used by the member cluster to access the hub cluster.<br />The hub agents deployed on the hub cluster will automatically grant the minimal required permissions to this identity for the member agents deployed on the member cluster to access the hub cluster. |  |  |
| `heartbeatPeriodSeconds` _integer_ | How often (in seconds) for the member cluster to send a heartbeat to the hub cluster. Default: 60 seconds. Min: 1 second. Max: 10 minutes. | 60 | Maximum: 600 <br />Minimum: 1 <br /> |
| `taints` _[Taint](#taint) array_ | If specified, the MemberCluster's taints.<br /><br />This field is beta-level and is for the taints and tolerations feature. |  | MaxItems: 100 <br /> |


#### MemberClusterStatus



MemberClusterStatus defines the observed status of MemberCluster.



_Appears in:_
- [MemberCluster](#membercluster)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for the member cluster. |  |  |
| `properties` _object (keys:[PropertyName](#propertyname), values:[PropertyValue](#propertyvalue))_ | Properties is an array of properties observed for the member cluster.<br /><br />This field is beta-level; it is for the property-based scheduling feature and is only<br />populated when a property provider is enabled in the deployment. |  |  |
| `resourceUsage` _[ResourceUsage](#resourceusage)_ | The current observed resource usage of the member cluster. It is copied from the corresponding InternalMemberCluster object. |  |  |
| `agentStatus` _[AgentStatus](#agentstatus) array_ | AgentStatus is an array of current observed status, each corresponding to one member agent running in the member cluster. |  |  |


#### PropertyName

_Underlying type:_ _string_

PropertyName is the name of a cluster property; it should be a Kubernetes label name.



_Appears in:_
- [InternalMemberClusterStatus](#internalmemberclusterstatus)
- [MemberClusterStatus](#memberclusterstatus)



#### PropertyValue



PropertyValue is the value of a cluster property.



_Appears in:_
- [InternalMemberClusterStatus](#internalmemberclusterstatus)
- [MemberClusterStatus](#memberclusterstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `value` _string_ | Value is the value of the cluster property.<br /><br />Currently, it should be a valid Kubernetes quantity.<br />For more information, see<br />https://pkg.go.dev/k8s.io/apimachinery/pkg/api/resource#Quantity. |  |  |
| `observationTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | ObservationTime is when the cluster property is observed. |  |  |


#### ResourceUsage



ResourceUsage contains the observed resource usage of a member cluster.



_Appears in:_
- [InternalMemberClusterStatus](#internalmemberclusterstatus)
- [MemberClusterStatus](#memberclusterstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `capacity` _[ResourceList](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#resourcelist-v1-core)_ | Capacity represents the total resource capacity of all the nodes on a member cluster.<br /><br />A node's total capacity is the amount of resource installed on the node. |  |  |
| `allocatable` _[ResourceList](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#resourcelist-v1-core)_ | Allocatable represents the total allocatable resources of all the nodes on a member cluster.<br /><br />A node's allocatable capacity is the amount of resource that can actually be used<br />for user workloads, i.e.,<br />allocatable capacity = total capacity - capacities reserved for the OS, kubelet, etc.<br /><br />For more information, see<br />https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/. |  |  |
| `available` _[ResourceList](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#resourcelist-v1-core)_ | Available represents the total available resources of all the nodes on a member cluster.<br /><br />A node's available capacity is the amount of resource that has not been used yet, i.e.,<br />available capacity = allocatable capacity - capacity that has been requested by workloads.<br /><br />This field is beta-level; it is for the property-based scheduling feature and is only<br />populated when a property provider is enabled in the deployment. |  |  |
| `observationTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | When the resource usage is observed. |  |  |


#### Taint



Taint attached to MemberCluster has the "effect" on
any ClusterResourcePlacement that does not tolerate the Taint.



_Appears in:_
- [MemberClusterSpec](#memberclusterspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `key` _string_ | The taint key to be applied to a MemberCluster. |  |  |
| `value` _string_ | The taint value corresponding to the taint key. |  |  |
| `effect` _[TaintEffect](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#tainteffect-v1-core)_ | The effect of the taint on ClusterResourcePlacements that do not tolerate the taint.<br />Only NoSchedule is supported. |  | Enum: [NoSchedule] <br /> |
