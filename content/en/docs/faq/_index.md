---
title: Frequently Asked Questions
description: Frequently Asked Questions about KubeFleet
weight: 6
---

## What are the KubeFleet-owned resources on the hub and member clusters? Can these KubeFleet-owned resources be modified by the user?

KubeFleet reserves all namespaces with the prefix `fleet-`, such as `fleet-system` and `fleet-member-YOUR-CLUSTER-NAME` where
`YOUR-CLUSTER-NAME` are names of member clusters that have joined the fleet. Additionally, KubeFleet will skip resources
under namespaces with the prefix `kube-`.

KubeFleet-owned **internal** resources on the hub cluster side include:

| Resource                           |
|------------------------------------|
| `InternalMemberCluster`            |
| `Work`                             |
| `ClusterResourceSnapshot`          |
| `ClusterSchedulingPolicySnapshot`  |
| `ClusterResourceBinding`           |
| `ResourceOverrideSnapshots`        |
| `ClusterResourceOverrideSnapshots` |

And the public APIs exposed by KubeFleet are:

| Resource                                    |
|---------------------------------------------|
| `ClusterResourcePlacement`                  |
| `ClusterResourceEnvelope`                   |
| `ResourceEnvelope`                          |
| `ClusterStagedUpdateRun`                    |
| `ClusterStagedUpdateRunStrategy`            |
| `ClusterApprovalRequests`                   |
| `ClusterResourceOverrides`                  |
| `ResourceOverrides`                         |
| `ClusterResourcePlacementDisruptionBudgets` |
| `ClusterResourcePlacementEvictions`         |

The following resources are the KubeFleet-owned **internal** resources on the member cluster side:

| Resource                |
|-------------------------|
| `AppliedWork`           |

See the [KubeFleet source code](https://github.com/kubefleet-dev/kubefleet/tree/main/apis) for the definitions of these APIs.

Depending on your setup, your environment might feature a few KubeFleet provided webhooks that help safeguard
the KubeFleet internal resources and the KubeFleet reserved namespaces.

## Which kinds of resources can be propagated from the hub cluster to the member clusters? How can I control the list?

When you use the `ClusterResourcePlacement` API to select resources for placement, KubeFleet will automatically ignore
certain Kubernetes resource groups and/or GVKs. The resources exempted from placement include:

- Pods and Nodes
- All resources in the `events.k8s.io` resource group.
- All resources in the `coordination.k8s.io` resource group.
- All resources in the `metrics.k8s.io` resource group.
- All KubeFleet internal resources.

Refer to the [KubeFleet source code](https://github.com/kubefleet-dev/kubefleet/blob/main/pkg/utils/apiresources.go) for more
information. In addition, KubeFleet will refuse to place the `default` namespace on the hub cluster to member clusters.

If you would like to enforce additional restrictions, set up the `skipped-propagating-apis` and/or the `skipped-propagating-namespaces` flag on the KubeFleet hub agent, which blocks a specific resource type or a specific
namespace for placement respectively.

You may also specify the `allowed-propagating-apis` flag on the KubeFleet hub agent to explicitly dictate
a number of resource types that can be placed via KubeFleet; all resource types not on the whitelist will not be
selected by KubeFleet for placement. Note that this flag is mutually exclusive with the `skipped-propagating-apis` flag.

## What happens to existing resources in member clusters when their configuration is in conflict from their hub cluster counterparts?

By default, when KubeFleet encounters a pre-existing resource on the member cluster side, it will attempt to assume
ownership of the resource and overwrite its configuration with values from the hub cluster. You may use apply strategies
to fine-tune this behavior: for example, you may choose to let KubeFleet ignore all pre-existing resources, or let
KubeFleet check if the configuration is consistent between the hub cluster end and the member cluster end before KubeFleet
applies a manifest. For more information, see the KubeFleet documentation on takeover policies.

## What happens if I modify a resource on the hub cluster that has been placed to member clusters? What happens if I modify a resource on the member cluster that is managed by KubeFleet?

If you write a resource on the hub cluster end, KubeFleet will synchronize your changes to all selected member clusters automatically.
Specifically, when you update a resource, your changes will be applied to all member clusters; should you choose to delete a
resource, it will be removed from all member clusters as well.

By default, KubeFleet will attempt to overwrite changes made on the member cluster side if the modified fields are managed by KubeFleet. If you choose to delete a KubeFleet-managed resource, KubeFleet will re-create it shortly. You can fine-tune this
behavior via KubeFleet apply strategies: KubeFleet can help you detect such changes (often known as configuration drifts),
preserve them as necessary, or overwrite them to keep the resources in sync. For more information, see the KubeFleet documentation
on drift detection capabilities.
