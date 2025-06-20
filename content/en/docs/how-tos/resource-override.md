---
title: Using the ResourceOverride API
description: How to use the `ResourceOverride` API to override namespace-scoped resources
weight: 9
---

This guide provides an overview of how to use the Fleet `ResourceOverride` API to override resources.

## Overview
`ResourceOverride` is a Fleet API that allows you to modify or override specific attributes of 
existing resources within your cluster. With ResourceOverride, you can define rules based on cluster 
labels or other criteria, specifying changes to be applied to resources such as Deployments, StatefulSets, ConfigMaps, or Secrets. 
These changes can include updates to container images, environment variables, resource limits, or any other configurable parameters. 

## API Components
The ResourceOverride API consists of the following components:
- **Placement**: This specifies which placement the override is applied to.
- **Resource Selectors**: These specify the set of resources selected for overriding.
- **Policy**: This specifies the policy to be applied to the selected resources.


The following sections discuss these components in depth.

## Placement

To configure which placement the override is applied to, you can use the name of `ClusterResourcePlacement`.

## Resource Selectors
A `ResourceOverride` object may feature one or more resource selectors, specifying which resources to select to be overridden.

The `ResourceSelector` object supports the following fields:
- `group`: The API group of the resource
- `version`: The API version of the resource
- `kind`: The kind of the resource
- `name`: The name of the resource
> Note: The resource can only be selected by name.


To add a resource selector, edit the `resourceSelectors` field in the `ResourceOverride` spec:
```yaml
apiVersion: placement.kubernetes-fleet.io/v1alpha1
kind: ResourceOverride
metadata:
  name: example-ro
  namespace: test-namespace
spec:
  placement:
    name: crp-example
  resourceSelectors:
    -  group: apps
       kind: Deployment
       version: v1
       name: my-deployment
```
> Note: The ResourceOverride needs to be in the same namespace as the resources it is overriding.

The examples in the tutorial will pick a `Deployment` named `my-deployment` from the namespace `test-namespace`, as shown below, to be overridden.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
  name: my-deployment
  namespace: test-namespace
  ...
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: test-nginx
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: test-nginx
    spec:
      containers:
      - image: nginx:1.14.2
        imagePullPolicy: IfNotPresent
        name: nginx
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  ...
```

## Policy
The `Policy` is made up of a set of rules (`OverrideRules`) that specify the changes to be applied to the selected 
resources on selected clusters.

Each `OverrideRule` supports the following fields:
- **Cluster Selector**: This specifies the set of clusters to which the override applies.
- **Override Type**: This specifies the type of override to be applied. The default type is `JSONPatch`.
    - `JSONPatch`: applies the JSON patch to the selected resources using [RFC 6902](https://datatracker.ietf.org/doc/html/rfc6902).
    - `Delete`: deletes the selected resources on the target cluster.
- **JSON Patch Override**: This specifies the changes to be applied to the selected resources when the override type is `JSONPatch`.

### Cluster Selector
To specify the clusters to which the override applies, you can use the `clusterSelector` field in the `OverrideRule` spec.
The `clusterSelector` field supports the following fields:
- `clusterSelectorTerms`: A list of terms that are used to select clusters.
    * Each term in the list is used to select clusters based on the label selector.

> IMPORTANT:
> Only `labelSelector` is supported in the `clusterSelectorTerms` field.

### Override Type
To specify the type of override to be applied, you can use the overrideType field in the OverrideRule spec.
The default value is `JSONPatch`.
- `JSONPatch`: applies the JSON patch to the selected resources using [RFC 6902](https://datatracker.ietf.org/doc/html/rfc6902).
- `Delete`: deletes the selected resources on the target cluster.

#### JSON Patch Override
To specify the changes to be applied to the selected resources, you can use the jsonPatchOverrides field in the OverrideRule spec.
The jsonPatchOverrides field supports the following fields:

> JSONPatchOverride applies a JSON patch on the selected resources following [RFC 6902](https://datatracker.ietf.org/doc/html/rfc6902).
> All the fields defined follow this RFC.

The `jsonPatchOverrides` field supports the following fields:
- `op`: The operation to be performed. The supported operations are `add`, `remove`, and `replace`.
    * `add`: Adds a new value to the specified path.
    * `remove`: Removes the value at the specified path.
    * `replace`: Replaces the value at the specified path.

- `path`: The path to the field to be modified.
    * Some guidelines for the path are as follows:
        * Must start with a `/` character.
        * Cannot be empty.
        * Cannot contain an empty string ("///").
        * Cannot be a TypeMeta Field ("/kind", "/apiVersion").
        * Cannot be a Metadata Field ("/metadata/name", "/metadata/namespace"), except the fields "/metadata/annotations" and "metadata/labels".
        * Cannot be any field in the status of the resource.
    * Some examples of valid paths are:
        * `/metadata/labels/new-label`
        * `/metadata/annotations/new-annotation`
        * `/spec/template/spec/containers/0/resources/limits/cpu`
        * `/spec/template/spec/containers/0/resources/requests/memory`


- `value`: The value to be set.
    * If the `op` is `remove`, the value cannot be set.
    * There is a list of reserved variables that will be replaced by the actual values:
        * `${MEMBER-CLUSTER-NAME}`:  this will be replaced by the name of the `memberCluster` that represents this cluster.

##### Example: Override Labels

To overwrite the existing labels on the `Deployment` named `my-deployment` on clusters with the label `env: prod`,
you can use the following configuration:
```yaml
apiVersion: placement.kubernetes-fleet.io/v1alpha1
kind: ResourceOverride
metadata:
  name: example-ro
  namespace: test-namespace
spec:
  placement:
    name: crp-example
  resourceSelectors:
    -  group: apps
       kind: Deployment
       version: v1
       name: my-deployment
  policy:
    overrideRules:
      - clusterSelector:
          clusterSelectorTerms:
            - labelSelector:
                matchLabels:
                  env: prod
        jsonPatchOverrides:
          - op: add
            path: /metadata/labels
            value:
              {"cluster-name":"${MEMBER-CLUSTER-NAME}"}
```

> Note: To add a new label to the existing labels, please use the below configuration:
> ```yaml
>  - op: add
>    path: /metadata/labels/new-label
>    value: "new-value"
> ```

The `ResourceOverride` object above will add a label `cluster-name` with the value of the `memberCluster` name to the `Deployment` named `example-ro` on clusters with the label `env: prod`.

##### Example: Override Image

To override the image of the container in the `Deployment` named `my-deployment` on all clusters with the label `env: prod`:
```yaml
apiVersion: placement.kubernetes-fleet.io/v1alpha1
kind: ResourceOverride
metadata:
  name: example-ro
  namespace: test-namespace
spec:
  placement:
    name: crp-example
  resourceSelectors:
    -  group: apps
       kind: Deployment
       version: v1
       name: my-deployment
  policy:
    overrideRules:
      - clusterSelector:
          clusterSelectorTerms:
            - labelSelector:
                matchLabels:
                  env: prod
        jsonPatchOverrides:
          - op: replace
            path: /spec/template/spec/containers/0/image
            value: "nginx:1.20.0"
```
The `ResourceOverride` object above will replace the image of the container in the `Deployment` named `my-deployment`
with the image `nginx:1.20.0` on all clusters with the label `env: prod` selected by the clusterResourcePlacement `crp-example`.
> The ResourceOverride mentioned above utilizes the deployment displayed below:
> ```
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   ...
>   name: my-deployment
>   namespace: test-namespace
>   ...
> spec:
>   ...
>   template:
>     ...
>     spec:
>       containers:
>       - image: nginx:1.14.2
>         imagePullPolicy: IfNotPresent
>         name: nginx
>         ports:
>        ...
>       ...
>   ...
>```

#### Delete

The `Delete` override type can be used to delete the selected resources on the target cluster.

##### Example: Delete Selected Resource

To delete the `my-deployment` on the clusters with the label `env: test` selected by the clusterResourcePlacement `crp-example`,
you can use the `Delete` override type.
```yaml
apiVersion: placement.kubernetes-fleet.io/v1alpha1
kind: ResourceOverride
metadata:
  name: example-ro
  namespace: test-namespace
spec:
  placement:
    name: crp-example
  resourceSelectors:
    -  group: apps
       kind: Deployment
       version: v1
       name: my-deployment
  policy:
    overrideRules:
      - clusterSelector:
          clusterSelectorTerms:
            - labelSelector:
                matchLabels:
                  env: test
        overrideType: Delete
```

### Multiple Override Rules

You may add multiple `OverrideRules` to a `Policy` to apply multiple changes to the selected resources.
```yaml
apiVersion: placement.kubernetes-fleet.io/v1alpha1
kind: ResourceOverride
metadata:
  name: example-ro
  namespace: test-namespace
spec:
  placement:
    name: crp-example
  resourceSelectors:
    -  group: apps
       kind: Deployment
       version: v1
       name: my-deployment
  policy:
    overrideRules:
      - clusterSelector:
          clusterSelectorTerms:
            - labelSelector:
                matchLabels:
                  env: prod
        jsonPatchOverrides:
          - op: replace
            path: /spec/template/spec/containers/0/image
            value: "nginx:1.20.0"
      - clusterSelector:
          clusterSelectorTerms:
            - labelSelector:
                matchLabels:
                  env: test
        jsonPatchOverrides:
          - op: replace
            path: /spec/template/spec/containers/0/image
            value: "nginx:latest"
```
The `ResourceOverride` object above will replace the image of the container in the `Deployment` named `my-deployment`
with the image `nginx:1.20.0` on all clusters with the label `env: prod` and the image `nginx:latest` on all clusters with the label `env: test`.

> The ResourceOverride mentioned above utilizes the deployment displayed below:
> ```
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   ...
>   name: my-deployment
>   namespace: test-namespace
>   ...
> spec:
>   ...
>   template:
>     ...
>     spec:
>       containers:
>       - image: nginx:1.14.2
>         imagePullPolicy: IfNotPresent
>         name: nginx
>         ports:
>        ...
>       ...
>   ...
>```

## Applying the ResourceOverride
Create a ClusterResourcePlacement resource to specify the placement rules for distributing the resource overrides across 
the cluster infrastructure. Ensure that you select the appropriate namespaces containing the matching resources.
```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: crp-example
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      name: test-namespace
      version: v1
  policy:
    placementType: PickAll
    affinity:
      clusterAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          clusterSelectorTerms:
            - labelSelector:
                matchLabels:
                  env: prod
            - labelSelector:
                matchLabels:
                  env: test
```
The `ClusterResourcePlacement` configuration outlined above will disperse resources within `test-namespace` across all 
clusters labeled with `env: prod` and `env: test`. As the changes are implemented, the corresponding `ResourceOverride` 
configurations will be applied to the designated clusters, triggered by the selection of matching deployment resource 
`my-deployment`.

## Verifying the Cluster Resource is Overridden
To ensure that the `ResourceOverride` object is applied to the selected resources, verify the `ClusterResourcePlacement`
status by running `kubectl describe crp crp-example` command:
```
Status:
  Conditions:
    ...
    Message:                The selected resources are successfully overridden in the 10 clusters
    Observed Generation:    1
    Reason:                 OverriddenSucceeded
    Status:                 True
    Type:                   ClusterResourcePlacementOverridden
    ...
  Observed Resource Index:  0
  Placement Statuses:
    Applicable Resource Overrides:
      Name:        example-ro-0
      Namespace:   test-namespace
    Cluster Name:  member-50
    Conditions:
      ...
      Message:               Successfully applied the override rules on the resources
      Observed Generation:   1
      Reason:                OverriddenSucceeded
      Status:                True
      Type:                  Overridden
     ...
```
Each cluster maintains its own `Applicable Resource Overrides` which contain the resource override snapshot and
the resource override namespace if relevant. Additionally, individual status messages for each cluster indicates
whether the override rules have been effectively applied.

The `ClusterResourcePlacementOverridden` condition indicates whether the resource override has been successfully applied
to the selected resources in the selected clusters.

To verify that the `ResourceOverride` object has been successfully applied to the selected resources,
check resources in the selected clusters:
1. Get cluster credentials:
   `az aks get-credentials --resource-group <resource-group> --name <cluster-name>`
2. Get the `Deployment` object in the selected cluster:
   `kubectl --context=<member-cluster-context>  get deployment my-deployment -n test-namespace -o yaml`

Upon inspecting the member cluster, it was found that the selected cluster had the label env: prod. 
Consequently, the image on deployment `my-deployment` was modified to be `nginx:1.20.0` on selected cluster.
   ```
   apiVersion: apps/v1
    kind: Deployment
    metadata:
      ...
      name: my-deployment
      namespace: test-namespace
      ...
    spec:
      ...
      template:
        ...
        spec:
          containers:
          - image: nginx:1.20.0
            imagePullPolicy: IfNotPresent
            name: nginx
            ports:
           ...
          ...
    status:
        ...
```