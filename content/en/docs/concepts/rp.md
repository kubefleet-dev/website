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
- **Operational flexibility**: Allow a team to manage different resources within the same namespace independently
- **Complementary functionality**: Work alongside CRP to provide a complete multi-cluster resource management solution

**Note**: `ResourcePlacement` can be used together with `ClusterResourcePlacement` in namespace-only mode. For example, you can use CRP to deploy the namespace, while using RP for fine-grained management of specific resources like environment-specific ConfigMaps or Secrets within that namespace.

### Addressing Real-World Namespace Usage Patterns

While CRP assumes that namespaces represent application boundaries, real-world usage patterns are often more complex. Organizations frequently use namespaces as team boundaries rather than application boundaries, leading to several challenges that ResourcePlacement directly addresses:

**Multi-Application Namespaces**: In many organizations, a single namespace contains multiple independent applications owned by the same team. These applications may have:
- Different lifecycle requirements (one application may need frequent updates while another remains stable)
- Different cluster placement needs (development vs. production applications)
- Independent scaling and resource requirements
- Separate compliance or governance requirements

**Individual Scheduling Decisions**: Many workloads, particularly AI/ML jobs, require individual scheduling decisions:
- **AI Jobs**: Machine learning workloads often consist of short-lived, resource-intensive jobs that need to be scheduled based on cluster resource availability, GPU availability, or data locality
- **Batch Workloads**: Different batch jobs within the same namespace may target different cluster types based on computational requirements


**Complete Application Team Control**: ResourcePlacement provides application teams with direct control over their resource placement without requiring platform team intervention:
- **Self-Service Operations**: Teams can manage their own resource distribution strategies
- **Independent Deployment Cycles**: Different applications within a namespace can have completely independent rollout schedules
- **Granular Override Capabilities**: Teams can customize resource configurations per cluster without affecting other applications in the namespace

This granular approach ensures that ResourcePlacement can adapt to diverse organizational structures and workload patterns while maintaining the simplicity and power of the Fleet scheduling framework.

### Key Differences Between ResourcePlacement and ClusterResourcePlacement

| Aspect | ResourcePlacement (RP) | ClusterResourcePlacement (CRP) |
|--------|------------------------|--------------------------------|
| **Scope** | Namespace-scoped resources only | Cluster-scoped resources (especially namespaces and their contents) |
| **Resource** | Namespace-scoped API object | Cluster-scoped API object |
| **Selection Boundary** | Limited to resources within the same namespace as the RP | Can select any cluster-scoped resource |
| **Typical Use Cases** | AI/ML Jobs, individual workloads, specific ConfigMaps/Secrets that need independent placement decisions | Application bundles, entire namespaces, cluster-wide policies |
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

## Working with ClusterResourcePlacement

ResourcePlacement is designed to work in coordination with ClusterResourcePlacement (CRP) to provide a complete multi-cluster resource management solution. Understanding this relationship is crucial for effective fleet management.

### Namespace Prerequisites

**Important**: ResourcePlacement can only place namespace-scoped resources to clusters that already have the target namespace. This creates a fundamental dependency on ClusterResourcePlacement for namespace establishment.

**Typical Workflow**:
1. **Fleet Admin**: Uses ClusterResourcePlacement to deploy namespaces across the fleet
2. **Application Teams**: Use ResourcePlacement to manage specific resources within those established namespaces


```yaml
# Fleet admin creates namespace using CRP
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourcePlacement
metadata:
  name: app-namespace-crp
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      name: my-app
      version: v1
  policy:
    placementType: PickAll
---
# Application team manages resources using RP
apiVersion: placement.kubernetes-fleet.io/v1
kind: ResourcePlacement
metadata:
  name: app-configs-rp
  namespace: my-app
spec:
  resourceSelectors:
    - group: ""
      kind: ConfigMap
      version: v1
      labelSelector:
        matchLabels:
          app: my-application
  policy:
    placementType: PickFixed
    clusterNames: ["prod-cluster-1", "prod-cluster-2"]
```

### Best Practices

- **Establish Namespaces First**: Always ensure namespaces are deployed via CRP before creating ResourcePlacement objects
- **Monitor Dependencies**: Use Fleet monitoring to ensure namespace-level CRPs are healthy before deploying dependent RPs
- **Coordinate Policies**: Align CRP and RP placement policies to avoid conflicts (e.g., if CRP places namespace on clusters A,B,C, RP can target any subset of those clusters)
- **Team Boundaries**: Use CRP for platform-managed resources (namespaces, RBAC) and RP for application-managed resources (app configs, secrets)

This coordinated approach ensures that ResourcePlacement provides the flexibility teams need while maintaining the foundational infrastructure managed by platform operators.

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

ResourcePlacement supports the same advanced features as ClusterResourcePlacement. For detailed documentation on these features, see the corresponding sections in the [ClusterResourcePlacement Concept Guide - Advanced Features](crp.md#advanced-features).

