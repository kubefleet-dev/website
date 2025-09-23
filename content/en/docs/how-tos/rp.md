---
title: Using the ResourcePlacement API
description: How to use the `ResourcePlacement` API
weight: 3
---

This guide provides an overview of how to use the KubeFleet `ResourcePlacement` (RP) API to orchestrate workload distribution across your fleet.

> NOTE: The `ResourcePlacement` is a namespace-scoped CR.

## Overview

The RP API is a core KubeFleet API that facilitates the distribution of specific resources from the hub cluster to 
member clusters within a fleet. This API offers scheduling capabilities that allow you to target the most suitable 
group of clusters for a set of resources using a complex rule set. For example, you can distribute resources to
clusters in specific regions (North America, East Asia, Europe, etc.) and/or release stages (production, canary, etc.). 
You can even distribute resources according to certain topology spread constraints.

## API Components

The RP API generally consists of the following components:

- **Resource Selectors**: These specify the set of resources selected for placement.
- **Scheduling Policy**: This determines the set of clusters where the resources will be placed.
- **Rollout Strategy**: This controls the behavior of resource placement when the resources themselves and/or the 
              scheduling policy are updated, minimizing interruptions caused by refreshes.

The following sections discuss these components in depth.

## Resource selectors

A `ResourcePlacement` object may feature one or more resource selectors,
specifying which resources to select for placement. To add a resource selector, edit
the `resourceSelectors` field in the `ResourcePlacement` spec:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourcePlacement
metadata:
  name: rp
  namespace: test-ns
spec:
  resourceSelectors:
    - group: "rbac.authorization.k8s.io"
      kind: Role
      version: v1          
      name: secretReader
```

The example above will pick a `Role` named `secretReader` for resource placement.

It is important to note that, as its name implies, `ResourcePlacement` **selects only
namespace-scoped resources**. It only places the resources selected within the namespaces
where the `ResourcePlacement` object itself resides.

### Different types of resource selectors

You can specify a resource selector in many different ways:

* To select **one specific resource**, such as a deployment, specify its API GVK (group, version, and
kind), and its name, in the resource selector:

    ```yaml
    # As mentioned earlier, the resource selector will only pick resources under the same namespace as the RP object.
    resourceSelectors:
      - group: apps
        kind: Deployment
        version: v1          
        name: work
    ```

* Alternately, you may also select a set of resources of the same API GVK using a label selector;
it also requires that you specify the API GVK and the filtering label(s):

    ```yaml
    # As mentioned earlier, the resource selector will only pick resources under the same namespace as the RP object.
    resourceSelectors:
      - group: apps
        kind: Deployment
        version: v1           
        labelSelector:
          matchLabels:
            system: critical
    ```

    In the example above, all the deployments in namespace `test-ns` with the label `system=critical` in the hub cluster
    will be selected. 

    Fleet uses standard Kubernetes label selectors; for its specification and usage, see the
    [Kubernetes API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#labelselector-v1-meta).

* Very occasionally, you may need to select all the resources under a specific GVK; to achieve
this, use a resource selector with only the API GVK added:

    ```yaml
    resourceSelectors:
      - group: apps
        kind: Deployment
        version: v1          
    ```

    In the example above, all the deployments in `test-ns` in the hub cluster will be picked.

### Multiple resource selectors

You may specify up to 100 different resource selectors; Fleet will pick a resource if it matches
any of the resource selectors specified (i.e., all selectors are OR'd).

```yaml
resourceSelectors:
  - group: apps
    kind: Deployment
    version: v1          
    name: work
  - group: "rbac.authorization.k8s.io"
    kind: Role
    version: v1
    name: secretReader      
```

In the example above, Fleet will pick the deployment `work` and the role `secretReader` in the namespace `test-ns`.

> Note
>
> You can find the GVKs of built-in Kubernetes API objects in the
> [Kubernetes API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/).

## Scheduling policy

Each scheduling policy is associated with a placement type, which determines how KubeFleet will
pick clusters. The `ResourcePlacement` API supports the same placement types as `ClusterResourcePlacement`; 
for more information about placement types, see the [ClusterResourcePlacement - Scheduling Policy](crp.md#scheduling-policy) How-To Guide.

## Rollout strategy
The rollout strategy controls how KubeFleet rolls out changes; for more information, see the [ClusterResourcePlacement-Rollout Strategy](crp.md#rollout-strategy) How-To Guide.