---
title: ResourcePlacement
description: Concept about the ResourcePlacement API
weight: 4
---

## Overview

`ResourcePlacement` is a namespace-scoped API that enables dynamic selection and multi-cluster propagation of namespace-scoped resources. It provides fine-grained control over how specific resources within a namespace are distributed across member clusters in a fleet.

**Key Characteristics:**
- **Namespace-scoped**: Both the ResourcePlacement object and the resources it manages exist within the same namespace
- **Selective**: Can target specific resources by type, name, or labels rather than entire namespaces
- **Declarative**: Uses the same placement patterns as ClusterResourcePlacement for consistent behavior

A ResourcePlacement consists of three core components:
- **Resource Selectors**: Define which namespace-scoped resources to include
- **Placement Policy**: Determine target clusters using PickAll, PickFixed, or PickN strategies  
- **Rollout Strategy**: Control how changes propagate across selected clusters

For detailed examples and implementation guidance, see the [ResourcePlacement How-To Guide](/docs/how-tos/resource-placement).

## Motivation

In multi-cluster environments, workloads often consist of both cluster-scoped and namespace-scoped resources that need to be distributed across different clusters. While `ClusterResourcePlacement` (CRP) handles cluster-scoped resources effectively, particularly entire namespaces and their contents, there are scenarios where you need more granular control over namespace-scoped resources within existing namespaces.

`ResourcePlacement` (RP) was designed to address this gap by providing:

- **Namespace-scoped resource management**: Target specific resources within a namespace without affecting the entire namespace
- **Operational flexibility**: Allow different teams to manage different resources within the same namespace independently
- **Complementary functionality**: Work alongside CRP to provide a complete multi-cluster resource management solution

### Key Differences Between ResourcePlacement and ClusterResourcePlacement

| Aspect | ResourcePlacement (RP) | ClusterResourcePlacement (CRP) |
|--------|------------------------|--------------------------------|
| **Scope** | Namespace-scoped resources only | Cluster-scoped resources (especially namespaces and their contents) |
| **Resource** | Namespace-scoped API object | Cluster-scoped API object |
| **Selection Boundary** | Limited to resources within the same namespace as the RP | Can select any cluster-scoped resource |
| **Typical Use Cases** | Individual ConfigMaps, Secrets, Services within existing namespaces | Entire namespaces, ClusterRoles, cluster-wide policies |
| **Team Ownership** | Can be managed by namespace owners/developers | Typically managed by platform operators |

### Similarities Between ResourcePlacement and ClusterResourcePlacement

Both RP and CRP share the same core concepts and capabilities:

- **Placement Policies**: Same three placement types (PickAll, PickFixed, PickN) with identical scheduling logic
- **Resource Selection**: Both support selection by group/version/kind, name, and label selectors
- **Rollout Strategy**: Identical rolling update mechanisms for zero-downtime deployments
- **Scheduling Framework**: Use the same multi-cluster scheduler with filtering, scoring, and binding phases
- **Override Support**: Both integrate with ClusterResourceOverride and ResourceOverride for resource customization
- **Status Reporting**: Similar status structures and condition types for placement tracking
- **Tolerations**: Same taints and tolerations mechanism for cluster selection
- **Snapshot Architecture**: Both use immutable snapshots (ResourceSnapshot vs ClusterResourceSnapshot) for resource and policy tracking

This design allows teams familiar with one placement object to easily understand and use the other, while providing the appropriate level of control for different resource scopes.

## When To Use ResourcePlacement

ResourcePlacement is ideal for scenarios requiring granular control over namespace-scoped resources:

- **Selective Resource Distribution**: Deploy specific ConfigMaps, Secrets, or Services without affecting the entire namespace
- **Multi-tenant Environments**: Allow different teams to manage their resources independently within shared namespaces
- **Configuration Management**: Distribute environment-specific configurations across different cluster environments
- **Compliance and Governance**: Apply different policies to different resource types within the same namespace
- **Progressive Rollouts**: Safely deploy resource updates across clusters with zero-downtime strategies

For practical examples and step-by-step instructions, see the [ResourcePlacement How-To Guide](/docs/how-tos/resource-placement).

## Core Concepts

ResourcePlacement orchestrates multi-cluster resource distribution through a coordinated system of controllers and snapshots that work together to ensure consistent, reliable deployments.

### The Complete Flow

![](/images/en/docs/concepts/crpc/placement-concept-overview.jpg)

When you create a ResourcePlacement, the system initiates a multi-stage process:

1. **Resource Selection & Snapshotting**: The placement controller identifies resources matching your selectors and creates immutable `ResourceSnapshot` objects capturing their current state
2. **Policy Evaluation & Snapshotting**: Placement policies are evaluated and captured in `SchedulingPolicySnapshot` objects to ensure stable scheduling decisions
3. **Multi-Cluster Scheduling**: The scheduler processes policy snapshots to determine target clusters through filtering, scoring, and selection
4. **Resource Binding**: Selected clusters are bound to specific resource snapshots via `ResourceBinding` objects
5. **Rollout Execution**: The rollout controller applies resources to target clusters according to the rollout strategy
6. **Override Processing**: Environment-specific customizations are applied through override controllers
7. **Work Generation**: Individual `Work` objects are created for each target cluster containing the final resource manifests
8. **Cluster Application**: Work controllers on member clusters apply the resources locally and report status back

### Status and Observability

ResourcePlacement provides comprehensive status reporting to track deployment progress:

- **Overall Status**: High-level conditions indicating scheduling, rollout, and availability states
- **Per-Cluster Status**: Individual status for each target cluster showing detailed progress
- **Events**: Timeline of placement activities and any issues encountered

Status information helps operators understand deployment progress, troubleshoot issues, and ensure resources are successfully propagated across the fleet.

For detailed troubleshooting guidance, see the [ResourcePlacement Troubleshooting Guide](/docs/troubleshooting/ResourcePlacement).

## Advanced Features

### Tolerations

ResourcePlacement supports Kubernetes-style taints and tolerations for advanced cluster selection. This enables:
- **Cluster Specialization**: Reserve clusters for specific workload types
- **Compliance Requirements**: Ensure resources only deploy to compliant clusters  
- **Resource Isolation**: Separate different classes of workloads

Tolerations allow ResourcePlacement to target clusters with specific taints, providing fine-grained control over placement decisions.

For detailed configuration examples, see the [Taints and Tolerations How-To Guide](/docs/how-tos/taints-tolerations).

### Envelope Objects

ResourcePlacement treats the hub cluster as a staging environment where resources are prepared for distribution rather than local execution. For resources that might cause unintended side effects when created on the hub cluster, envelope objects provide a safe encapsulation mechanism.

This approach ensures that resources like Network Policies or Resource Quotas don't interfere with hub cluster operations while still being properly distributed to target clusters.

For implementation details, see the [Envelope Object How-To Guide](/docs/how-tos/envelope-object).