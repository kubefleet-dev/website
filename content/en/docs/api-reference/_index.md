---
title: API Reference
description: Reference for Fleet APIs
weight: 9
---

## Packages
- [cluster.kubernetes-fleet.io/v1](#clusterkubernetes-fleetiov1)
- [cluster.kubernetes-fleet.io/v1beta1](#clusterkubernetes-fleetiov1beta1)
- [placement.kubernetes-fleet.io/v1](#placementkubernetes-fleetiov1)
- [placement.kubernetes-fleet.io/v1alpha1](#placementkubernetes-fleetiov1alpha1)
- [placement.kubernetes-fleet.io/v1beta1](#placementkubernetes-fleetiov1beta1)


## cluster.kubernetes-fleet.io/v1



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
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `InternalMemberCluster` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[InternalMemberClusterSpec](#internalmemberclusterspec)_ | The desired state of InternalMemberCluster. |  |  |
| `status` _[InternalMemberClusterStatus](#internalmemberclusterstatus)_ | The observed status of InternalMemberCluster. |  |  |


#### InternalMemberClusterList



InternalMemberClusterList contains a list of InternalMemberCluster.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1` | | |
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
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `MemberCluster` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[MemberClusterSpec](#memberclusterspec)_ | The desired state of MemberCluster. |  |  |
| `status` _[MemberClusterStatus](#memberclusterstatus)_ | The observed status of MemberCluster. |  |  |




#### MemberClusterList



MemberClusterList contains a list of MemberCluster.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `cluster.kubernetes-fleet.io/v1` | | |
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



## placement.kubernetes-fleet.io/v1



### Resource Types
- [AppliedWork](#appliedwork)
- [AppliedWorkList](#appliedworklist)
- [ClusterResourceBinding](#clusterresourcebinding)
- [ClusterResourcePlacement](#clusterresourceplacement)
- [ClusterResourceSnapshot](#clusterresourcesnapshot)
- [ClusterSchedulingPolicySnapshot](#clusterschedulingpolicysnapshot)
- [Work](#work)
- [WorkList](#worklist)



#### Affinity



Affinity is a group of cluster affinity scheduling rules. More to be added.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterAffinity` _[ClusterAffinity](#clusteraffinity)_ | ClusterAffinity contains cluster affinity scheduling rules for the selected resources. |  |  |


#### AppliedResourceMeta



AppliedResourceMeta represents the group, version, resource, name and namespace of a resource.
Since these resources have been created, they must have valid group, version, resource, namespace, and name.



_Appears in:_
- [AppliedWorkStatus](#appliedworkstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `ordinal` _integer_ | Ordinal represents an index in manifests list, so the condition can still be linked<br />to a manifest even though manifest cannot be parsed successfully. |  |  |
| `group` _string_ | Group is the group of the resource. |  |  |
| `version` _string_ | Version is the version of the resource. |  |  |
| `kind` _string_ | Kind is the kind of the resource. |  |  |
| `resource` _string_ | Resource is the resource type of the resource |  |  |
| `namespace` _string_ | Namespace is the namespace of the resource, the resource is cluster scoped if the value<br />is empty |  |  |
| `name` _string_ | Name is the name of the resource |  |  |
| `uid` _[UID](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#uid-types-pkg)_ | UID is set on successful deletion of the Kubernetes resource by controller. The<br />resource might be still visible on the managed cluster after this field is set.<br />It is not directly settable by a client. |  |  |


#### AppliedWork



AppliedWork represents an applied work on managed cluster that is placed
on a managed cluster. An appliedwork links to a work on a hub recording resources
deployed in the managed cluster.
When the agent is removed from managed cluster, cluster-admin on managed cluster
can delete appliedwork to remove resources deployed by the agent.
The name of the appliedwork must be the same as {work name}
The namespace of the appliedwork should be the same as the resource applied on
the managed cluster.



_Appears in:_
- [AppliedWorkList](#appliedworklist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `AppliedWork` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[AppliedWorkSpec](#appliedworkspec)_ | Spec represents the desired configuration of AppliedWork. |  | Required: \{\} <br /> |
| `status` _[AppliedWorkStatus](#appliedworkstatus)_ | Status represents the current status of AppliedWork. |  |  |


#### AppliedWorkList



AppliedWorkList contains a list of AppliedWork.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `AppliedWorkList` | | |
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `items` _[AppliedWork](#appliedwork) array_ | List of works. |  |  |


#### AppliedWorkSpec



AppliedWorkSpec represents the desired configuration of AppliedWork.



_Appears in:_
- [AppliedWork](#appliedwork)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `workName` _string_ | WorkName represents the name of the related work on the hub. |  | Required: \{\} <br /> |
| `workNamespace` _string_ | WorkNamespace represents the namespace of the related work on the hub. |  | Required: \{\} <br /> |


#### AppliedWorkStatus



AppliedWorkStatus represents the current status of AppliedWork.



_Appears in:_
- [AppliedWork](#appliedwork)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `appliedResources` _[AppliedResourceMeta](#appliedresourcemeta) array_ | AppliedResources represents a list of resources defined within the Work that are applied.<br />Only resources with valid GroupVersionResource, namespace, and name are suitable.<br />An item in this slice is deleted when there is no mapped manifest in Work.Spec or by finalizer.<br />The resource relating to the item will also be removed from managed cluster.<br />The deleted resource may still be present until the finalizers for that resource are finished.<br />However, the resource will not be undeleted, so it can be removed from this list and eventual consistency is preserved. |  |  |


#### ApplyStrategy



ApplyStrategy describes how to resolve the conflict if the resource to be placed already exists in the target cluster
and whether it's allowed to be co-owned by other non-fleet appliers.
Note: If multiple CRPs try to place the same resource with different apply strategy, the later ones will fail with the
reason ApplyConflictBetweenPlacements.



_Appears in:_
- [ResourceBindingSpec](#resourcebindingspec)
- [RolloutStrategy](#rolloutstrategy)
- [WorkSpec](#workspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `type` _[ApplyStrategyType](#applystrategytype)_ | Type defines the type of strategy to use. Default to ClientSideApply.<br />Server-side apply is a safer choice. Read more about the differences between server-side apply and client-side<br />apply: https://kubernetes.io/docs/reference/using-api/server-side-apply/#comparison-with-client-side-apply. | ClientSideApply | Enum: [ClientSideApply ServerSideApply] <br /> |
| `allowCoOwnership` _boolean_ | AllowCoOwnership defines whether to apply the resource if it already exists in the target cluster and is not<br />solely owned by fleet (i.e., metadata.ownerReferences contains only fleet custom resources).<br />If true, apply the resource and add fleet as a co-owner.<br />If false, leave the resource unchanged and fail the apply. |  |  |
| `serverSideApplyConfig` _[ServerSideApplyConfig](#serversideapplyconfig)_ | ServerSideApplyConfig defines the configuration for server side apply. It is honored only when type is ServerSideApply. |  |  |


#### ApplyStrategyType

_Underlying type:_ _string_

ApplyStrategyType describes the type of the strategy used to resolve the conflict if the resource to be placed already
exists in the target cluster and is owned by other appliers.



_Appears in:_
- [ApplyStrategy](#applystrategy)

| Field | Description |
| --- | --- |
| `ClientSideApply` | ApplyStrategyTypeClientSideApply will use three-way merge patch similar to how `kubectl apply` does by storing<br />last applied state in the `last-applied-configuration` annotation.<br />When the `last-applied-configuration` annotation size is greater than 256kB, it falls back to the server-side apply.<br /> |
| `ServerSideApply` | ApplyStrategyTypeServerSideApply will use server-side apply to resolve conflicts between the resource to be placed<br />and the existing resource in the target cluster.<br />Details: https://kubernetes.io/docs/reference/using-api/server-side-apply<br /> |


#### BindingState

_Underlying type:_ _string_

BindingState is the state of the binding.



_Appears in:_
- [ResourceBindingSpec](#resourcebindingspec)

| Field | Description |
| --- | --- |
| `Scheduled` | BindingStateScheduled means the binding is scheduled but need to be bound to the target cluster.<br /> |
| `Bound` | BindingStateBound means the binding is bound to the target cluster.<br /> |
| `Unscheduled` | BindingStateUnscheduled means the binding is not scheduled on to the target cluster anymore.<br />This is a state that rollout controller cares about.<br />The work generator still treat this as bound until rollout controller deletes the binding.<br /> |


#### ClusterAffinity



ClusterAffinity contains cluster affinity scheduling rules for the selected resources.



_Appears in:_
- [Affinity](#affinity)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `requiredDuringSchedulingIgnoredDuringExecution` _[ClusterSelector](#clusterselector)_ | If the affinity requirements specified by this field are not met at<br />scheduling time, the resource will not be scheduled onto the cluster.<br />If the affinity requirements specified by this field cease to be met<br />at some point after the placement (e.g. due to an update), the system<br />may or may not try to eventually remove the resource from the cluster. |  |  |
| `preferredDuringSchedulingIgnoredDuringExecution` _[PreferredClusterSelector](#preferredclusterselector) array_ | The scheduler computes a score for each cluster at schedule time by iterating<br />through the elements of this field and adding "weight" to the sum if the cluster<br />matches the corresponding matchExpression. The scheduler then chooses the first<br />`N` clusters with the highest sum to satisfy the placement.<br />This field is ignored if the placement type is "PickAll".<br />If the cluster score changes at some point after the placement (e.g. due to an update),<br />the system may or may not try to eventually move the resource from a cluster with a lower score<br />to a cluster with higher score. |  |  |


#### ClusterDecision



ClusterDecision represents a decision from a placement
An empty ClusterDecision indicates it is not scheduled yet.



_Appears in:_
- [ResourceBindingSpec](#resourcebindingspec)
- [SchedulingPolicySnapshotStatus](#schedulingpolicysnapshotstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterName` _string_ | ClusterName is the name of the ManagedCluster. If it is not empty, its value should be unique cross all<br />placement decisions for the Placement. |  | Required: \{\} <br /> |
| `selected` _boolean_ | Selected indicates if this cluster is selected by the scheduler. |  |  |
| `clusterScore` _[ClusterScore](#clusterscore)_ | ClusterScore represents the score of the cluster calculated by the scheduler. |  |  |
| `reason` _string_ | Reason represents the reason why the cluster is selected or not. |  |  |


#### ClusterResourceBinding



ClusterResourceBinding represents a scheduling decision that binds a group of resources to a cluster.
It MUST have a label named `CRPTrackingLabel` that points to the cluster resource policy that creates it.



_Appears in:_
- [ClusterResourceBindingList](#clusterresourcebindinglist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `ClusterResourceBinding` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ResourceBindingSpec](#resourcebindingspec)_ | The desired state of ClusterResourceBinding. |  |  |
| `status` _[ResourceBindingStatus](#resourcebindingstatus)_ | The observed status of ClusterResourceBinding. |  |  |




#### ClusterResourcePlacement



ClusterResourcePlacement is used to select cluster scoped resources, including built-in resources and custom resources,
and placement them onto selected member clusters in a fleet.


If a namespace is selected, ALL the resources under the namespace are placed to the target clusters.
Note that you can't select the following resources:
  - reserved namespaces including: default, kube-* (reserved for Kubernetes system namespaces),
    fleet-* (reserved for fleet system namespaces).
  - reserved fleet resource types including: MemberCluster, InternalMemberCluster, ClusterResourcePlacement,
    ClusterSchedulingPolicySnapshot, ClusterResourceSnapshot, ClusterResourceBinding, etc.


`ClusterSchedulingPolicySnapshot` and `ClusterResourceSnapshot` objects are created when there are changes in the
system to keep the history of the changes affecting a `ClusterResourcePlacement`.



_Appears in:_
- [ClusterResourcePlacementList](#clusterresourceplacementlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `ClusterResourcePlacement` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ClusterResourcePlacementSpec](#clusterresourceplacementspec)_ | The desired state of ClusterResourcePlacement. |  |  |
| `status` _[ClusterResourcePlacementStatus](#clusterresourceplacementstatus)_ | The observed status of ClusterResourcePlacement. |  |  |






#### ClusterResourcePlacementSpec



ClusterResourcePlacementSpec defines the desired state of ClusterResourcePlacement.



_Appears in:_
- [ClusterResourcePlacement](#clusterresourceplacement)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `resourceSelectors` _[ClusterResourceSelector](#clusterresourceselector) array_ | ResourceSelectors is an array of selectors used to select cluster scoped resources. The selectors are `ORed`.<br />You can have 1-100 selectors. |  | MaxItems: 100 <br />MinItems: 1 <br /> |
| `policy` _[PlacementPolicy](#placementpolicy)_ | Policy defines how to select member clusters to place the selected resources.<br />If unspecified, all the joined member clusters are selected. |  |  |
| `strategy` _[RolloutStrategy](#rolloutstrategy)_ | The rollout strategy to use to replace existing placement with new ones. |  |  |
| `revisionHistoryLimit` _integer_ | The number of old ClusterSchedulingPolicySnapshot or ClusterResourceSnapshot resources to retain to allow rollback.<br />This is a pointer to distinguish between explicit zero and not specified.<br />Defaults to 10. | 10 | Maximum: 1000 <br />Minimum: 1 <br /> |


#### ClusterResourcePlacementStatus



ClusterResourcePlacementStatus defines the observed state of the ClusterResourcePlacement object.



_Appears in:_
- [ClusterResourcePlacement](#clusterresourceplacement)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `selectedResources` _[ResourceIdentifier](#resourceidentifier) array_ | SelectedResources contains a list of resources selected by ResourceSelectors. |  |  |
| `observedResourceIndex` _string_ | Resource index logically represents the generation of the selected resources.<br />We take a new snapshot of the selected resources whenever the selection or their content change.<br />Each snapshot has a different resource index.<br />One resource snapshot can contain multiple clusterResourceSnapshots CRs in order to store large amount of resources.<br />To get clusterResourceSnapshot of a given resource index, use the following command:<br />`kubectl get ClusterResourceSnapshot --selector=kubernetes-fleet.io/resource-index=$ObservedResourceIndex `<br />ObservedResourceIndex is the resource index that the conditions in the ClusterResourcePlacementStatus observe.<br />For example, a condition of `ClusterResourcePlacementWorkSynchronized` type<br />is observing the synchronization status of the resource snapshot with the resource index $ObservedResourceIndex. |  |  |
| `placementStatuses` _[ResourcePlacementStatus](#resourceplacementstatus) array_ | PlacementStatuses contains a list of placement status on the clusters that are selected by PlacementPolicy.<br />Each selected cluster according to the latest resource placement is guaranteed to have a corresponding placementStatuses.<br />In the pickN case, there are N placement statuses where N = NumberOfClusters; Or in the pickFixed case, there are<br />N placement statuses where N = ClusterNames.<br />In these cases, some of them may not have assigned clusters when we cannot fill the required number of clusters.<br />TODO, For pickAll type, considering providing unselected clusters info. |  |  |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ClusterResourcePlacement. |  |  |


#### ClusterResourceSelector



ClusterResourceSelector is used to select cluster scoped resources as the target resources to be placed.
If a namespace is selected, ALL the resources under the namespace are selected automatically.
All the fields are `ANDed`. In other words, a resource must match all the fields to be selected.



_Appears in:_
- [ClusterResourcePlacementSpec](#clusterresourceplacementspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group name of the cluster-scoped resource.<br />Use an empty string to select resources under the core API group (e.g., namespaces). |  |  |
| `version` _string_ | Version of the cluster-scoped resource. |  |  |
| `kind` _string_ | Kind of the cluster-scoped resource.<br />Note: When `Kind` is `namespace`, ALL the resources under the selected namespaces are selected. |  |  |
| `name` _string_ | Name of the cluster-scoped resource. |  |  |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#labelselector-v1-meta)_ | A label query over all the cluster-scoped resources. Resources matching the query are selected.<br />Note that namespace-scoped resources can't be selected even if they match the query. |  |  |


#### ClusterResourceSnapshot



ClusterResourceSnapshot is used to store a snapshot of selected resources by a resource placement policy.
Its spec is immutable.
We may need to produce more than one resourceSnapshot for all the resources a ResourcePlacement selected to get around the 1MB size limit of k8s objects.
We assign an ever-increasing index for each such group of resourceSnapshots.
The naming convention of a clusterResourceSnapshot is {CRPName}-{resourceIndex}-{subindex}
where the name of the first snapshot of a group has no subindex part so its name is {CRPName}-{resourceIndex}-snapshot.
resourceIndex will begin with 0.
Each snapshot MUST have the following labels:
  - `CRPTrackingLabel` which points to its owner CRP.
  - `ResourceIndexLabel` which is the index  of the snapshot group.
  - `IsLatestSnapshotLabel` which indicates whether the snapshot is the latest one.


All the snapshots within the same index group must have the same ResourceIndexLabel.


The first snapshot of the index group MUST have the following annotations:
  - `NumberOfResourceSnapshotsAnnotation` to store the total number of resource snapshots in the index group.
  - `ResourceGroupHashAnnotation` whose value is the sha-256 hash of all the snapshots belong to the same snapshot index.


Each snapshot (excluding the first snapshot) MUST have the following annotations:
  - `SubindexOfResourceSnapshotAnnotation` to store the subindex of resource snapshot in the group.



_Appears in:_
- [ClusterResourceSnapshotList](#clusterresourcesnapshotlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `ClusterResourceSnapshot` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ResourceSnapshotSpec](#resourcesnapshotspec)_ | The desired state of ResourceSnapshot. |  |  |
| `status` _[ResourceSnapshotStatus](#resourcesnapshotstatus)_ | The observed status of ResourceSnapshot. |  |  |




#### ClusterSchedulingPolicySnapshot



ClusterSchedulingPolicySnapshot is used to store a snapshot of cluster placement policy.
Its spec is immutable.
The naming convention of a ClusterSchedulingPolicySnapshot is {CRPName}-{PolicySnapshotIndex}.
PolicySnapshotIndex will begin with 0.
Each snapshot must have the following labels:
  - `CRPTrackingLabel` which points to its owner CRP.
  - `PolicyIndexLabel` which is the index of the policy snapshot.
  - `IsLatestSnapshotLabel` which indicates whether the snapshot is the latest one.



_Appears in:_
- [ClusterSchedulingPolicySnapshotList](#clusterschedulingpolicysnapshotlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `ClusterSchedulingPolicySnapshot` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[SchedulingPolicySnapshotSpec](#schedulingpolicysnapshotspec)_ | The desired state of SchedulingPolicySnapshot. |  |  |
| `status` _[SchedulingPolicySnapshotStatus](#schedulingpolicysnapshotstatus)_ | The observed status of SchedulingPolicySnapshot. |  |  |




#### ClusterScore



ClusterScore represents the score of the cluster calculated by the scheduler.



_Appears in:_
- [ClusterDecision](#clusterdecision)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `affinityScore` _integer_ | AffinityScore represents the affinity score of the cluster calculated by the last<br />scheduling decision based on the preferred affinity selector.<br />An affinity score may not present if the cluster does not meet the required affinity. |  |  |
| `priorityScore` _integer_ | TopologySpreadScore represents the priority score of the cluster calculated by the last<br />scheduling decision based on the topology spread applied to the cluster.<br />A priority score may not present if the cluster does not meet the topology spread. |  |  |


#### ClusterSelector







_Appears in:_
- [ClusterAffinity](#clusteraffinity)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterSelectorTerms` _[ClusterSelectorTerm](#clusterselectorterm) array_ | ClusterSelectorTerms is a list of cluster selector terms. The terms are `ORed`. |  | MaxItems: 10 <br /> |


#### ClusterSelectorTerm

_Underlying type:_ _[struct{LabelSelector *k8s.io/apimachinery/pkg/apis/meta/v1.LabelSelector "json:\"labelSelector,omitempty\""; PropertySelector *PropertySelector "json:\"propertySelector,omitempty\""; PropertySorter *PropertySorter "json:\"propertySorter,omitempty\""}](#struct{labelselector-*k8sioapimachinerypkgapismetav1labelselector-"json:\"labelselector,omitempty\"";-propertyselector-*propertyselector-"json:\"propertyselector,omitempty\"";-propertysorter-*propertysorter-"json:\"propertysorter,omitempty\""})_





_Appears in:_
- [PreferredClusterSelector](#preferredclusterselector)



#### EnvelopeIdentifier



EnvelopeIdentifier identifies the envelope object that contains the selected resource.



_Appears in:_
- [FailedResourcePlacement](#failedresourceplacement)
- [ResourceIdentifier](#resourceidentifier)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | Name of the envelope object. |  |  |
| `namespace` _string_ | Namespace is the namespace of the envelope object. Empty if the envelope object is cluster scoped. |  |  |
| `type` _[EnvelopeType](#envelopetype)_ | Type of the envelope object. | ConfigMap | Enum: [ConfigMap] <br /> |


#### EnvelopeType

_Underlying type:_ _string_

EnvelopeType defines the type of the envelope object.



_Appears in:_
- [EnvelopeIdentifier](#envelopeidentifier)

| Field | Description |
| --- | --- |
| `ConfigMap` | ConfigMapEnvelopeType means the envelope object is of type `ConfigMap`.<br /> |


#### FailedResourcePlacement



FailedResourcePlacement contains the failure details of a failed resource placement.



_Appears in:_
- [ResourceBindingStatus](#resourcebindingstatus)
- [ResourcePlacementStatus](#resourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group is the group name of the selected resource. |  |  |
| `version` _string_ | Version is the version of the selected resource. |  |  |
| `kind` _string_ | Kind represents the Kind of the selected resources. |  |  |
| `name` _string_ | Name of the target resource. |  |  |
| `namespace` _string_ | Namespace is the namespace of the resource. Empty if the resource is cluster scoped. |  |  |
| `envelope` _[EnvelopeIdentifier](#envelopeidentifier)_ | Envelope identifies the envelope object that contains this resource. |  |  |
| `condition` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta)_ | The failed condition status. |  |  |


#### Manifest



Manifest represents a resource to be deployed on spoke cluster.



_Appears in:_
- [WorkloadTemplate](#workloadtemplate)



#### ManifestCondition



ManifestCondition represents the conditions of the resources deployed on
spoke cluster.



_Appears in:_
- [WorkStatus](#workstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `identifier` _[WorkResourceIdentifier](#workresourceidentifier)_ | resourceId represents a identity of a resource linking to manifests in spec. |  |  |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions represents the conditions of this resource on spoke cluster |  |  |


#### NamespacedName



NamespacedName comprises a resource name, with a mandatory namespace.



_Appears in:_
- [ResourceBindingSpec](#resourcebindingspec)
- [ResourcePlacementStatus](#resourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | Name is the name of the namespaced scope resource. |  |  |
| `namespace` _string_ | Namespace is namespace of the namespaced scope resource. |  |  |


#### PlacementPolicy



PlacementPolicy contains the rules to select target member clusters to place the selected resources.
Note that only clusters that are both joined and satisfying the rules will be selected.


You can only specify at most one of the two fields: ClusterNames and Affinity.
If none is specified, all the joined clusters are selected.



_Appears in:_
- [ClusterResourcePlacementSpec](#clusterresourceplacementspec)
- [SchedulingPolicySnapshotSpec](#schedulingpolicysnapshotspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `placementType` _[PlacementType](#placementtype)_ | Type of placement. Can be "PickAll", "PickN" or "PickFixed". Default is PickAll. | PickAll | Enum: [PickAll PickN PickFixed] <br /> |
| `clusterNames` _string array_ | ClusterNames contains a list of names of MemberCluster to place the selected resources.<br />Only valid if the placement type is "PickFixed" |  | MaxItems: 100 <br /> |
| `numberOfClusters` _integer_ | NumberOfClusters of placement. Only valid if the placement type is "PickN". |  | Minimum: 0 <br /> |
| `affinity` _[Affinity](#affinity)_ | Affinity contains cluster affinity scheduling rules. Defines which member clusters to place the selected resources.<br />Only valid if the placement type is "PickAll" or "PickN". |  |  |
| `topologySpreadConstraints` _[TopologySpreadConstraint](#topologyspreadconstraint) array_ | TopologySpreadConstraints describes how a group of resources ought to spread across multiple topology<br />domains. Scheduler will schedule resources in a way which abides by the constraints.<br />All topologySpreadConstraints are ANDed.<br />Only valid if the placement type is "PickN". |  |  |
| `tolerations` _[Toleration](#toleration) array_ | If specified, the ClusterResourcePlacement's Tolerations.<br />Tolerations cannot be updated or deleted.<br /><br />This field is beta-level and is for the taints and tolerations feature. |  | MaxItems: 100 <br /> |


#### PlacementType

_Underlying type:_ _string_

PlacementType identifies the type of placement.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description |
| --- | --- |
| `PickAll` | PickAllPlacementType picks all clusters that satisfy the rules.<br /> |
| `PickN` | PickNPlacementType picks N clusters that satisfy the rules.<br /> |
| `PickFixed` | PickFixedPlacementType picks a fixed set of clusters.<br /> |


#### PreferredClusterSelector







_Appears in:_
- [ClusterAffinity](#clusteraffinity)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `weight` _integer_ | Weight associated with matching the corresponding clusterSelectorTerm, in the range [-100, 100]. |  | Maximum: 100 <br />Minimum: -100 <br /> |
| `preference` _[ClusterSelectorTerm](#clusterselectorterm)_ | A cluster selector term, associated with the corresponding weight. |  |  |




#### PropertySelectorOperator

_Underlying type:_ _string_

PropertySelectorOperator is the operator that can be used with PropertySelectorRequirements.



_Appears in:_
- [PropertySelectorRequirement](#propertyselectorrequirement)

| Field | Description |
| --- | --- |
| `Gt` | PropertySelectorGreaterThan dictates Fleet to select cluster if its observed value of a given<br />property is greater than the value specified in the requirement.<br /> |
| `Ge` | PropertySelectorGreaterThanOrEqualTo dictates Fleet to select cluster if its observed value<br />of a given property is greater than or equal to the value specified in the requirement.<br /> |
| `Eq` | PropertySelectorEqualTo dictates Fleet to select cluster if its observed value of a given<br />property is equal to the values specified in the requirement.<br /> |
| `Ne` | PropertySelectorNotEqualTo dictates Fleet to select cluster if its observed value of a given<br />property is not equal to the values specified in the requirement.<br /> |
| `Lt` | PropertySelectorLessThan dictates Fleet to select cluster if its observed value of a given<br />property is less than the value specified in the requirement.<br /> |
| `Le` | PropertySelectorLessThanOrEqualTo dictates Fleet to select cluster if its observed value of a<br />given property is less than or equal to the value specified in the requirement.<br /> |


#### PropertySelectorRequirement



PropertySelectorRequirement is a specific property requirement when picking clusters for
resource placement.



_Appears in:_
- [PropertySelector](#propertyselector)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | Name is the name of the property; it should be a Kubernetes label name. |  |  |
| `operator` _[PropertySelectorOperator](#propertyselectoroperator)_ | Operator specifies the relationship between a cluster's observed value of the specified<br />property and the values given in the requirement. |  |  |
| `values` _string array_ | Values are a list of values of the specified property which Fleet will compare against<br />the observed values of individual member clusters in accordance with the given<br />operator.<br /><br />At this moment, each value should be a Kubernetes quantity. For more information, see<br />https://pkg.go.dev/k8s.io/apimachinery/pkg/api/resource#Quantity.<br /><br />If the operator is Gt (greater than), Ge (greater than or equal to), Lt (less than),<br />or `Le` (less than or equal to), Eq (equal to), or Ne (ne), exactly one value must be<br />specified in the list. |  | MaxItems: 1 <br /> |


#### PropertySortOrder

_Underlying type:_ _string_





_Appears in:_
- [PropertySorter](#propertysorter)

| Field | Description |
| --- | --- |
| `Descending` | Descending instructs Fleet to sort in descending order, that is, the clusters with higher<br />observed values of a property are most preferred and should have higher weights. We will<br />use linear scaling to calculate the weight for each cluster based on the observed values.<br />For example, with this order, if Fleet sorts all clusters by a specific property where the<br />observed values are in the range [10, 100], and a weight of 100 is specified;<br />Fleet will assign:<br />* a weight of 100 to the cluster with the maximum observed value (100); and<br />* a weight of 0 to the cluster with the minimum observed value (10); and<br />* a weight of 11 to the cluster with an observed value of 20.<br />  It is calculated using the formula below:<br />  ((20 - 10)) / (100 - 10)) * 100 = 11<br /> |
| `Ascending` | Ascending instructs Fleet to sort in ascending order, that is, the clusters with lower<br />observed values are most preferred and should have higher weights. We will use linear scaling<br />to calculate the weight for each cluster based on the observed values.<br />For example, with this order, if Fleet sorts all clusters by a specific property where<br />the observed values are in the range [10, 100], and a weight of 100 is specified;<br />Fleet will assign:<br />* a weight of 0 to the cluster with the  maximum observed value (100); and<br />* a weight of 100 to the cluster with the minimum observed value (10); and<br />* a weight of 89 to the cluster with an observed value of 20.<br />  It is calculated using the formula below:<br />  (1 - ((20 - 10) / (100 - 10))) * 100 = 89<br /> |






#### ResourceBindingSpec



ResourceBindingSpec defines the desired state of ClusterResourceBinding.



_Appears in:_
- [ClusterResourceBinding](#clusterresourcebinding)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `state` _[BindingState](#bindingstate)_ | The desired state of the binding. Possible values: Scheduled, Bound, Unscheduled. |  |  |
| `resourceSnapshotName` _string_ | ResourceSnapshotName is the name of the resource snapshot that this resource binding points to.<br />If the resources are divided into multiple snapshots because of the resource size limit,<br />it points to the name of the leading snapshot of the index group. |  |  |
| `resourceOverrideSnapshots` _[NamespacedName](#namespacedname) array_ | ResourceOverrideSnapshots is a list of ResourceOverride snapshots associated with the selected resources. |  |  |
| `clusterResourceOverrideSnapshots` _string array_ | ClusterResourceOverrides contains a list of applicable ClusterResourceOverride snapshot names associated with the<br />selected resources. |  |  |
| `schedulingPolicySnapshotName` _string_ | SchedulingPolicySnapshotName is the name of the scheduling policy snapshot that this resource binding<br />points to; more specifically, the scheduler creates this bindings in accordance with this<br />scheduling policy snapshot. |  |  |
| `targetCluster` _string_ | TargetCluster is the name of the cluster that the scheduler assigns the resources to. |  |  |
| `clusterDecision` _[ClusterDecision](#clusterdecision)_ | ClusterDecision explains why the scheduler selected this cluster. |  |  |
| `applyStrategy` _[ApplyStrategy](#applystrategy)_ | ApplyStrategy describes how to resolve the conflict if the resource to be placed already exists in the target cluster<br />and is owned by other appliers.<br />This field is a beta-level feature. |  |  |


#### ResourceBindingStatus



ResourceBindingStatus represents the current status of a ClusterResourceBinding.



_Appears in:_
- [ClusterResourceBinding](#clusterresourcebinding)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `failedPlacements` _[FailedResourcePlacement](#failedresourceplacement) array_ | FailedPlacements is a list of all the resources failed to be placed to the given cluster or the resource is unavailable.<br />Note that we only include 100 failed resource placements even if there are more than 100. |  | MaxItems: 100 <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ClusterResourceBinding. |  |  |


#### ResourceContent



ResourceContent contains the content of a resource



_Appears in:_
- [ResourceSnapshotSpec](#resourcesnapshotspec)



#### ResourceIdentifier



ResourceIdentifier identifies one Kubernetes resource.



_Appears in:_
- [ClusterResourcePlacementStatus](#clusterresourceplacementstatus)
- [FailedResourcePlacement](#failedresourceplacement)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group is the group name of the selected resource. |  |  |
| `version` _string_ | Version is the version of the selected resource. |  |  |
| `kind` _string_ | Kind represents the Kind of the selected resources. |  |  |
| `name` _string_ | Name of the target resource. |  |  |
| `namespace` _string_ | Namespace is the namespace of the resource. Empty if the resource is cluster scoped. |  |  |
| `envelope` _[EnvelopeIdentifier](#envelopeidentifier)_ | Envelope identifies the envelope object that contains this resource. |  |  |




#### ResourcePlacementStatus



ResourcePlacementStatus represents the placement status of selected resources for one target cluster.



_Appears in:_
- [ClusterResourcePlacementStatus](#clusterresourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterName` _string_ | ClusterName is the name of the cluster this resource is assigned to.<br />If it is not empty, its value should be unique cross all placement decisions for the Placement. |  |  |
| `applicableResourceOverrides` _[NamespacedName](#namespacedname) array_ | ApplicableResourceOverrides contains a list of applicable ResourceOverride snapshots associated with the selected<br />resources.<br /><br />This field is alpha-level and is for the override policy feature. |  |  |
| `applicableClusterResourceOverrides` _string array_ | ApplicableClusterResourceOverrides contains a list of applicable ClusterResourceOverride snapshots associated with<br />the selected resources.<br /><br />This field is alpha-level and is for the override policy feature. |  |  |
| `failedPlacements` _[FailedResourcePlacement](#failedresourceplacement) array_ | FailedPlacements is a list of all the resources failed to be placed to the given cluster or the resource is unavailable.<br />Note that we only include 100 failed resource placements even if there are more than 100.<br />This field is only meaningful if the `ClusterName` is not empty. |  | MaxItems: 100 <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ResourcePlacementStatus. |  |  |


#### ResourceSnapshotSpec



ResourceSnapshotSpec	defines the desired state of ResourceSnapshot.



_Appears in:_
- [ClusterResourceSnapshot](#clusterresourcesnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `selectedResources` _[ResourceContent](#resourcecontent) array_ | SelectedResources contains a list of resources selected by ResourceSelectors. |  |  |


#### ResourceSnapshotStatus







_Appears in:_
- [ClusterResourceSnapshot](#clusterresourcesnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ResourceSnapshot. |  |  |


#### RollingUpdateConfig



RollingUpdateConfig contains the config to control the desired behavior of rolling update.



_Appears in:_
- [RolloutStrategy](#rolloutstrategy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `maxUnavailable` _[IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#intorstring-intstr-util)_ | The maximum number of clusters that can be unavailable during the rolling update<br />comparing to the desired number of clusters.<br />The desired number equals to the `NumberOfClusters` field when the placement type is `PickN`.<br />The desired number equals to the number of clusters scheduler selected when the placement type is `PickAll`.<br />Value can be an absolute number (ex: 5) or a percentage of the desired number of clusters (ex: 10%).<br />Absolute number is calculated from percentage by rounding up.<br />We consider a resource unavailable when we either remove it from a cluster or in-place<br />upgrade the resources content on the same cluster.<br />The minimum of MaxUnavailable is 0 to allow no downtime moving a placement from one cluster to another.<br />Please set it to be greater than 0 to avoid rolling out stuck during in-place resource update.<br />Defaults to 25%. | 25% | Pattern: `^((100\|[0-9]\{1,2\})%\|[0-9]+)$` <br />XIntOrString: \{\} <br /> |
| `maxSurge` _[IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#intorstring-intstr-util)_ | The maximum number of clusters that can be scheduled above the desired number of clusters.<br />The desired number equals to the `NumberOfClusters` field when the placement type is `PickN`.<br />The desired number equals to the number of clusters scheduler selected when the placement type is `PickAll`.<br />Value can be an absolute number (ex: 5) or a percentage of desire (ex: 10%).<br />Absolute number is calculated from percentage by rounding up.<br />This does not apply to the case that we do in-place update of resources on the same cluster.<br />This can not be 0 if MaxUnavailable is 0.<br />Defaults to 25%. | 25% | Pattern: `^((100\|[0-9]\{1,2\})%\|[0-9]+)$` <br />XIntOrString: \{\} <br /> |
| `unavailablePeriodSeconds` _integer_ | UnavailablePeriodSeconds is used to configure the waiting time between rollout phases when we<br />cannot determine if the resources have rolled out successfully or not.<br />We have a built-in resource state detector to determine the availability status of following well-known Kubernetes<br />native resources: Deployment, StatefulSet, DaemonSet, Service, Namespace, ConfigMap, Secret,<br />ClusterRole, ClusterRoleBinding, Role, RoleBinding.<br />Please see [SafeRollout](https://github.com/Azure/fleet/tree/main/docs/concepts/SafeRollout/README.md) for more details.<br />For other types of resources, we consider them as available after `UnavailablePeriodSeconds` seconds<br />have passed since they were successfully applied to the target cluster.<br />Default is 60. | 60 |  |


#### RolloutStrategy



RolloutStrategy describes how to roll out a new change in selected resources to target clusters.



_Appears in:_
- [ClusterResourcePlacementSpec](#clusterresourceplacementspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `type` _[RolloutStrategyType](#rolloutstrategytype)_ | Type of rollout. The only supported type is "RollingUpdate". Default is "RollingUpdate". | RollingUpdate | Enum: [RollingUpdate] <br /> |
| `rollingUpdate` _[RollingUpdateConfig](#rollingupdateconfig)_ | Rolling update config params. Present only if RolloutStrategyType = RollingUpdate. |  |  |
| `applyStrategy` _[ApplyStrategy](#applystrategy)_ | ApplyStrategy describes how to resolve the conflict if the resource to be placed already exists in the target cluster<br />and is owned by other appliers.<br />This field is a beta-level feature. |  |  |


#### RolloutStrategyType

_Underlying type:_ _string_





_Appears in:_
- [RolloutStrategy](#rolloutstrategy)

| Field | Description |
| --- | --- |
| `RollingUpdate` | RollingUpdateRolloutStrategyType replaces the old placed resource using rolling update<br />i.e. gradually create the new one while replace the old ones.<br /> |




#### SchedulingPolicySnapshotSpec



SchedulingPolicySnapshotSpec defines the desired state of SchedulingPolicySnapshot.



_Appears in:_
- [ClusterSchedulingPolicySnapshot](#clusterschedulingpolicysnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `policy` _[PlacementPolicy](#placementpolicy)_ | Policy defines how to select member clusters to place the selected resources.<br />If unspecified, all the joined member clusters are selected. |  |  |
| `policyHash` _integer array_ | PolicyHash is the sha-256 hash value of the Policy field. |  |  |


#### SchedulingPolicySnapshotStatus



SchedulingPolicySnapshotStatus defines the observed state of SchedulingPolicySnapshot.



_Appears in:_
- [ClusterSchedulingPolicySnapshot](#clusterschedulingpolicysnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `observedCRPGeneration` _integer_ | ObservedCRPGeneration is the generation of the CRP which the scheduler uses to perform<br />the scheduling cycle and prepare the scheduling status. |  |  |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for SchedulingPolicySnapshot. |  |  |
| `targetClusters` _[ClusterDecision](#clusterdecision) array_ | ClusterDecisions contains a list of names of member clusters considered by the scheduler.<br />Note that all the selected clusters must present in the list while not all the<br />member clusters are guaranteed to be listed due to the size limit. We will try to<br />add the clusters that can provide the most insight to the list first. |  | MaxItems: 1000 <br /> |


#### ServerSideApplyConfig



ServerSideApplyConfig defines the configuration for server side apply.
Details: https://kubernetes.io/docs/reference/using-api/server-side-apply/#conflicts



_Appears in:_
- [ApplyStrategy](#applystrategy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `force` _boolean_ | Force represents to force apply to succeed when resolving the conflicts<br />For any conflicting fields,<br />- If true, use the values from the resource to be applied to overwrite the values of the existing resource in the<br />target cluster, as well as take over ownership of such fields.<br />- If false, apply will fail with the reason ApplyConflictWithOtherApplier.<br /><br />For non-conflicting fields, values stay unchanged and ownership are shared between appliers. |  |  |


#### Toleration



Toleration allows ClusterResourcePlacement to tolerate any taint that matches
the triple <key,value,effect> using the matching operator <operator>.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `key` _string_ | Key is the taint key that the toleration applies to. Empty means match all taint keys.<br />If the key is empty, operator must be Exists; this combination means to match all values and all keys. |  |  |
| `operator` _[TolerationOperator](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#tolerationoperator-v1-core)_ | Operator represents a key's relationship to the value.<br />Valid operators are Exists and Equal. Defaults to Equal.<br />Exists is equivalent to wildcard for value, so that a<br />ClusterResourcePlacement can tolerate all taints of a particular category. | Equal | Enum: [Equal Exists] <br /> |
| `value` _string_ | Value is the taint value the toleration matches to.<br />If the operator is Exists, the value should be empty, otherwise just a regular string. |  |  |
| `effect` _[TaintEffect](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#tainteffect-v1-core)_ | Effect indicates the taint effect to match. Empty means match all taint effects.<br />When specified, only allowed value is NoSchedule. |  | Enum: [NoSchedule] <br /> |


#### TopologySpreadConstraint



TopologySpreadConstraint specifies how to spread resources among the given cluster topology.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `maxSkew` _integer_ | MaxSkew describes the degree to which resources may be unevenly distributed.<br />When `whenUnsatisfiable=DoNotSchedule`, it is the maximum permitted difference<br />between the number of resource copies in the target topology and the global minimum.<br />The global minimum is the minimum number of resource copies in a domain.<br />When `whenUnsatisfiable=ScheduleAnyway`, it is used to give higher precedence<br />to topologies that satisfy it.<br />It's an optional field. Default value is 1 and 0 is not allowed. | 1 | Minimum: 1 <br /> |
| `topologyKey` _string_ | TopologyKey is the key of cluster labels. Clusters that have a label with this key<br />and identical values are considered to be in the same topology.<br />We consider each <key, value> as a "bucket", and try to put balanced number<br />of replicas of the resource into each bucket honor the `MaxSkew` value.<br />It's a required field. |  |  |
| `whenUnsatisfiable` _[UnsatisfiableConstraintAction](#unsatisfiableconstraintaction)_ | WhenUnsatisfiable indicates how to deal with the resource if it doesn't satisfy<br />the spread constraint.<br />- DoNotSchedule (default) tells the scheduler not to schedule it.<br />- ScheduleAnyway tells the scheduler to schedule the resource in any cluster,<br />  but giving higher precedence to topologies that would help reduce the skew.<br />It's an optional field. |  |  |


#### UnsatisfiableConstraintAction

_Underlying type:_ _string_

UnsatisfiableConstraintAction defines the type of actions that can be taken if a constraint is not satisfied.



_Appears in:_
- [TopologySpreadConstraint](#topologyspreadconstraint)

| Field | Description |
| --- | --- |
| `DoNotSchedule` | DoNotSchedule instructs the scheduler not to schedule the resource<br />onto the cluster when constraints are not satisfied.<br /> |
| `ScheduleAnyway` | ScheduleAnyway instructs the scheduler to schedule the resource<br />even if constraints are not satisfied.<br /> |


#### Work



Work is the Schema for the works API.



_Appears in:_
- [WorkList](#worklist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `Work` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[WorkSpec](#workspec)_ | spec defines the workload of a work. |  |  |
| `status` _[WorkStatus](#workstatus)_ | status defines the status of each applied manifest on the spoke cluster. |  |  |


#### WorkList



WorkList contains a list of Work.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1` | | |
| `kind` _string_ | `WorkList` | | |
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `items` _[Work](#work) array_ | List of works. |  |  |


#### WorkResourceIdentifier



WorkResourceIdentifier provides the identifiers needed to interact with any arbitrary object.
Renamed original "ResourceIdentifier" so that it won't conflict with ResourceIdentifier defined in the clusterresourceplacement_types.go.



_Appears in:_
- [AppliedResourceMeta](#appliedresourcemeta)
- [ManifestCondition](#manifestcondition)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `ordinal` _integer_ | Ordinal represents an index in manifests list, so the condition can still be linked<br />to a manifest even though manifest cannot be parsed successfully. |  |  |
| `group` _string_ | Group is the group of the resource. |  |  |
| `version` _string_ | Version is the version of the resource. |  |  |
| `kind` _string_ | Kind is the kind of the resource. |  |  |
| `resource` _string_ | Resource is the resource type of the resource |  |  |
| `namespace` _string_ | Namespace is the namespace of the resource, the resource is cluster scoped if the value<br />is empty |  |  |
| `name` _string_ | Name is the name of the resource |  |  |


#### WorkSpec



WorkSpec defines the desired state of Work.



_Appears in:_
- [Work](#work)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `workload` _[WorkloadTemplate](#workloadtemplate)_ | Workload represents the manifest workload to be deployed on spoke cluster |  |  |
| `applyStrategy` _[ApplyStrategy](#applystrategy)_ | ApplyStrategy describes how to resolve the conflict if the resource to be placed already exists in the target cluster<br />and is owned by other appliers.<br />This field is a beta-level feature. |  |  |


#### WorkStatus



WorkStatus defines the observed state of Work.



_Appears in:_
- [Work](#work)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions contains the different condition statuses for this work.<br />Valid condition types are:<br />1. Applied represents workload in Work is applied successfully on the spoke cluster.<br />2. Progressing represents workload in Work in the transitioning from one state to another the on the spoke cluster.<br />3. Available represents workload in Work exists on the spoke cluster.<br />4. Degraded represents the current state of workload does not match the desired<br />state for a certain period. |  |  |
| `manifestConditions` _[ManifestCondition](#manifestcondition) array_ | ManifestConditions represents the conditions of each resource in work deployed on<br />spoke cluster. |  |  |


#### WorkloadTemplate



WorkloadTemplate represents the manifest workload to be deployed on spoke cluster



_Appears in:_
- [WorkSpec](#workspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `manifests` _[Manifest](#manifest) array_ | Manifests represents a list of kubernetes resources to be deployed on the spoke cluster. |  |  |



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



## placement.kubernetes-fleet.io/v1beta1



### Resource Types
- [AppliedWork](#appliedwork)
- [AppliedWorkList](#appliedworklist)
- [ClusterApprovalRequest](#clusterapprovalrequest)
- [ClusterResourceBinding](#clusterresourcebinding)
- [ClusterResourcePlacement](#clusterresourceplacement)
- [ClusterResourcePlacementDisruptionBudget](#clusterresourceplacementdisruptionbudget)
- [ClusterResourcePlacementEviction](#clusterresourceplacementeviction)
- [ClusterResourceSnapshot](#clusterresourcesnapshot)
- [ClusterSchedulingPolicySnapshot](#clusterschedulingpolicysnapshot)
- [ClusterStagedUpdateRun](#clusterstagedupdaterun)
- [ClusterStagedUpdateStrategy](#clusterstagedupdatestrategy)
- [Work](#work)
- [WorkList](#worklist)



#### Affinity



Affinity is a group of cluster affinity scheduling rules. More to be added.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterAffinity` _[ClusterAffinity](#clusteraffinity)_ | ClusterAffinity contains cluster affinity scheduling rules for the selected resources. |  | Optional: \{\} <br /> |


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


#### AppliedResourceMeta



AppliedResourceMeta represents the group, version, resource, name and namespace of a resource.
Since these resources have been created, they must have valid group, version, resource, namespace, and name.



_Appears in:_
- [AppliedWorkStatus](#appliedworkstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `ordinal` _integer_ | Ordinal represents an index in manifests list, so the condition can still be linked<br />to a manifest even though manifest cannot be parsed successfully. |  |  |
| `group` _string_ | Group is the group of the resource. |  |  |
| `version` _string_ | Version is the version of the resource. |  |  |
| `kind` _string_ | Kind is the kind of the resource. |  |  |
| `resource` _string_ | Resource is the resource type of the resource. |  |  |
| `namespace` _string_ | Namespace is the namespace of the resource, the resource is cluster scoped if the value<br />is empty. |  |  |
| `name` _string_ | Name is the name of the resource. |  |  |
| `uid` _[UID](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#uid-types-pkg)_ | UID is set on successful deletion of the Kubernetes resource by controller. The<br />resource might be still visible on the managed cluster after this field is set.<br />It is not directly settable by a client. |  |  |


#### AppliedWork



AppliedWork represents an applied work on managed cluster that is placed
on a managed cluster. An appliedwork links to a work on a hub recording resources
deployed in the managed cluster.
When the agent is removed from managed cluster, cluster-admin on managed cluster
can delete appliedwork to remove resources deployed by the agent.
The name of the appliedwork must be the same as {work name}
The namespace of the appliedwork should be the same as the resource applied on
the managed cluster.



_Appears in:_
- [AppliedWorkList](#appliedworklist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `AppliedWork` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[AppliedWorkSpec](#appliedworkspec)_ | Spec represents the desired configuration of AppliedWork. |  | Required: \{\} <br /> |
| `status` _[AppliedWorkStatus](#appliedworkstatus)_ | Status represents the current status of AppliedWork. |  |  |


#### AppliedWorkList



AppliedWorkList contains a list of AppliedWork.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `AppliedWorkList` | | |
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `items` _[AppliedWork](#appliedwork) array_ | List of works. |  |  |


#### AppliedWorkSpec



AppliedWorkSpec represents the desired configuration of AppliedWork.



_Appears in:_
- [AppliedWork](#appliedwork)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `workName` _string_ | WorkName represents the name of the related work on the hub. |  | Required: \{\} <br /> |
| `workNamespace` _string_ | WorkNamespace represents the namespace of the related work on the hub. |  | Required: \{\} <br /> |


#### AppliedWorkStatus



AppliedWorkStatus represents the current status of AppliedWork.



_Appears in:_
- [AppliedWork](#appliedwork)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `appliedResources` _[AppliedResourceMeta](#appliedresourcemeta) array_ | AppliedResources represents a list of resources defined within the Work that are applied.<br />Only resources with valid GroupVersionResource, namespace, and name are suitable.<br />An item in this slice is deleted when there is no mapped manifest in Work.Spec or by finalizer.<br />The resource relating to the item will also be removed from managed cluster.<br />The deleted resource may still be present until the finalizers for that resource are finished.<br />However, the resource will not be undeleted, so it can be removed from this list and eventual consistency is preserved. |  |  |


#### ApplyStrategy



ApplyStrategy describes when and how to apply the selected resource to the target cluster.
Note: If multiple CRPs try to place the same resource with different apply strategy, the later ones will fail with the
reason ApplyConflictBetweenPlacements.



_Appears in:_
- [ResourceBindingSpec](#resourcebindingspec)
- [RolloutStrategy](#rolloutstrategy)
- [StagedUpdateRunStatus](#stagedupdaterunstatus)
- [StagedUpdateRunStatus](#stagedupdaterunstatus)
- [WorkSpec](#workspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `comparisonOption` _[ComparisonOptionType](#comparisonoptiontype)_ | ComparisonOption controls how Fleet compares the desired state of a resource, as kept in<br />a hub cluster manifest, with the current state of the resource (if applicable) in the<br />member cluster.<br /><br />Available options are:<br /><br />* PartialComparison: with this option, Fleet will compare only fields that are managed by<br />  Fleet, i.e., the fields that are specified explicitly in the hub cluster manifest.<br />  Unmanaged fields are ignored. This is the default option.<br /><br />* FullComparison: with this option, Fleet will compare all fields of the resource,<br />  even if the fields are absent from the hub cluster manifest.<br /><br />Consider using the PartialComparison option if you would like to:<br /><br />* use the default values for certain fields; or<br />* let another agent, e.g., HPAs, VPAs, etc., on the member cluster side manage some fields; or<br />* allow ad-hoc or cluster-specific settings on the member cluster side.<br /><br />To use the FullComparison option, it is recommended that you:<br /><br />* specify all fields as appropriate in the hub cluster, even if you are OK with using default<br />  values;<br />* make sure that no fields are managed by agents other than Fleet on the member cluster<br />  side, such as HPAs, VPAs, or other controllers.<br /><br />See the Fleet documentation for further explanations and usage examples. | PartialComparison | Enum: [PartialComparison FullComparison] <br />Optional: \{\} <br /> |
| `whenToApply` _[WhenToApplyType](#whentoapplytype)_ | WhenToApply controls when Fleet would apply the manifests on the hub cluster to the member<br />clusters.<br /><br />Available options are:<br /><br />* Always: with this option, Fleet will periodically apply hub cluster manifests<br />  on the member cluster side; this will effectively overwrite any change in the fields<br />  managed by Fleet (i.e., specified in the hub cluster manifest). This is the default<br />  option.<br /><br />  Note that this option would revert any ad-hoc changes made on the member cluster side in<br />  the managed fields; if you would like to make temporary edits on the member cluster side<br />  in the managed fields, switch to IfNotDrifted option. Note that changes in unmanaged<br />  fields will be left alone; if you use the FullDiff compare option, such changes will<br />  be reported as drifts.<br /><br />* IfNotDrifted: with this option, Fleet will stop applying hub cluster manifests on<br />  clusters that have drifted from the desired state; apply ops would still continue on<br />  the rest of the clusters. Drifts are calculated using the ComparisonOption,<br />  as explained in the corresponding field.<br /><br />  Use this option if you would like Fleet to detect drifts in your multi-cluster setup.<br />  A drift occurs when an agent makes an ad-hoc change on the member cluster side that<br />  makes affected resources deviate from its desired state as kept in the hub cluster;<br />  and this option grants you an opportunity to view the drift details and take actions<br />  accordingly. The drift details will be reported in the CRP status.<br /><br />  To fix a drift, you may:<br /><br />  * revert the changes manually on the member cluster side<br />  * update the hub cluster manifest; this will trigger Fleet to apply the latest revision<br />    of the manifests, which will overwrite the drifted fields<br />    (if they are managed by Fleet)<br />  * switch to the Always option; this will trigger Fleet to apply the current revision<br />    of the manifests, which will overwrite the drifted fields (if they are managed by Fleet).<br />  * if applicable and necessary, delete the drifted resources on the member cluster side; Fleet<br />    will attempt to re-create them using the hub cluster manifests | Always | Enum: [Always IfNotDrifted] <br />Optional: \{\} <br /> |
| `type` _[ApplyStrategyType](#applystrategytype)_ | Type is the apply strategy to use; it determines how Fleet applies manifests from the<br />hub cluster to a member cluster.<br /><br />Available options are:<br /><br />* ClientSideApply: Fleet uses three-way merge to apply manifests, similar to how kubectl<br />  performs a client-side apply. This is the default option.<br /><br />  Note that this strategy requires that Fleet keep the last applied configuration in the<br />  annotation of an applied resource. If the object gets so large that apply ops can no longer<br />  be executed, Fleet will switch to server-side apply.<br /><br />  Use ComparisonOption and WhenToApply settings to control when an apply op can be executed.<br /><br />* ServerSideApply: Fleet uses server-side apply to apply manifests; Fleet itself will<br />  become the field manager for specified fields in the manifests. Specify<br />  ServerSideApplyConfig as appropriate if you would like Fleet to take over field<br />  ownership upon conflicts. This is the recommended option for most scenarios; it might<br />  help reduce object size and safely resolve conflicts between field values. For more<br />  information, please refer to the Kubernetes documentation<br />  (https://kubernetes.io/docs/reference/using-api/server-side-apply/#comparison-with-client-side-apply).<br /><br />  Use ComparisonOption and WhenToApply settings to control when an apply op can be executed.<br /><br />* ReportDiff: Fleet will compare the desired state of a resource as kept in the hub cluster<br />  with its current state (if applicable) on the member cluster side, and report any<br />  differences. No actual apply ops would be executed, and resources will be left alone as they<br />  are on the member clusters.<br /><br />  If configuration differences are found on a resource, Fleet will consider this as an apply<br />  error, which might block rollout depending on the specified rollout strategy.<br /><br />  Use ComparisonOption setting to control how the difference is calculated.<br /><br />ClientSideApply and ServerSideApply apply strategies only work when Fleet can assume<br />ownership of a resource (e.g., the resource is created by Fleet, or Fleet has taken over<br />the resource). See the comments on the WhenToTakeOver field for more information.<br />ReportDiff apply strategy, however, will function regardless of Fleet's ownership<br />status. One may set up a CRP with the ReportDiff strategy and the Never takeover option,<br />and this will turn Fleet into a detection tool that reports only configuration differences<br />but do not touch any resources on the member cluster side.<br /><br />For a comparison between the different strategies and usage examples, refer to the<br />Fleet documentation. | ClientSideApply | Enum: [ClientSideApply ServerSideApply ReportDiff] <br />Optional: \{\} <br /> |
| `allowCoOwnership` _boolean_ | AllowCoOwnership controls whether co-ownership between Fleet and other agents are allowed<br />on a Fleet-managed resource. If set to false, Fleet will refuse to apply manifests to<br />a resource that has been owned by one or more non-Fleet agents.<br /><br />Note that Fleet does not support the case where one resource is being placed multiple<br />times by different CRPs on the same member cluster. An apply error will be returned if<br />Fleet finds that a resource has been owned by another placement attempt by Fleet, even<br />with the AllowCoOwnership setting set to true. |  |  |
| `serverSideApplyConfig` _[ServerSideApplyConfig](#serversideapplyconfig)_ | ServerSideApplyConfig defines the configuration for server side apply. It is honored only when type is ServerSideApply. |  | Optional: \{\} <br /> |
| `whenToTakeOver` _[WhenToTakeOverType](#whentotakeovertype)_ | WhenToTakeOver determines the action to take when Fleet applies resources to a member<br />cluster for the first time and finds out that the resource already exists in the cluster.<br /><br />This setting is most relevant in cases where you would like Fleet to manage pre-existing<br />resources on a member cluster.<br /><br />Available options include:<br /><br />* Always: with this action, Fleet will apply the hub cluster manifests to the member<br />  clusters even if the affected resources already exist. This is the default action.<br /><br />  Note that this might lead to fields being overwritten on the member clusters, if they<br />  are specified in the hub cluster manifests.<br /><br />* IfNoDiff: with this action, Fleet will apply the hub cluster manifests to the member<br />  clusters if (and only if) pre-existing resources look the same as the hub cluster manifests.<br /><br />  This is a safer option as pre-existing resources that are inconsistent with the hub cluster<br />  manifests will not be overwritten; Fleet will ignore them until the inconsistencies<br />  are resolved properly: any change you make to the hub cluster manifests would not be<br />  applied, and if you delete the manifests or even the ClusterResourcePlacement itself<br />  from the hub cluster, these pre-existing resources would not be taken away.<br /><br />  Fleet will check for inconsistencies in accordance with the ComparisonOption setting. See also<br />  the comments on the ComparisonOption field for more information.<br /><br />  If a diff has been found in a field that is **managed** by Fleet (i.e., the field<br />  **is specified ** in the hub cluster manifest), consider one of the following actions:<br />  * set the field in the member cluster to be of the same value as that in the hub cluster<br />    manifest.<br />  * update the hub cluster manifest so that its field value matches with that in the member<br />    cluster.<br />  * switch to the Always action, which will allow Fleet to overwrite the field with the<br />    value in the hub cluster manifest.<br /><br />  If a diff has been found in a field that is **not managed** by Fleet (i.e., the field<br />  **is not specified** in the hub cluster manifest), consider one of the following actions:<br />  * remove the field from the member cluster.<br />  * update the hub cluster manifest so that the field is included in the hub cluster manifest.<br /><br />  If appropriate, you may also delete the object from the member cluster; Fleet will recreate<br />  it using the hub cluster manifest.<br /><br />* Never: with this action, Fleet will not apply a hub cluster manifest to the member<br />  clusters if there is a corresponding pre-existing resource. However, if a manifest<br />  has never been applied yet; or it has a corresponding resource which Fleet has assumed<br />  ownership, apply op will still be executed.<br /><br />  This is the safest option; one will have to remove the pre-existing resources (so that<br />  Fleet can re-create them) or switch to a different<br />  WhenToTakeOver option before Fleet starts processing the corresponding hub cluster<br />  manifests.<br /><br />  If you prefer Fleet stop processing all manifests, use this option along with the<br />  ReportDiff apply strategy type. This setup would instruct Fleet to touch nothing<br />  on the member cluster side but still report configuration differences between the<br />  hub cluster and member clusters. Fleet will not give up ownership<br />  that it has already assumed though. | Always | Enum: [Always IfNoDiff Never] <br />Optional: \{\} <br /> |


#### ApplyStrategyType

_Underlying type:_ _string_

ApplyStrategyType describes the type of the strategy used to apply the resource to the target cluster.



_Appears in:_
- [ApplyStrategy](#applystrategy)

| Field | Description |
| --- | --- |
| `ClientSideApply` | ApplyStrategyTypeClientSideApply will use three-way merge patch similar to how `kubectl apply` does by storing<br />last applied state in the `last-applied-configuration` annotation.<br />When the `last-applied-configuration` annotation size is greater than 256kB, it falls back to the server-side apply.<br /> |
| `ServerSideApply` | ApplyStrategyTypeServerSideApply will use server-side apply to resolve conflicts between the resource to be placed<br />and the existing resource in the target cluster.<br />Details: https://kubernetes.io/docs/reference/using-api/server-side-apply<br /> |
| `ReportDiff` | ApplyStrategyTypeReportDiff will report differences between the desired state of a<br />resource as kept in the hub cluster and its current state (if applicable) on the member<br />cluster side. No actual apply ops would be executed.<br /> |




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


#### BindingState

_Underlying type:_ _string_

BindingState is the state of the binding.



_Appears in:_
- [ResourceBindingSpec](#resourcebindingspec)

| Field | Description |
| --- | --- |
| `Scheduled` | BindingStateScheduled means the binding is scheduled but need to be bound to the target cluster.<br /> |
| `Bound` | BindingStateBound means the binding is bound to the target cluster.<br /> |
| `Unscheduled` | BindingStateUnscheduled means the binding is not scheduled on to the target cluster anymore.<br />This is a state that rollout controller cares about.<br />The work generator still treat this as bound until rollout controller deletes the binding.<br /> |


#### ClusterAffinity



ClusterAffinity contains cluster affinity scheduling rules for the selected resources.



_Appears in:_
- [Affinity](#affinity)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `requiredDuringSchedulingIgnoredDuringExecution` _[ClusterSelector](#clusterselector)_ | If the affinity requirements specified by this field are not met at<br />scheduling time, the resource will not be scheduled onto the cluster.<br />If the affinity requirements specified by this field cease to be met<br />at some point after the placement (e.g. due to an update), the system<br />may or may not try to eventually remove the resource from the cluster. |  | Optional: \{\} <br /> |
| `preferredDuringSchedulingIgnoredDuringExecution` _[PreferredClusterSelector](#preferredclusterselector) array_ | The scheduler computes a score for each cluster at schedule time by iterating<br />through the elements of this field and adding "weight" to the sum if the cluster<br />matches the corresponding matchExpression. The scheduler then chooses the first<br />`N` clusters with the highest sum to satisfy the placement.<br />This field is ignored if the placement type is "PickAll".<br />If the cluster score changes at some point after the placement (e.g. due to an update),<br />the system may or may not try to eventually move the resource from a cluster with a lower score<br />to a cluster with higher score. |  | Optional: \{\} <br /> |


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
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `ClusterApprovalRequest` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ApprovalRequestSpec](#approvalrequestspec)_ | The desired state of ClusterApprovalRequest. |  | Required: \{\} <br /> |
| `status` _[ApprovalRequestStatus](#approvalrequeststatus)_ | The observed state of ClusterApprovalRequest. |  | Optional: \{\} <br /> |




#### ClusterDecision



ClusterDecision represents a decision from a placement
An empty ClusterDecision indicates it is not scheduled yet.



_Appears in:_
- [ResourceBindingSpec](#resourcebindingspec)
- [SchedulingPolicySnapshotStatus](#schedulingpolicysnapshotstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterName` _string_ | ClusterName is the name of the ManagedCluster. If it is not empty, its value should be unique cross all<br />placement decisions for the Placement. |  | Required: \{\} <br /> |
| `selected` _boolean_ | Selected indicates if this cluster is selected by the scheduler. |  |  |
| `clusterScore` _[ClusterScore](#clusterscore)_ | ClusterScore represents the score of the cluster calculated by the scheduler. |  |  |
| `reason` _string_ | Reason represents the reason why the cluster is selected or not. |  |  |


#### ClusterResourceBinding



ClusterResourceBinding represents a scheduling decision that binds a group of resources to a cluster.
It MUST have a label named `CRPTrackingLabel` that points to the cluster resource policy that creates it.



_Appears in:_
- [ClusterResourceBindingList](#clusterresourcebindinglist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `ClusterResourceBinding` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ResourceBindingSpec](#resourcebindingspec)_ | The desired state of ClusterResourceBinding. |  |  |
| `status` _[ResourceBindingStatus](#resourcebindingstatus)_ | The observed status of ClusterResourceBinding. |  |  |




#### ClusterResourcePlacement



ClusterResourcePlacement is used to select cluster scoped resources, including built-in resources and custom resources,
and placement them onto selected member clusters in a fleet.


If a namespace is selected, ALL the resources under the namespace are placed to the target clusters.
Note that you can't select the following resources:
  - reserved namespaces including: default, kube-* (reserved for Kubernetes system namespaces),
    fleet-* (reserved for fleet system namespaces).
  - reserved fleet resource types including: MemberCluster, InternalMemberCluster, ClusterResourcePlacement,
    ClusterSchedulingPolicySnapshot, ClusterResourceSnapshot, ClusterResourceBinding, etc.


`ClusterSchedulingPolicySnapshot` and `ClusterResourceSnapshot` objects are created when there are changes in the
system to keep the history of the changes affecting a `ClusterResourcePlacement`.



_Appears in:_
- [ClusterResourcePlacementList](#clusterresourceplacementlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `ClusterResourcePlacement` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ClusterResourcePlacementSpec](#clusterresourceplacementspec)_ | The desired state of ClusterResourcePlacement. |  | Required: \{\} <br /> |
| `status` _[ClusterResourcePlacementStatus](#clusterresourceplacementstatus)_ | The observed status of ClusterResourcePlacement. |  | Optional: \{\} <br /> |




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
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
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
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `ClusterResourcePlacementEviction` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[PlacementEvictionSpec](#placementevictionspec)_ | Spec is the desired state of the ClusterResourcePlacementEviction.<br /><br />Note that all fields in the spec are immutable. |  |  |
| `status` _[PlacementEvictionStatus](#placementevictionstatus)_ | Status is the observed state of the ClusterResourcePlacementEviction. |  |  |






#### ClusterResourcePlacementSpec



ClusterResourcePlacementSpec defines the desired state of ClusterResourcePlacement.



_Appears in:_
- [ClusterResourcePlacement](#clusterresourceplacement)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `resourceSelectors` _[ClusterResourceSelector](#clusterresourceselector) array_ | ResourceSelectors is an array of selectors used to select cluster scoped resources. The selectors are `ORed`.<br />You can have 1-100 selectors. |  | MaxItems: 100 <br />MinItems: 1 <br />Required: \{\} <br /> |
| `policy` _[PlacementPolicy](#placementpolicy)_ | Policy defines how to select member clusters to place the selected resources.<br />If unspecified, all the joined member clusters are selected. |  | Optional: \{\} <br /> |
| `strategy` _[RolloutStrategy](#rolloutstrategy)_ | The rollout strategy to use to replace existing placement with new ones. |  | Optional: \{\} <br /> |
| `revisionHistoryLimit` _integer_ | The number of old ClusterSchedulingPolicySnapshot or ClusterResourceSnapshot resources to retain to allow rollback.<br />This is a pointer to distinguish between explicit zero and not specified.<br />Defaults to 10. | 10 | Maximum: 1000 <br />Minimum: 1 <br />Optional: \{\} <br /> |


#### ClusterResourcePlacementStatus



ClusterResourcePlacementStatus defines the observed state of the ClusterResourcePlacement object.



_Appears in:_
- [ClusterResourcePlacement](#clusterresourceplacement)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `selectedResources` _[ResourceIdentifier](#resourceidentifier) array_ | SelectedResources contains a list of resources selected by ResourceSelectors. |  | Optional: \{\} <br /> |
| `observedResourceIndex` _string_ | Resource index logically represents the generation of the selected resources.<br />We take a new snapshot of the selected resources whenever the selection or their content change.<br />Each snapshot has a different resource index.<br />One resource snapshot can contain multiple clusterResourceSnapshots CRs in order to store large amount of resources.<br />To get clusterResourceSnapshot of a given resource index, use the following command:<br />`kubectl get ClusterResourceSnapshot --selector=kubernetes-fleet.io/resource-index=$ObservedResourceIndex `<br />ObservedResourceIndex is the resource index that the conditions in the ClusterResourcePlacementStatus observe.<br />For example, a condition of `ClusterResourcePlacementWorkSynchronized` type<br />is observing the synchronization status of the resource snapshot with the resource index $ObservedResourceIndex. |  | Optional: \{\} <br /> |
| `placementStatuses` _[ResourcePlacementStatus](#resourceplacementstatus) array_ | PlacementStatuses contains a list of placement status on the clusters that are selected by PlacementPolicy.<br />Each selected cluster according to the latest resource placement is guaranteed to have a corresponding placementStatuses.<br />In the pickN case, there are N placement statuses where N = NumberOfClusters; Or in the pickFixed case, there are<br />N placement statuses where N = ClusterNames.<br />In these cases, some of them may not have assigned clusters when we cannot fill the required number of clusters.<br />TODO, For pickAll type, considering providing unselected clusters info. |  | Optional: \{\} <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ClusterResourcePlacement. |  | Optional: \{\} <br /> |


#### ClusterResourceSelector



ClusterResourceSelector is used to select cluster scoped resources as the target resources to be placed.
If a namespace is selected, ALL the resources under the namespace are selected automatically.
All the fields are `ANDed`. In other words, a resource must match all the fields to be selected.



_Appears in:_
- [ClusterResourceOverrideSpec](#clusterresourceoverridespec)
- [ClusterResourcePlacementSpec](#clusterresourceplacementspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group name of the cluster-scoped resource.<br />Use an empty string to select resources under the core API group (e.g., namespaces). |  | Required: \{\} <br /> |
| `version` _string_ | Version of the cluster-scoped resource. |  | Required: \{\} <br /> |
| `kind` _string_ | Kind of the cluster-scoped resource.<br />Note: When `Kind` is `namespace`, ALL the resources under the selected namespaces are selected. |  | Required: \{\} <br /> |
| `name` _string_ | Name of the cluster-scoped resource. |  | Optional: \{\} <br /> |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#labelselector-v1-meta)_ | A label query over all the cluster-scoped resources. Resources matching the query are selected.<br />Note that namespace-scoped resources can't be selected even if they match the query. |  | Optional: \{\} <br /> |


#### ClusterResourceSnapshot



ClusterResourceSnapshot is used to store a snapshot of selected resources by a resource placement policy.
Its spec is immutable.
We may need to produce more than one resourceSnapshot for all the resources a ResourcePlacement selected to get around the 1MB size limit of k8s objects.
We assign an ever-increasing index for each such group of resourceSnapshots.
The naming convention of a clusterResourceSnapshot is {CRPName}-{resourceIndex}-{subindex}
where the name of the first snapshot of a group has no subindex part so its name is {CRPName}-{resourceIndex}-snapshot.
resourceIndex will begin with 0.
Each snapshot MUST have the following labels:
  - `CRPTrackingLabel` which points to its owner CRP.
  - `ResourceIndexLabel` which is the index  of the snapshot group.
  - `IsLatestSnapshotLabel` which indicates whether the snapshot is the latest one.


All the snapshots within the same index group must have the same ResourceIndexLabel.


The first snapshot of the index group MUST have the following annotations:
  - `NumberOfResourceSnapshotsAnnotation` to store the total number of resource snapshots in the index group.
  - `ResourceGroupHashAnnotation` whose value is the sha-256 hash of all the snapshots belong to the same snapshot index.


Each snapshot (excluding the first snapshot) MUST have the following annotations:
  - `SubindexOfResourceSnapshotAnnotation` to store the subindex of resource snapshot in the group.



_Appears in:_
- [ClusterResourceSnapshotList](#clusterresourcesnapshotlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `ClusterResourceSnapshot` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[ResourceSnapshotSpec](#resourcesnapshotspec)_ | The desired state of ResourceSnapshot. |  |  |
| `status` _[ResourceSnapshotStatus](#resourcesnapshotstatus)_ | The observed status of ResourceSnapshot. |  |  |




#### ClusterSchedulingPolicySnapshot



ClusterSchedulingPolicySnapshot is used to store a snapshot of cluster placement policy.
Its spec is immutable.
The naming convention of a ClusterSchedulingPolicySnapshot is {CRPName}-{PolicySnapshotIndex}.
PolicySnapshotIndex will begin with 0.
Each snapshot must have the following labels:
  - `CRPTrackingLabel` which points to its owner CRP.
  - `PolicyIndexLabel` which is the index of the policy snapshot.
  - `IsLatestSnapshotLabel` which indicates whether the snapshot is the latest one.



_Appears in:_
- [ClusterSchedulingPolicySnapshotList](#clusterschedulingpolicysnapshotlist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `ClusterSchedulingPolicySnapshot` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[SchedulingPolicySnapshotSpec](#schedulingpolicysnapshotspec)_ | The desired state of SchedulingPolicySnapshot. |  |  |
| `status` _[SchedulingPolicySnapshotStatus](#schedulingpolicysnapshotstatus)_ | The observed status of SchedulingPolicySnapshot. |  |  |




#### ClusterScore



ClusterScore represents the score of the cluster calculated by the scheduler.



_Appears in:_
- [ClusterDecision](#clusterdecision)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `affinityScore` _integer_ | AffinityScore represents the affinity score of the cluster calculated by the last<br />scheduling decision based on the preferred affinity selector.<br />An affinity score may not present if the cluster does not meet the required affinity. |  |  |
| `priorityScore` _integer_ | TopologySpreadScore represents the priority score of the cluster calculated by the last<br />scheduling decision based on the topology spread applied to the cluster.<br />A priority score may not present if the cluster does not meet the topology spread. |  |  |


#### ClusterSelector







_Appears in:_
- [ClusterAffinity](#clusteraffinity)
- [OverrideRule](#overriderule)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterSelectorTerms` _[ClusterSelectorTerm](#clusterselectorterm) array_ | ClusterSelectorTerms is a list of cluster selector terms. The terms are `ORed`. |  | MaxItems: 10 <br />Required: \{\} <br /> |


#### ClusterSelectorTerm

_Underlying type:_ _[struct{LabelSelector *k8s.io/apimachinery/pkg/apis/meta/v1.LabelSelector "json:\"labelSelector,omitempty\""; PropertySelector *PropertySelector "json:\"propertySelector,omitempty\""; PropertySorter *PropertySorter "json:\"propertySorter,omitempty\""}](#struct{labelselector-*k8sioapimachinerypkgapismetav1labelselector-"json:\"labelselector,omitempty\"";-propertyselector-*propertyselector-"json:\"propertyselector,omitempty\"";-propertysorter-*propertysorter-"json:\"propertysorter,omitempty\""})_





_Appears in:_
- [PreferredClusterSelector](#preferredclusterselector)



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
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
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
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
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




#### ComparisonOptionType

_Underlying type:_ _string_

ComparisonOptionType describes the compare option that Fleet uses to detect drifts and/or
calculate differences.



_Appears in:_
- [ApplyStrategy](#applystrategy)

| Field | Description |
| --- | --- |
| `PartialComparison` | ComparisonOptionTypePartialComparison will compare only fields that are managed by Fleet, i.e.,<br />fields that are specified explicitly in the hub cluster manifest. Unmanaged fields<br />are ignored.<br /> |
| `FullComparison` | ComparisonOptionTypeFullDiff will compare all fields of the resource, even if the fields<br />are absent from the hub cluster manifest.<br /> |


#### DiffDetails



DiffDetails describes the observed configuration differences.



_Appears in:_
- [ManifestCondition](#manifestcondition)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `observationTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | ObservationTime is the timestamp when the configuration difference was last detected. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `observedInMemberClusterGeneration` _integer_ | ObservedInMemberClusterGeneration is the generation of the applied manifest on the member<br />cluster side.<br /><br />This might be nil if the resource has not been created yet in the member cluster. |  | Optional: \{\} <br /> |
| `firstDiffedObservedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | FirsftDiffedObservedTime is the timestamp when the configuration difference<br />was first detected. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `observedDiffs` _[PatchDetail](#patchdetail) array_ | ObservedDiffs describes each field with configuration difference as found from the<br />member cluster side.<br /><br />Fleet might truncate the details as appropriate to control object size.<br /><br />Each entry specifies how the live state (the state on the member cluster side) compares<br />against the desired state (the state kept in the hub cluster manifest). |  | Optional: \{\} <br /> |


#### DiffedResourcePlacement



DiffedResourcePlacement contains the details of a resource with configuration differences.



_Appears in:_
- [ResourceBindingStatus](#resourcebindingstatus)
- [ResourcePlacementStatus](#resourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group is the group name of the selected resource. |  | Optional: \{\} <br /> |
| `version` _string_ | Version is the version of the selected resource. |  | Required: \{\} <br /> |
| `kind` _string_ | Kind represents the Kind of the selected resources. |  | Required: \{\} <br /> |
| `name` _string_ | Name of the target resource. |  | Required: \{\} <br /> |
| `namespace` _string_ | Namespace is the namespace of the resource. Empty if the resource is cluster scoped. |  | Optional: \{\} <br /> |
| `envelope` _[EnvelopeIdentifier](#envelopeidentifier)_ | Envelope identifies the envelope object that contains this resource. |  | Optional: \{\} <br /> |
| `observationTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | ObservationTime is the time when we observe the configuration differences for the resource. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `targetClusterObservedGeneration` _integer_ | TargetClusterObservedGeneration is the generation of the resource on the target cluster<br />that contains the configuration differences.<br /><br />This might be nil if the resource has not been created yet on the target cluster. |  | Optional: \{\} <br /> |
| `firstDiffedObservedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | FirstDiffedObservedTime is the first time the resource on the target cluster is<br />observed to have configuration differences. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `observedDiffs` _[PatchDetail](#patchdetail) array_ | ObservedDiffs are the details about the found configuration differences. Note that<br />Fleet might truncate the details as appropriate to control the object size.<br /><br />Each detail entry specifies how the live state (the state on the member<br />cluster side) compares against the desired state (the state kept in the hub cluster manifest).<br /><br />An event about the details will be emitted as well. |  | Optional: \{\} <br /> |


#### DriftDetails



DriftDetails describes the observed configuration drifts.



_Appears in:_
- [ManifestCondition](#manifestcondition)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `observationTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | ObservationTime is the timestamp when the drift was last detected. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `observedInMemberClusterGeneration` _integer_ | ObservedInMemberClusterGeneration is the generation of the applied manifest on the member<br />cluster side. |  | Required: \{\} <br /> |
| `firstDriftedObservedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | FirsftDriftedObservedTime is the timestamp when the drift was first detected. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `observedDrifts` _[PatchDetail](#patchdetail) array_ | ObservedDrifts describes each drifted field found from the applied manifest.<br />Fleet might truncate the details as appropriate to control object size.<br /><br />Each entry specifies how the live state (the state on the member cluster side) compares<br />against the desired state (the state kept in the hub cluster manifest). |  | Optional: \{\} <br /> |


#### DriftedResourcePlacement



DriftedResourcePlacement contains the details of a resource with configuration drifts.



_Appears in:_
- [ResourceBindingStatus](#resourcebindingstatus)
- [ResourcePlacementStatus](#resourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group is the group name of the selected resource. |  | Optional: \{\} <br /> |
| `version` _string_ | Version is the version of the selected resource. |  | Required: \{\} <br /> |
| `kind` _string_ | Kind represents the Kind of the selected resources. |  | Required: \{\} <br /> |
| `name` _string_ | Name of the target resource. |  | Required: \{\} <br /> |
| `namespace` _string_ | Namespace is the namespace of the resource. Empty if the resource is cluster scoped. |  | Optional: \{\} <br /> |
| `envelope` _[EnvelopeIdentifier](#envelopeidentifier)_ | Envelope identifies the envelope object that contains this resource. |  | Optional: \{\} <br /> |
| `observationTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | ObservationTime is the time when we observe the configuration drifts for the resource. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `targetClusterObservedGeneration` _integer_ | TargetClusterObservedGeneration is the generation of the resource on the target cluster<br />that contains the configuration drifts. |  | Required: \{\} <br /> |
| `firstDriftedObservedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#time-v1-meta)_ | FirstDriftedObservedTime is the first time the resource on the target cluster is<br />observed to have configuration drifts. |  | Format: date-time <br />Required: \{\} <br />Type: string <br /> |
| `observedDrifts` _[PatchDetail](#patchdetail) array_ | ObservedDrifts are the details about the found configuration drifts. Note that<br />Fleet might truncate the details as appropriate to control the object size.<br /><br />Each detail entry specifies how the live state (the state on the member<br />cluster side) compares against the desired state (the state kept in the hub cluster manifest).<br /><br />An event about the details will be emitted as well. |  | Optional: \{\} <br /> |


#### EnvelopeIdentifier



EnvelopeIdentifier identifies the envelope object that contains the selected resource.



_Appears in:_
- [DiffedResourcePlacement](#diffedresourceplacement)
- [DriftedResourcePlacement](#driftedresourceplacement)
- [FailedResourcePlacement](#failedresourceplacement)
- [ResourceIdentifier](#resourceidentifier)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | Name of the envelope object. |  | Required: \{\} <br /> |
| `namespace` _string_ | Namespace is the namespace of the envelope object. Empty if the envelope object is cluster scoped. |  | Optional: \{\} <br /> |
| `type` _[EnvelopeType](#envelopetype)_ | Type of the envelope object. | ConfigMap | Enum: [ConfigMap] <br />Optional: \{\} <br /> |


#### EnvelopeType

_Underlying type:_ _string_

EnvelopeType defines the type of the envelope object.



_Appears in:_
- [EnvelopeIdentifier](#envelopeidentifier)

| Field | Description |
| --- | --- |
| `ConfigMap` | ConfigMapEnvelopeType means the envelope object is of type `ConfigMap`.<br /> |


#### FailedResourcePlacement



FailedResourcePlacement contains the failure details of a failed resource placement.



_Appears in:_
- [ResourceBindingStatus](#resourcebindingstatus)
- [ResourcePlacementStatus](#resourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group is the group name of the selected resource. |  | Optional: \{\} <br /> |
| `version` _string_ | Version is the version of the selected resource. |  | Required: \{\} <br /> |
| `kind` _string_ | Kind represents the Kind of the selected resources. |  | Required: \{\} <br /> |
| `name` _string_ | Name of the target resource. |  | Required: \{\} <br /> |
| `namespace` _string_ | Namespace is the namespace of the resource. Empty if the resource is cluster scoped. |  | Optional: \{\} <br /> |
| `envelope` _[EnvelopeIdentifier](#envelopeidentifier)_ | Envelope identifies the envelope object that contains this resource. |  | Optional: \{\} <br /> |
| `condition` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta)_ | The failed condition status. |  | Required: \{\} <br /> |


#### Manifest



Manifest represents a resource to be deployed on spoke cluster.



_Appears in:_
- [WorkloadTemplate](#workloadtemplate)



#### ManifestCondition



ManifestCondition represents the conditions of the resources deployed on
spoke cluster.



_Appears in:_
- [WorkStatus](#workstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `identifier` _[WorkResourceIdentifier](#workresourceidentifier)_ | resourceId represents a identity of a resource linking to manifests in spec. |  |  |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions represents the conditions of this resource on spoke cluster |  |  |
| `driftDetails` _[DriftDetails](#driftdetails)_ | DriftDetails explains about the observed configuration drifts.<br />Fleet might truncate the details as appropriate to control object size.<br /><br />Note that configuration drifts can only occur on a resource if it is currently owned by<br />Fleet and its corresponding placement is set to use the ClientSideApply or ServerSideApply<br />apply strategy. In other words, DriftDetails and DiffDetails will not be populated<br />at the same time. |  | Optional: \{\} <br /> |
| `diffDetails` _[DiffDetails](#diffdetails)_ | DiffDetails explains the details about the observed configuration differences.<br />Fleet might truncate the details as appropriate to control object size.<br /><br />Note that configuration differences can only occur on a resource if it is not currently owned<br />by Fleet (i.e., it is a pre-existing resource that needs to be taken over), or if its<br />corresponding placement is set to use the ReportDiff apply strategy. In other words,<br />DiffDetails and DriftDetails will not be populated at the same time. |  | Optional: \{\} <br /> |


#### NamespacedName



NamespacedName comprises a resource name, with a mandatory namespace.



_Appears in:_
- [ClusterUpdatingStatus](#clusterupdatingstatus)
- [ClusterUpdatingStatus](#clusterupdatingstatus)
- [ResourceBindingSpec](#resourcebindingspec)
- [ResourcePlacementStatus](#resourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | Name is the name of the namespaced scope resource. |  | Required: \{\} <br /> |
| `namespace` _string_ | Namespace is namespace of the namespaced scope resource. |  | Required: \{\} <br /> |


#### PatchDetail



PatchDetail describes a patch that explains an observed configuration drift or
difference.


A patch detail can be transcribed as a JSON patch operation, as specified in RFC 6902.



_Appears in:_
- [DiffDetails](#diffdetails)
- [DiffedResourcePlacement](#diffedresourceplacement)
- [DriftDetails](#driftdetails)
- [DriftedResourcePlacement](#driftedresourceplacement)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `path` _string_ | The JSON path that points to a field that has drifted or has configuration differences. |  | Required: \{\} <br /> |
| `valueInMember` _string_ | The value at the JSON path from the member cluster side.<br /><br />This field can be empty if the JSON path does not exist on the member cluster side; i.e.,<br />applying the manifest from the hub cluster side would add a new field. |  | Optional: \{\} <br /> |
| `valueInHub` _string_ | The value at the JSON path from the hub cluster side.<br /><br />This field can be empty if the JSON path does not exist on the hub cluster side; i.e.,<br />applying the manifest from the hub cluster side would remove the field. |  | Optional: \{\} <br /> |


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


#### PlacementPolicy



PlacementPolicy contains the rules to select target member clusters to place the selected resources.
Note that only clusters that are both joined and satisfying the rules will be selected.


You can only specify at most one of the two fields: ClusterNames and Affinity.
If none is specified, all the joined clusters are selected.



_Appears in:_
- [ClusterResourcePlacementSpec](#clusterresourceplacementspec)
- [SchedulingPolicySnapshotSpec](#schedulingpolicysnapshotspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `placementType` _[PlacementType](#placementtype)_ | Type of placement. Can be "PickAll", "PickN" or "PickFixed". Default is PickAll. | PickAll | Enum: [PickAll PickN PickFixed] <br />Optional: \{\} <br /> |
| `clusterNames` _string array_ | ClusterNames contains a list of names of MemberCluster to place the selected resources.<br />Only valid if the placement type is "PickFixed" |  | MaxItems: 100 <br />Optional: \{\} <br /> |
| `numberOfClusters` _integer_ | NumberOfClusters of placement. Only valid if the placement type is "PickN". |  | Minimum: 0 <br />Optional: \{\} <br /> |
| `affinity` _[Affinity](#affinity)_ | Affinity contains cluster affinity scheduling rules. Defines which member clusters to place the selected resources.<br />Only valid if the placement type is "PickAll" or "PickN". |  | Optional: \{\} <br /> |
| `topologySpreadConstraints` _[TopologySpreadConstraint](#topologyspreadconstraint) array_ | TopologySpreadConstraints describes how a group of resources ought to spread across multiple topology<br />domains. Scheduler will schedule resources in a way which abides by the constraints.<br />All topologySpreadConstraints are ANDed.<br />Only valid if the placement type is "PickN". |  | Optional: \{\} <br /> |
| `tolerations` _[Toleration](#toleration) array_ | If specified, the ClusterResourcePlacement's Tolerations.<br />Tolerations cannot be updated or deleted.<br /><br />This field is beta-level and is for the taints and tolerations feature. |  | MaxItems: 100 <br />Optional: \{\} <br /> |


#### PlacementType

_Underlying type:_ _string_

PlacementType identifies the type of placement.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description |
| --- | --- |
| `PickAll` | PickAllPlacementType picks all clusters that satisfy the rules.<br /> |
| `PickN` | PickNPlacementType picks N clusters that satisfy the rules.<br /> |
| `PickFixed` | PickFixedPlacementType picks a fixed set of clusters.<br /> |


#### PreferredClusterSelector







_Appears in:_
- [ClusterAffinity](#clusteraffinity)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `weight` _integer_ | Weight associated with matching the corresponding clusterSelectorTerm, in the range [-100, 100]. |  | Maximum: 100 <br />Minimum: -100 <br />Required: \{\} <br /> |
| `preference` _[ClusterSelectorTerm](#clusterselectorterm)_ | A cluster selector term, associated with the corresponding weight. |  | Required: \{\} <br /> |




#### PropertySelectorOperator

_Underlying type:_ _string_

PropertySelectorOperator is the operator that can be used with PropertySelectorRequirements.



_Appears in:_
- [PropertySelectorRequirement](#propertyselectorrequirement)

| Field | Description |
| --- | --- |
| `Gt` | PropertySelectorGreaterThan dictates Fleet to select cluster if its observed value of a given<br />property is greater than the value specified in the requirement.<br /> |
| `Ge` | PropertySelectorGreaterThanOrEqualTo dictates Fleet to select cluster if its observed value<br />of a given property is greater than or equal to the value specified in the requirement.<br /> |
| `Eq` | PropertySelectorEqualTo dictates Fleet to select cluster if its observed value of a given<br />property is equal to the values specified in the requirement.<br /> |
| `Ne` | PropertySelectorNotEqualTo dictates Fleet to select cluster if its observed value of a given<br />property is not equal to the values specified in the requirement.<br /> |
| `Lt` | PropertySelectorLessThan dictates Fleet to select cluster if its observed value of a given<br />property is less than the value specified in the requirement.<br /> |
| `Le` | PropertySelectorLessThanOrEqualTo dictates Fleet to select cluster if its observed value of a<br />given property is less than or equal to the value specified in the requirement.<br /> |


#### PropertySelectorRequirement



PropertySelectorRequirement is a specific property requirement when picking clusters for
resource placement.



_Appears in:_
- [PropertySelector](#propertyselector)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `name` _string_ | Name is the name of the property; it should be a Kubernetes label name. |  | Required: \{\} <br /> |
| `operator` _[PropertySelectorOperator](#propertyselectoroperator)_ | Operator specifies the relationship between a cluster's observed value of the specified<br />property and the values given in the requirement. |  | Required: \{\} <br /> |
| `values` _string array_ | Values are a list of values of the specified property which Fleet will compare against<br />the observed values of individual member clusters in accordance with the given<br />operator.<br /><br />At this moment, each value should be a Kubernetes quantity. For more information, see<br />https://pkg.go.dev/k8s.io/apimachinery/pkg/api/resource#Quantity.<br /><br />If the operator is Gt (greater than), Ge (greater than or equal to), Lt (less than),<br />or `Le` (less than or equal to), Eq (equal to), or Ne (ne), exactly one value must be<br />specified in the list. |  | MaxItems: 1 <br />Required: \{\} <br /> |


#### PropertySortOrder

_Underlying type:_ _string_





_Appears in:_
- [PropertySorter](#propertysorter)

| Field | Description |
| --- | --- |
| `Descending` | Descending instructs Fleet to sort in descending order, that is, the clusters with higher<br />observed values of a property are most preferred and should have higher weights. We will<br />use linear scaling to calculate the weight for each cluster based on the observed values.<br />For example, with this order, if Fleet sorts all clusters by a specific property where the<br />observed values are in the range [10, 100], and a weight of 100 is specified;<br />Fleet will assign:<br />* a weight of 100 to the cluster with the maximum observed value (100); and<br />* a weight of 0 to the cluster with the minimum observed value (10); and<br />* a weight of 11 to the cluster with an observed value of 20.<br />  It is calculated using the formula below:<br />  ((20 - 10)) / (100 - 10)) * 100 = 11<br /> |
| `Ascending` | Ascending instructs Fleet to sort in ascending order, that is, the clusters with lower<br />observed values are most preferred and should have higher weights. We will use linear scaling<br />to calculate the weight for each cluster based on the observed values.<br />For example, with this order, if Fleet sorts all clusters by a specific property where<br />the observed values are in the range [10, 100], and a weight of 100 is specified;<br />Fleet will assign:<br />* a weight of 0 to the cluster with the  maximum observed value (100); and<br />* a weight of 100 to the cluster with the minimum observed value (10); and<br />* a weight of 89 to the cluster with an observed value of 20.<br />  It is calculated using the formula below:<br />  (1 - ((20 - 10) / (100 - 10))) * 100 = 89<br /> |






#### ResourceBindingSpec



ResourceBindingSpec defines the desired state of ClusterResourceBinding.



_Appears in:_
- [ClusterResourceBinding](#clusterresourcebinding)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `state` _[BindingState](#bindingstate)_ | The desired state of the binding. Possible values: Scheduled, Bound, Unscheduled. |  |  |
| `resourceSnapshotName` _string_ | ResourceSnapshotName is the name of the resource snapshot that this resource binding points to.<br />If the resources are divided into multiple snapshots because of the resource size limit,<br />it points to the name of the leading snapshot of the index group. |  |  |
| `resourceOverrideSnapshots` _[NamespacedName](#namespacedname) array_ | ResourceOverrideSnapshots is a list of ResourceOverride snapshots associated with the selected resources. |  |  |
| `clusterResourceOverrideSnapshots` _string array_ | ClusterResourceOverrides contains a list of applicable ClusterResourceOverride snapshot names associated with the<br />selected resources. |  |  |
| `schedulingPolicySnapshotName` _string_ | SchedulingPolicySnapshotName is the name of the scheduling policy snapshot that this resource binding<br />points to; more specifically, the scheduler creates this bindings in accordance with this<br />scheduling policy snapshot. |  |  |
| `targetCluster` _string_ | TargetCluster is the name of the cluster that the scheduler assigns the resources to. |  |  |
| `clusterDecision` _[ClusterDecision](#clusterdecision)_ | ClusterDecision explains why the scheduler selected this cluster. |  |  |
| `applyStrategy` _[ApplyStrategy](#applystrategy)_ | ApplyStrategy describes how to resolve the conflict if the resource to be placed already exists in the target cluster<br />and is owned by other appliers. |  |  |


#### ResourceBindingStatus



ResourceBindingStatus represents the current status of a ClusterResourceBinding.



_Appears in:_
- [ClusterResourceBinding](#clusterresourcebinding)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `failedPlacements` _[FailedResourcePlacement](#failedresourceplacement) array_ | FailedPlacements is a list of all the resources failed to be placed to the given cluster or the resource is unavailable.<br />Note that we only include 100 failed resource placements even if there are more than 100. |  | MaxItems: 100 <br /> |
| `driftedPlacements` _[DriftedResourcePlacement](#driftedresourceplacement) array_ | DriftedPlacements is a list of resources that have drifted from their desired states<br />kept in the hub cluster, as found by Fleet using the drift detection mechanism.<br /><br />To control the object size, only the first 100 drifted resources will be included.<br />This field is only meaningful if the `ClusterName` is not empty. |  | MaxItems: 100 <br />Optional: \{\} <br /> |
| `diffedPlacements` _[DiffedResourcePlacement](#diffedresourceplacement) array_ | DiffedPlacements is a list of resources that have configuration differences from their<br />corresponding hub cluster manifests. Fleet will report such differences when:<br /><br />* The CRP uses the ReportDiff apply strategy, which instructs Fleet to compare the hub<br />  cluster manifests against the live resources without actually performing any apply op; or<br />* Fleet finds a pre-existing resource on the member cluster side that does not match its<br />  hub cluster counterpart, and the CRP has been configured to only take over a resource if<br />  no configuration differences are found.<br /><br />To control the object size, only the first 100 diffed resources will be included.<br />This field is only meaningful if the `ClusterName` is not empty. |  | MaxItems: 100 <br />Optional: \{\} <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ClusterResourceBinding. |  |  |


#### ResourceContent



ResourceContent contains the content of a resource



_Appears in:_
- [ResourceSnapshotSpec](#resourcesnapshotspec)



#### ResourceIdentifier



ResourceIdentifier identifies one Kubernetes resource.



_Appears in:_
- [ClusterResourcePlacementStatus](#clusterresourceplacementstatus)
- [DiffedResourcePlacement](#diffedresourceplacement)
- [DriftedResourcePlacement](#driftedresourceplacement)
- [FailedResourcePlacement](#failedresourceplacement)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `group` _string_ | Group is the group name of the selected resource. |  | Optional: \{\} <br /> |
| `version` _string_ | Version is the version of the selected resource. |  | Required: \{\} <br /> |
| `kind` _string_ | Kind represents the Kind of the selected resources. |  | Required: \{\} <br /> |
| `name` _string_ | Name of the target resource. |  | Required: \{\} <br /> |
| `namespace` _string_ | Namespace is the namespace of the resource. Empty if the resource is cluster scoped. |  | Optional: \{\} <br /> |
| `envelope` _[EnvelopeIdentifier](#envelopeidentifier)_ | Envelope identifies the envelope object that contains this resource. |  | Optional: \{\} <br /> |




#### ResourcePlacementStatus



ResourcePlacementStatus represents the placement status of selected resources for one target cluster.



_Appears in:_
- [ClusterResourcePlacementStatus](#clusterresourceplacementstatus)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `clusterName` _string_ | ClusterName is the name of the cluster this resource is assigned to.<br />If it is not empty, its value should be unique cross all placement decisions for the Placement. |  | Optional: \{\} <br /> |
| `applicableResourceOverrides` _[NamespacedName](#namespacedname) array_ | ApplicableResourceOverrides contains a list of applicable ResourceOverride snapshots associated with the selected<br />resources.<br /><br />This field is alpha-level and is for the override policy feature. |  | Optional: \{\} <br /> |
| `applicableClusterResourceOverrides` _string array_ | ApplicableClusterResourceOverrides contains a list of applicable ClusterResourceOverride snapshots associated with<br />the selected resources.<br /><br />This field is alpha-level and is for the override policy feature. |  | Optional: \{\} <br /> |
| `failedPlacements` _[FailedResourcePlacement](#failedresourceplacement) array_ | FailedPlacements is a list of all the resources failed to be placed to the given cluster or the resource is unavailable.<br />Note that we only include 100 failed resource placements even if there are more than 100.<br />This field is only meaningful if the `ClusterName` is not empty. |  | MaxItems: 100 <br />Optional: \{\} <br /> |
| `driftedPlacements` _[DriftedResourcePlacement](#driftedresourceplacement) array_ | DriftedPlacements is a list of resources that have drifted from their desired states<br />kept in the hub cluster, as found by Fleet using the drift detection mechanism.<br /><br />To control the object size, only the first 100 drifted resources will be included.<br />This field is only meaningful if the `ClusterName` is not empty. |  | MaxItems: 100 <br />Optional: \{\} <br /> |
| `diffedPlacements` _[DiffedResourcePlacement](#diffedresourceplacement) array_ | DiffedPlacements is a list of resources that have configuration differences from their<br />corresponding hub cluster manifests. Fleet will report such differences when:<br /><br />* The CRP uses the ReportDiff apply strategy, which instructs Fleet to compare the hub<br />  cluster manifests against the live resources without actually performing any apply op; or<br />* Fleet finds a pre-existing resource on the member cluster side that does not match its<br />  hub cluster counterpart, and the CRP has been configured to only take over a resource if<br />  no configuration differences are found.<br /><br />To control the object size, only the first 100 diffed resources will be included.<br />This field is only meaningful if the `ClusterName` is not empty. |  | MaxItems: 100 <br />Optional: \{\} <br /> |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ResourcePlacementStatus. |  | Optional: \{\} <br /> |


#### ResourceSnapshotSpec



ResourceSnapshotSpec	defines the desired state of ResourceSnapshot.



_Appears in:_
- [ClusterResourceSnapshot](#clusterresourcesnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `selectedResources` _[ResourceContent](#resourcecontent) array_ | SelectedResources contains a list of resources selected by ResourceSelectors. |  |  |


#### ResourceSnapshotStatus







_Appears in:_
- [ClusterResourceSnapshot](#clusterresourcesnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for ResourceSnapshot. |  |  |


#### RollingUpdateConfig



RollingUpdateConfig contains the config to control the desired behavior of rolling update.



_Appears in:_
- [RolloutStrategy](#rolloutstrategy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `maxUnavailable` _[IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#intorstring-intstr-util)_ | The maximum number of clusters that can be unavailable during the rolling update<br />comparing to the desired number of clusters.<br />The desired number equals to the `NumberOfClusters` field when the placement type is `PickN`.<br />The desired number equals to the number of clusters scheduler selected when the placement type is `PickAll`.<br />Value can be an absolute number (ex: 5) or a percentage of the desired number of clusters (ex: 10%).<br />Absolute number is calculated from percentage by rounding up.<br />We consider a resource unavailable when we either remove it from a cluster or in-place<br />upgrade the resources content on the same cluster.<br />The minimum of MaxUnavailable is 0 to allow no downtime moving a placement from one cluster to another.<br />Please set it to be greater than 0 to avoid rolling out stuck during in-place resource update.<br />Defaults to 25%. | 25% | Optional: \{\} <br />Pattern: `^((100\|[0-9]\{1,2\})%\|[0-9]+)$` <br />XIntOrString: \{\} <br /> |
| `maxSurge` _[IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#intorstring-intstr-util)_ | The maximum number of clusters that can be scheduled above the desired number of clusters.<br />The desired number equals to the `NumberOfClusters` field when the placement type is `PickN`.<br />The desired number equals to the number of clusters scheduler selected when the placement type is `PickAll`.<br />Value can be an absolute number (ex: 5) or a percentage of desire (ex: 10%).<br />Absolute number is calculated from percentage by rounding up.<br />This does not apply to the case that we do in-place update of resources on the same cluster.<br />This can not be 0 if MaxUnavailable is 0.<br />Defaults to 25%. | 25% | Optional: \{\} <br />Pattern: `^((100\|[0-9]\{1,2\})%\|[0-9]+)$` <br />XIntOrString: \{\} <br /> |
| `unavailablePeriodSeconds` _integer_ | UnavailablePeriodSeconds is used to configure the waiting time between rollout phases when we<br />cannot determine if the resources have rolled out successfully or not.<br />We have a built-in resource state detector to determine the availability status of following well-known Kubernetes<br />native resources: Deployment, StatefulSet, DaemonSet, Service, Namespace, ConfigMap, Secret,<br />ClusterRole, ClusterRoleBinding, Role, RoleBinding.<br />Please see [SafeRollout](https://github.com/Azure/fleet/tree/main/docs/concepts/SafeRollout/README.md) for more details.<br />For other types of resources, we consider them as available after `UnavailablePeriodSeconds` seconds<br />have passed since they were successfully applied to the target cluster.<br />Default is 60. | 60 | Optional: \{\} <br /> |


#### RolloutStrategy



RolloutStrategy describes how to roll out a new change in selected resources to target clusters.



_Appears in:_
- [ClusterResourcePlacementSpec](#clusterresourceplacementspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `type` _[RolloutStrategyType](#rolloutstrategytype)_ | Type of rollout. The only supported types are "RollingUpdate" and "External".<br />Default is "RollingUpdate". | RollingUpdate | Enum: [RollingUpdate External] <br />Optional: \{\} <br /> |
| `rollingUpdate` _[RollingUpdateConfig](#rollingupdateconfig)_ | Rolling update config params. Present only if RolloutStrategyType = RollingUpdate. |  | Optional: \{\} <br /> |
| `applyStrategy` _[ApplyStrategy](#applystrategy)_ | ApplyStrategy describes when and how to apply the selected resources to the target cluster. |  | Optional: \{\} <br /> |


#### RolloutStrategyType

_Underlying type:_ _string_





_Appears in:_
- [RolloutStrategy](#rolloutstrategy)

| Field | Description |
| --- | --- |
| `RollingUpdate` | RollingUpdateRolloutStrategyType replaces the old placed resource using rolling update<br />i.e. gradually create the new one while replace the old ones.<br /> |
| `External` | ExternalRolloutStrategyType means there is an external rollout controller that will<br />handle the rollout of the resources.<br /> |




#### SchedulingPolicySnapshotSpec



SchedulingPolicySnapshotSpec defines the desired state of SchedulingPolicySnapshot.



_Appears in:_
- [ClusterSchedulingPolicySnapshot](#clusterschedulingpolicysnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `policy` _[PlacementPolicy](#placementpolicy)_ | Policy defines how to select member clusters to place the selected resources.<br />If unspecified, all the joined member clusters are selected. |  |  |
| `policyHash` _integer array_ | PolicyHash is the sha-256 hash value of the Policy field. |  |  |


#### SchedulingPolicySnapshotStatus



SchedulingPolicySnapshotStatus defines the observed state of SchedulingPolicySnapshot.



_Appears in:_
- [ClusterSchedulingPolicySnapshot](#clusterschedulingpolicysnapshot)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `observedCRPGeneration` _integer_ | ObservedCRPGeneration is the generation of the CRP which the scheduler uses to perform<br />the scheduling cycle and prepare the scheduling status. |  |  |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions is an array of current observed conditions for SchedulingPolicySnapshot. |  |  |
| `targetClusters` _[ClusterDecision](#clusterdecision) array_ | ClusterDecisions contains a list of names of member clusters considered by the scheduler.<br />Note that all the selected clusters must present in the list while not all the<br />member clusters are guaranteed to be listed due to the size limit. We will try to<br />add the clusters that can provide the most insight to the list first. |  | MaxItems: 1000 <br /> |


#### ServerSideApplyConfig



ServerSideApplyConfig defines the configuration for server side apply.
Details: https://kubernetes.io/docs/reference/using-api/server-side-apply/#conflicts



_Appears in:_
- [ApplyStrategy](#applystrategy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `force` _boolean_ | Force represents to force apply to succeed when resolving the conflicts<br />For any conflicting fields,<br />- If true, use the values from the resource to be applied to overwrite the values of the existing resource in the<br />target cluster, as well as take over ownership of such fields.<br />- If false, apply will fail with the reason ApplyConflictWithOtherApplier.<br /><br />For non-conflicting fields, values stay unchanged and ownership are shared between appliers. |  | Optional: \{\} <br /> |


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


#### Toleration



Toleration allows ClusterResourcePlacement to tolerate any taint that matches
the triple <key,value,effect> using the matching operator <operator>.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `key` _string_ | Key is the taint key that the toleration applies to. Empty means match all taint keys.<br />If the key is empty, operator must be Exists; this combination means to match all values and all keys. |  | Optional: \{\} <br /> |
| `operator` _[TolerationOperator](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#tolerationoperator-v1-core)_ | Operator represents a key's relationship to the value.<br />Valid operators are Exists and Equal. Defaults to Equal.<br />Exists is equivalent to wildcard for value, so that a<br />ClusterResourcePlacement can tolerate all taints of a particular category. | Equal | Enum: [Equal Exists] <br />Optional: \{\} <br /> |
| `value` _string_ | Value is the taint value the toleration matches to.<br />If the operator is Exists, the value should be empty, otherwise just a regular string. |  | Optional: \{\} <br /> |
| `effect` _[TaintEffect](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#tainteffect-v1-core)_ | Effect indicates the taint effect to match. Empty means match all taint effects.<br />When specified, only allowed value is NoSchedule. |  | Enum: [NoSchedule] <br />Optional: \{\} <br /> |


#### TopologySpreadConstraint



TopologySpreadConstraint specifies how to spread resources among the given cluster topology.



_Appears in:_
- [PlacementPolicy](#placementpolicy)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `maxSkew` _integer_ | MaxSkew describes the degree to which resources may be unevenly distributed.<br />When `whenUnsatisfiable=DoNotSchedule`, it is the maximum permitted difference<br />between the number of resource copies in the target topology and the global minimum.<br />The global minimum is the minimum number of resource copies in a domain.<br />When `whenUnsatisfiable=ScheduleAnyway`, it is used to give higher precedence<br />to topologies that satisfy it.<br />It's an optional field. Default value is 1 and 0 is not allowed. | 1 | Minimum: 1 <br />Optional: \{\} <br /> |
| `topologyKey` _string_ | TopologyKey is the key of cluster labels. Clusters that have a label with this key<br />and identical values are considered to be in the same topology.<br />We consider each <key, value> as a "bucket", and try to put balanced number<br />of replicas of the resource into each bucket honor the `MaxSkew` value.<br />It's a required field. |  | Required: \{\} <br /> |
| `whenUnsatisfiable` _[UnsatisfiableConstraintAction](#unsatisfiableconstraintaction)_ | WhenUnsatisfiable indicates how to deal with the resource if it doesn't satisfy<br />the spread constraint.<br />- DoNotSchedule (default) tells the scheduler not to schedule it.<br />- ScheduleAnyway tells the scheduler to schedule the resource in any cluster,<br />  but giving higher precedence to topologies that would help reduce the skew.<br />It's an optional field. |  | Optional: \{\} <br /> |


#### UnsatisfiableConstraintAction

_Underlying type:_ _string_

UnsatisfiableConstraintAction defines the type of actions that can be taken if a constraint is not satisfied.



_Appears in:_
- [TopologySpreadConstraint](#topologyspreadconstraint)

| Field | Description |
| --- | --- |
| `DoNotSchedule` | DoNotSchedule instructs the scheduler not to schedule the resource<br />onto the cluster when constraints are not satisfied.<br /> |
| `ScheduleAnyway` | ScheduleAnyway instructs the scheduler to schedule the resource<br />even if constraints are not satisfied.<br /> |


#### WhenToApplyType

_Underlying type:_ _string_

WhenToApplyType describes when Fleet would apply the manifests on the hub cluster to
the member clusters.



_Appears in:_
- [ApplyStrategy](#applystrategy)

| Field | Description |
| --- | --- |
| `Always` | WhenToApplyTypeAlways instructs Fleet to periodically apply hub cluster manifests<br />on the member cluster side; this will effectively overwrite any change in the fields<br />managed by Fleet (i.e., specified in the hub cluster manifest).<br /> |
| `IfNotDrifted` | WhenToApplyTypeIfNotDrifted instructs Fleet to stop applying hub cluster manifests on<br />clusters that have drifted from the desired state; apply ops would still continue on<br />the rest of the clusters.<br /> |


#### WhenToTakeOverType

_Underlying type:_ _string_

WhenToTakeOverType describes the type of the action to take when we first apply the
resources to the member cluster.



_Appears in:_
- [ApplyStrategy](#applystrategy)

| Field | Description |
| --- | --- |
| `IfNoDiff` | WhenToTakeOverTypeIfNoDiff instructs Fleet to apply a manifest with a corresponding<br />pre-existing resource on a member cluster if and only if the pre-existing resource<br />looks the same as the manifest. Should there be any inconsistency, Fleet will skip<br />the apply op; no change will be made on the resource and Fleet will not claim<br />ownership on it.<br />Note that this will not stop Fleet from processing other manifests in the same<br />placement that do not concern the takeover process (e.g., the manifests that have<br />not been created yet, or that are already under the management of Fleet).<br /> |
| `Always` | WhenToTakeOverTypeAlways instructs Fleet to always apply manifests to a member cluster,<br />even if there are some corresponding pre-existing resources. Some fields on these<br />resources might be overwritten, and Fleet will claim ownership on them.<br /> |
| `Never` | WhenToTakeOverTypeNever instructs Fleet to never apply a manifest to a member cluster<br />if there is a corresponding pre-existing resource.<br />Note that this will not stop Fleet from processing other manifests in the same placement<br />that do not concern the takeover process (e.g., the manifests that have not been created<br />yet, or that are already under the management of Fleet).<br />If you would like Fleet to stop processing manifests all together and do not assume<br />ownership on any pre-existing resources, use this option along with the ReportDiff<br />apply strategy type. This setup would instruct Fleet to touch nothing on the member<br />cluster side but still report configuration differences between the hub cluster<br />and member clusters. Fleet will not give up ownership that it has already assumed, though.<br /> |


#### Work



Work is the Schema for the works API.



_Appears in:_
- [WorkList](#worklist)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `Work` | | |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `spec` _[WorkSpec](#workspec)_ | spec defines the workload of a work. |  |  |
| `status` _[WorkStatus](#workstatus)_ | status defines the status of each applied manifest on the spoke cluster. |  |  |


#### WorkList



WorkList contains a list of Work.





| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `apiVersion` _string_ | `placement.kubernetes-fleet.io/v1beta1` | | |
| `kind` _string_ | `WorkList` | | |
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |  |  |
| `items` _[Work](#work) array_ | List of works. |  |  |


#### WorkResourceIdentifier



WorkResourceIdentifier provides the identifiers needed to interact with any arbitrary object.
Renamed original "ResourceIdentifier" so that it won't conflict with ResourceIdentifier defined in the clusterresourceplacement_types.go.



_Appears in:_
- [AppliedResourceMeta](#appliedresourcemeta)
- [ManifestCondition](#manifestcondition)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `ordinal` _integer_ | Ordinal represents an index in manifests list, so the condition can still be linked<br />to a manifest even though manifest cannot be parsed successfully. |  |  |
| `group` _string_ | Group is the group of the resource. |  |  |
| `version` _string_ | Version is the version of the resource. |  |  |
| `kind` _string_ | Kind is the kind of the resource. |  |  |
| `resource` _string_ | Resource is the resource type of the resource. |  |  |
| `namespace` _string_ | Namespace is the namespace of the resource, the resource is cluster scoped if the value<br />is empty. |  |  |
| `name` _string_ | Name is the name of the resource. |  |  |


#### WorkSpec



WorkSpec defines the desired state of Work.



_Appears in:_
- [Work](#work)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `workload` _[WorkloadTemplate](#workloadtemplate)_ | Workload represents the manifest workload to be deployed on spoke cluster |  |  |
| `applyStrategy` _[ApplyStrategy](#applystrategy)_ | ApplyStrategy describes how to resolve the conflict if the resource to be placed already exists in the target cluster<br />and is owned by other appliers. |  |  |


#### WorkStatus



WorkStatus defines the observed state of Work.



_Appears in:_
- [Work](#work)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#condition-v1-meta) array_ | Conditions contains the different condition statuses for this work.<br />Valid condition types are:<br />1. Applied represents workload in Work is applied successfully on the spoke cluster.<br />2. Progressing represents workload in Work in the transitioning from one state to another the on the spoke cluster.<br />3. Available represents workload in Work exists on the spoke cluster.<br />4. Degraded represents the current state of workload does not match the desired<br />state for a certain period. |  |  |
| `manifestConditions` _[ManifestCondition](#manifestcondition) array_ | ManifestConditions represents the conditions of each resource in work deployed on<br />spoke cluster. |  |  |


#### WorkloadTemplate



WorkloadTemplate represents the manifest workload to be deployed on spoke cluster



_Appears in:_
- [WorkSpec](#workspec)

| Field | Description | Default | Validation |
| --- | --- | --- | --- |
| `manifests` _[Manifest](#manifest) array_ | Manifests represents a list of kubernetes resources to be deployed on the spoke cluster. |  |  |


