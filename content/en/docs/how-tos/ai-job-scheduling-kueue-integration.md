---
title: "Scheduling AI Jobs with Kueue and Fleet"
description: "Learn how to schedule AI/ML workloads using Kueue and ClusterResourcePlacement/ResourcePlacement"
weight: 16
---

# Scheduling AI Jobs with Kueue and Placement

This guide demonstrates how to schedule AI/ML workloads across your fleet using KubeFleet's ClusterResourcePlacement/ResourcePlacement in conjunction with Kueue for efficient job queuing and resource management.


## Overview

When scheduling AI/ML jobs across multiple clusters, you need three key components working together:

- **ClusterResourcePlacement**: Propagates cluster-scoped resources (ClusterQueues, ResourceFlavors) and namespaces to selected clusters
- **ResourcePlacement**: Propagates the AI/ML job and LocalQueue to selected clusters within the namespace
- **Kueue**: Manages job queuing and resource quotas within each cluster

This combination ensures efficient scheduling and resource utilization for your AI workloads across your entire fleet.

## Enable Kueue on Fleet

To enable Kueue in your fleet environment, you'll need to install Kueue on your Member Clusters and the required CustomResourceDefinitions (CRDs) on your Hub Cluster.

### Install Kueue on Individual Member Clusters

Before proceeding with the installation, keep in mind that you'll need to switch to the context of the member cluster you want to install Kueue on. This is because Kueue needs to be installed and managed individually within each cluster, and you need to ensure that you're interacting with the correct cluster when applying the necessary configurations.

```bash
# Set the Kueue version you want to install
VERSION=v0.9.0  # Replace with the latest version, or working version you like

# Switch to your member cluster context
kubectl config use-context <member-cluster-context>

# Install Kueue on the member cluster
kubectl apply --server-side -f \
  https://github.com/kubernetes-sigs/kueue/releases/download/$VERSION/manifests.yaml
```

> **Note**: Replace `VERSION` with the latest version of Kueue. For more information about Kueue versions, see [Kueue releases](https://github.com/kubernetes-sigs/kueue/releases).


To ensure Kueue is properly installed:

```bash
# On member clusters - check Kueue controller is running
kubectl get pods -n kueue-system
```
```
NAME                                        READY   STATUS    RESTARTS   AGE
kueue-controller-manager-59f5c6b49c-22g7r   2/2     Running   0          57s
```

**Repeat this process for each member cluster** in your fleet where you want to schedule AI/ML workloads.

### Install CRDs on Hub Cluster

Next, you will need to install the necessary CRDs on the hub cluster. Installing the CRDs here allows the hub cluster to properly handle Kueue-related resources. For this guide, we will install the CRDs for ResourceFlavor, ClusterQueue, and LocalQueue.

> **Important**: Make sure you have switched to the context of your hub cluster before proceeding with the installation.

```bash
# Switch to your hub cluster context
kubectl config use-context <hub-cluster-context>

# Set the Kueue version you want to install
VERSION=v0.9.0  # Replace with the latest version, or working version you like

# Install required Kueue CRDs on hub cluster
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kueue/$VERSION/config/components/crd/bases/kueue.x-k8s.io_clusterqueues.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kueue/$VERSION/config/components/crd/bases/kueue.x-k8s.io_localqueues.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kueue/$VERSION/config/components/crd/bases/kueue.x-k8s.io_resourceflavors.yaml

# Verify CRDs are installed
kubectl get crds | grep kueue
```

You should see output similar to:
```
clusterqueues.kueue.x-k8s.io                       2025-10-17T17:50:30Z
localqueues.kueue.x-k8s.io                         2025-10-17T17:50:33Z
resourceflavors.kueue.x-k8s.io                     2025-10-17T17:50:35Z
```

## Step-by-Step Guide

### 1. Create Resource Flavor on Hub

First, create a ResourceFlavor that defines the available resource types:

```yaml
apiVersion: kueue.x-k8s.io/v1beta1 
kind: ResourceFlavor  
metadata:  
  name: default-flavor
spec:
  # This ResourceFlavor will be used for all the resources
```

A ResourceFlavor is an object that represents the variations in the nodes available in your cluster by associating them with node labels and taints. 


### 2. Configure ClusterQueue on Hub

Set up a ClusterQueue for the workloads:

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: cluster-queue
spec:
  cohort: ai-training
  namespaceSelector: {} # Available to all namespaces  
  queueingStrategy: BestEffortFIFO # Default queueing strategy 
  resourceGroups:
  - coveredResources: ["cpu", "memory"]
    flavors:
    - name: default-flavor
      resources:
      - name: cpu
        nominalQuota: "32"
      - name: memory
        nominalQuota: "128Gi"
```
> NOTE: The resources need to be listed in the same order as the coveredResources list.

A ClusterQueue is a cluster-scoped object that oversees a pool of resources, including CPU, memory, and GPU. It manages ResourceFlavors, sets usage limits, and controls the order in which workloads are admitted. This will handle the ResourceFlavor that was previously created.


### 3. Create Training Namespace on Hub

Create the namespace where your AI jobs will be scheduled:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: training
  labels:
    app: ai-training
```
The LocalQueue and Job require a namespace to be specified. 


### 4. Use ClusterResourcePlacement to Propagate Cluster-Scoped Resources

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1  
kind: ClusterResourcePlacement  
metadata:  
  name: sample-kueue 
spec:  
  resourceSelectors:
    - group: kueue.x-k8s.io  
      version: v1beta1  
      kind: ResourceFlavor  
      name: default-flavor  
    - group: kueue.x-k8s.io  
      version: v1beta1  
      kind: ClusterQueue  
      name: cluster-queue  
    - group: ""  
      kind: Namespace  
      version: v1  
      name: training  
      selectionScope: NamespaceOnly
  policy:  
    placementType: PickAll
  strategy:  
    type: RollingUpdate  
    rollingUpdate:  
      maxUnavailable: 25%  
      maxSurge: 25%  
      unavailablePeriodSeconds: 60  
  revisionHistoryLimit: 15
```

The ClusterResourcePlacement (CRP) will select the cluster-scoped resources you created (such as ResourceFlavor and ClusterQueue) and the namespace only. The CRP will propagate these resources to all selected member clusters on the Fleet.

#### Verify ClusterResourcePlacement Completed

After creating the ClusterResourcePlacement, you need to verify that it has successfully propagated the resources to the target clusters. A successful completion is indicated by several conditions in the status:

1. Check the placement status:
```bash
# Get detailed status of the ClusterResourcePlacement
kubectl describe crp sample-kueue
```
```yaml
Name:         sample-kueue
Namespace:    
Labels:       <none>
Annotations:  <none>
API Version:  placement.kubernetes-fleet.io/v1
Kind:         ClusterResourcePlacement
Metadata:
  Creation Timestamp:  2025-10-22T20:19:50Z
  Finalizers:
    kubernetes-fleet.io/crp-cleanup
    kubernetes-fleet.io/scheduler-cleanup
  Generation:        1
  Resource Version:  3794694
  UID:               e242900c-3552-4289-bf8f-8be2480e63b1
Spec:
  ..
Status:
  Conditions:
    Last Transition Time:   2025-10-22T20:19:50Z
    Message:                found all cluster needed as specified by the scheduling policy, found 3 cluster(s)
    Observed Generation:    1
    Reason:                 SchedulingPolicyFulfilled
    Status:                 True
    Type:                   ClusterResourcePlacementScheduled
    Last Transition Time:   2025-10-22T20:19:50Z
    Message:                All 3 cluster(s) start rolling out the latest resource
    Observed Generation:    1
    Reason:                 RolloutStarted
    Status:                 True
    Type:                   ClusterResourcePlacementRolloutStarted
    Last Transition Time:   2025-10-22T20:19:50Z
    Message:                No override rules are configured for the selected resources
    Observed Generation:    1
    Reason:                 NoOverrideSpecified
    Status:                 True
    Type:                   ClusterResourcePlacementOverridden
    Last Transition Time:   2025-10-22T20:19:50Z
    Message:                Works(s) are succcesfully created or updated in 3 target cluster(s)' namespaces
    Observed Generation:    1
    Reason:                 WorkSynchronized
    Status:                 True
    Type:                   ClusterResourcePlacementWorkSynchronized
    Last Transition Time:   2025-10-22T20:19:50Z
    Message:                The selected resources are successfully applied to 3 cluster(s)
    Observed Generation:    1
    Reason:                 ApplySucceeded
    Status:                 True
    Type:                   ClusterResourcePlacementApplied
    Last Transition Time:   2025-10-22T20:19:50Z
    Message:                The selected resources in 3 cluster(s) are available now
    Observed Generation:    1
    Reason:                 ResourceAvailable
    Status:                 True
    Type:                   ClusterResourcePlacementAvailable
  Observed Resource Index:  0
  Placement Statuses:
    Cluster Name:  cluster-1
    Conditions:
      Last Transition Time:  2025-10-22T20:19:50Z
      Message:               Successfully scheduled resources for placement in "cluster-1" (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2025-10-22T20:19:50Z
      Message:               Detected the new changes on the resources and started the rollout process
      Observed Generation:   1
      Reason:                RolloutStarted
      Status:                True
      Type:                  RolloutStarted
      Last Transition Time:  2025-10-22T20:19:50Z
      Message:               No override rules are configured for the selected resources
      Observed Generation:   1
      Reason:                NoOverrideSpecified
      Status:                True
      Type:                  Overridden
      Last Transition Time:  2025-10-22T20:19:50Z
      Message:               All of the works are synchronized to the latest
      Observed Generation:   1
      Reason:                AllWorkSynced
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2025-10-22T20:19:50Z
      Message:               All corresponding work objects are applied
      Observed Generation:   1
      Reason:                AllWorkHaveBeenApplied
      Status:                True
      Type:                  Applied
      Last Transition Time:  2025-10-22T20:19:50Z
      Message:               The availability of work object sample-kueue-work is not trackable
      Observed Generation:   1
      Reason:                NotAllWorkAreAvailabilityTrackable
      Status:                True
      Type:                  Available
    ClusterName: cluster-2
      ...
    ClusterName: cluster-3
      ...
  Selected Resources:
    Kind:     Namespace
    Name:     training
    Version:  v1
    Group:    kueue.x-k8s.io
    Kind:     ClusterQueue
    Name:     cluster-queue
    Version:  v1beta1
    Group:    kueue.x-k8s.io
    Kind:     ResourceFlavor
    Name:     default-flavor
    Version:  v1beta1
Events:
  Type    Reason                        Age   From                  Message
  ----    ------                        ----  ----                  -------
  Normal  PlacementRolloutStarted       13s   placement-controller  Started rolling out the latest resources
  Normal  PlacementOverriddenSucceeded  13s   placement-controller  Placement has been successfully overridden
  Normal  PlacementWorkSynchronized     13s   placement-controller  Work(s) have been created or updated successfully for the selected cluster(s)
  Normal  PlacementApplied              13s   placement-controller  Resources have been applied to the selected cluster(s)
  Normal  PlacementAvailable            13s   placement-controller  Resources are available on the selected cluster(s)
  Normal  PlacementRolloutCompleted     13s   placement-controller  Placement has finished the rollout process and reached the desired status
```

2. Verify resources on target clusters:
```bash
# Switch to member cluster context
kubectl config use-context <member-cluster-context>

# Check if resources are present
kubectl get resourceflavor default-flavor
kubectl get clusterqueue cluster-queue
kubectl get ns training
```

### 5. Create LocalQueue on Hub

Create a LocalQueue that will be propagated to member clusters:

```yaml
apiVersion: kueue.x-k8s.io/v1beta1 
kind: LocalQueue  
metadata:   
  namespace: training
  name: lq-training   
spec:  
  clusterQueue: cluster-queue # Point to the ClusterQueue
```

A LocalQueue is a namespaced resource that receives workloads from users within the specified namespace. This resource will point to the ClusterQueue previously created.


### 6. Define Your AI Job(s) on Hub

Create your AI training job(s) with Kueue annotations:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mock-training
  namespace: training
  annotations:
    kueue.x-k8s.io/queue-name: lq-training
spec:
  ttlSecondsAfterFinished: 60 # Job will be deleted after 60 seconds  
  parallelism: 3
  completions: 3
  suspend: true # Set to true to allow Kueue to control the Job
  template:
    spec:
      containers:
      - name: training
        image: ubuntu:22.04
        command:
        - "/bin/bash"
        - "-c"
        - |
          echo "Starting mock training job..."
          echo "Loading training dataset..."
          sleep 10
          echo "Epoch 1/3: Training accuracy: 65%"
          sleep 10
          echo "Epoch 2/3: Training accuracy: 85%"
          sleep 10
          echo "Epoch 3/3: Training accuracy: 95%"
          echo "Training completed successfully!"
        resources:
          requests:
            cpu: "1"
            memory: "2Gi"
          limits:
            cpu: "1"
            memory: "2Gi"
      restartPolicy: Never
  backoffLimit: 3
---
apiVersion: batch/v1
kind: Job
metadata:
  name: model-evaluation
  namespace: training
  annotations:
    kueue.x-k8s.io/queue-name: lq-training
spec:
  ttlSecondsAfterFinished: 60
  parallelism: 3
  completions: 3
  suspend: true # Set to true to allow Kueue to control the Job
  template:
    spec:
      containers:
      - name: evaluation
        image: ubuntu:22.04
        command:
        - "/bin/bash"
        - "-c"
        - |
          echo "Starting model evaluation job..."
          echo "Loading test dataset..."
          sleep 5
          echo "Running evaluation suite..."
          sleep 10
          echo "Computing metrics..."
          echo "Accuracy: 94.5%"
          echo "F1 Score: 0.93"
          echo "Evaluation completed successfully!"
        resources:
          requests:
            cpu: "1"
            memory: "1Gi"
          limits:
            cpu: "1"
            memory: "1Gi"
      restartPolicy: Never
  backoffLimit: 3
```

This Job defines the AI/ML training workload that will be scheduled by Kueue. The `kueue.x-k8s.io/queue-name` annotation tells Kueue which LocalQueue should manage this job, ensuring proper resource allocation and queuing behavior.

### 7. Create ResourcePlacement for the AI Job and LocalQueue

Create a ResourcePlacement to schedule your job and LocalQueue on appropriate clusters:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1  
kind: ResourcePlacement
metadata:
  name: training-placement
  namespace: training
spec:
  resourceSelectors:
  - group: batch
    version: v1
    kind: Job
    name: mock-training
  - group: batch
    version: v1
    kind: Job
    name: model-evaluation
  - group: kueue.x-k8s.io
    version: v1beta1
    kind: LocalQueue
    name: lq-training 
  policy:  
    placementType: PickN  
    numberOfClusters: 2  
    affinity:  
      clusterAffinity:  
        preferredDuringSchedulingIgnoredDuringExecution:  
          - weight: 40
            preference:  
              propertySorter:  
                name: kubernetes-fleet.io/node-count  
                sortOrder: Descending  
          - weight: 30  
            preference:  
              propertySorter:  
                name: resources.kubernetes-fleet.io/available-cpu  
                sortOrder: Descending  
  strategy:  
    type: RollingUpdate  
    rollingUpdate:  
      maxUnavailable: 25%  
      maxSurge: 25%  
      unavailablePeriodSeconds: 60  
    applyStrategy:  
      whenToApply: IfNotDrifted
  revisionHistoryLimit: 15
```

The ResourcePlacement intelligently selects member clusters based on resource availability and placement policies, then propagates both the AI Job and LocalQueue to the chosen cluster(s). It uses cluster affinity rules to prioritize clusters with more nodes and available CPU resources for optimal job placement.

#### Verify ResourcePlacement Completed

After creating the ResourcePlacement, verify that your AI job and LocalQueue are properly propagated:

1. Check ResourcePlacement status:
```bash
# Get detailed status of the ResourcePlacement
kubectl describe resourceplacement training-placement -n training
```

```yaml
Name:         training-placement
Namespace:    training
Labels:       <none>
Annotations:  <none>
API Version:  placement.kubernetes-fleet.io/v1beta1
Kind:         ResourcePlacement
Metadata:
  Creation Timestamp:  2025-10-23T22:41:26Z
  Finalizers:
    kubernetes-fleet.io/crp-cleanup
    kubernetes-fleet.io/scheduler-cleanup
  Generation:        1
  Resource Version:  4416159
  UID:               91666f24-9b16-43cd-90f3-9a2e715733be
Spec:
  ...
Status:
  Conditions:
    Last Transition Time:   2025-10-23T22:41:26Z
    Message:                found all cluster needed as specified by the scheduling policy, found 2 cluster(s)
    Observed Generation:    1
    Reason:                 SchedulingPolicyFulfilled
    Status:                 True
    Type:                   ResourcePlacementScheduled
    Last Transition Time:   2025-10-23T22:41:26Z
    Message:                All 2 cluster(s) start rolling out the latest resource
    Observed Generation:    1
    Reason:                 RolloutStarted
    Status:                 True
    Type:                   ResourcePlacementRolloutStarted
    Last Transition Time:   2025-10-23T22:41:26Z
    Message:                No override rules are configured for the selected resources
    Observed Generation:    1
    Reason:                 NoOverrideSpecified
    Status:                 True
    Type:                   ResourcePlacementOverridden
    Last Transition Time:   2025-10-23T22:41:26Z
    Message:                Works(s) are succcesfully created or updated in 2 target cluster(s)' namespaces
    Observed Generation:    1
    Reason:                 WorkSynchronized
    Status:                 True
    Type:                   ResourcePlacementWorkSynchronized
    Last Transition Time:   2025-10-23T22:41:32Z
    Message:                Failed to apply resources to 2 cluster(s), please check the `failedPlacements` status
    Observed Generation:    1
    Reason:                 ApplyFailed
    Status:                 False
    Type:                   ResourcePlacementApplied
  Observed Resource Index:  0
  Placement Statuses:
    Cluster Name:  cluster-3
    Conditions:
      Last Transition Time:  2025-10-23T22:41:26Z
      Message:               Successfully scheduled resources for placement in "cluster-3" (affinity score: 70, topology spread score: 0): picked by scheduling policy
      Observed Generation:   1
      Reason:                Scheduled
      Status:                True
      Type:                  Scheduled
      Last Transition Time:  2025-10-23T22:41:26Z
      Message:               Detected the new changes on the resources and started the rollout process
      Observed Generation:   1
      Reason:                RolloutStarted
      Status:                True
      Type:                  RolloutStarted
      Last Transition Time:  2025-10-23T22:41:26Z
      Message:               No override rules are configured for the selected resources
      Observed Generation:   1
      Reason:                NoOverrideSpecified
      Status:                True
      Type:                  Overridden
      Last Transition Time:  2025-10-23T22:41:26Z
      Message:               All of the works are synchronized to the latest
      Observed Generation:   1
      Reason:                AllWorkSynced
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2025-10-23T22:41:32Z
      Message:               Work object training.training-placement-work has failed to apply
      Observed Generation:   1
      Reason:                NotAllWorkHaveBeenApplied
      Status:                False
      Type:                  Applied
    Drifted Placements:
      First Drifted Observed Time:  2025-10-23T22:41:32Z
      Group:                        batch
      Kind:                         Job
      Name:                         mock-training
      Namespace:                    training
      Observation Time:             2025-10-23T22:41:45Z
      Observed Drifts:
        Path:                              /spec/selector/matchLabels/batch.kubernetes.io~1controller-uid
        Value In Member:                   f9e62977-6c5c-48aa-a82b-1421e2647395
        Path:                              /spec/suspend
        Value In Hub:                      true
        Value In Member:                   false
        Path:                              /spec/template/metadata/creationTimestamp
        Value In Member:                   <nil>
        Path:                              /spec/template/metadata/labels/batch.kubernetes.io~1controller-uid
        Value In Member:                   f9e62977-6c5c-48aa-a82b-1421e2647395
        Path:                              /spec/template/metadata/labels/controller-uid
        Value In Member:                   f9e62977-6c5c-48aa-a82b-1421e2647395
      Target Cluster Observed Generation:  2
      Version:                             v1
      First Drifted Observed Time:         2025-10-23T22:41:32Z
      Group:                               batch
      Kind:                                Job
      Name:                                model-evaluation
      Namespace:                           training
      Observation Time:                    2025-10-23T22:41:45Z
      Observed Drifts:
        Path:                              /spec/selector/matchLabels/batch.kubernetes.io~1controller-uid
        Value In Member:                   bf5e580f-48ed-4eeb-8d91-58a6da398091
        Path:                              /spec/suspend
        Value In Hub:                      true
        Value In Member:                   false
        Path:                              /spec/template/metadata/creationTimestamp
        Value In Member:                   <nil>
        Path:                              /spec/template/metadata/labels/batch.kubernetes.io~1controller-uid
        Value In Member:                   bf5e580f-48ed-4eeb-8d91-58a6da398091
        Path:                              /spec/template/metadata/labels/controller-uid
        Value In Member:                   bf5e580f-48ed-4eeb-8d91-58a6da398091
      Target Cluster Observed Generation:  2
      Version:                             v1
    Failed Placements:
      Condition:
        Last Transition Time:  2025-10-23T22:41:32Z
        Message:               Failed to apply the manifest (error: cannot apply manifest: drifts are found between the manifest and the object from the member cluster in degraded mode (full comparison is performed instead of partial comparison, as the manifest object is considered to be invalid by the member cluster API server))
        Observed Generation:   2
        Reason:                FoundDriftsInDegradedMode
        Status:                False
        Type:                  Applied
      Group:                   batch
      Kind:                    Job
      Name:                    mock-training
      Namespace:               training
      Version:                 v1
      Condition:
        Last Transition Time:  2025-10-23T22:41:32Z
        Message:               Failed to apply the manifest (error: cannot apply manifest: drifts are found between the manifest and the object from the member cluster in degraded mode (full comparison is performed instead of partial comparison, as the manifest object is considered to be invalid by the member cluster API server))
        Observed Generation:   2
        Reason:                FoundDriftsInDegradedMode
        Status:                False
        Type:                  Applied
      Group:                   batch
      Kind:                    Job
      Name:                    model-evaluation
      Namespace:               training
      Version:                 v1
    Observed Resource Index:   0
    Cluster Name:              cluster-1
    Conditions:
      ... # Should be similar to first cluster above
  Selected Resources:
    Group:      batch
    Kind:       Job
    Name:       mock-training
    Namespace:  training
    Version:    v1
    Group:      batch
    Kind:       Job
    Name:       model-evaluation
    Namespace:  training
    Version:    v1
    Group:      kueue.x-k8s.io
    Kind:       LocalQueue
    Name:       lq-training
    Namespace:  training
    Version:    v1beta1
Events:
  Type    Reason                        Age   From                  Message
  ----    ------                        ----  ----                  -------
  Normal  PlacementRolloutStarted       23s   placement-controller  Started rolling out the latest resources
  Normal  PlacementOverriddenSucceeded  23s   placement-controller  Placement has been successfully overridden
  Normal  PlacementWorkSynchronized     23s   placement-controller  Work(s) have been created or updated successfully for the selected cluster(s)
  Normal  PlacementApplied              22s   placement-controller  Resources have been applied to the selected cluster(s)
  Normal  PlacementAvailable            22s   placement-controller  Resources are available on the selected cluster(s)
  Normal  PlacementRolloutCompleted     22s   placement-controller  Placement has finished the rollout process and reached the desired status
```
> NOTE: The ResourcePlacement will complete rollout but with detect drifts after initial application as kueue takes over the resources. Completition indication can be found in the events.


2. Verify resources on target cluster:
```bash
# Switch to member cluster context
kubectl config use-context <member-cluster-context>

# Check if job and localqueue exist in the namespace
kubectl get jobs,localqueue -n training
```

## How It Works

The job scheduling process combines ClusterResourcePlacement, ResourcePlacement, and Kueue in the following orchestrated workflow:

### 🔄 Workflow Overview

1. **ClusterResourcePlacement Phase**:
   - Propagates cluster-scoped resources (ResourceFlavor, ClusterQueue) to selected member clusters
   - Ensures the namespace is created on target clusters
   - Sets up the foundational Kueue infrastructure across the fleet

2. **ResourcePlacement Phase**: 
   - Selects appropriate clusters based on resource constraints
   - Propagates the AI/ML job and LocalQueue to the selected cluster(s)

3. **Kueue Management Phase**:
   - Manages job admission based on ClusterQueue quotas
   - Controls job execution through suspend/unsuspend mechanism
   - Handles resource tracking and quota enforcement
   - Maintains job queuing and priority order

### 🎯 Resource Flow

```
Hub Cluster                    Member Cluster(s)
├── ResourceFlavor       ──────► ResourceFlavor
├── ClusterQueue         ──────► ClusterQueue  
├── Namespace           ──────► Namespace
├── LocalQueue          ──────► LocalQueue
└── AI Job              ──────► AI Job → Kueue → Pod
```

## Best Practices

1. **Resource Management**
   - Always specify both requests and limits for resources
   - Set realistic resource requirements based on workload needs
   - Consider additional resources needed for data processing

2. **Queue Configuration**
   - Configure quotas based on actual cluster capacity
   - Create separate queues for different workload types
   - Use cohorts to manage related jobs efficiently

3. **Placement Strategy**
   - Define clear cluster selection criteria
   - Consider workload requirements when setting affinities
   - Plan for high availability with backup clusters

## Monitoring and Troubleshooting

### 📊 Monitoring Job Status

#### Check Placement Status
```bash
# View ResourcePlacement status
kubectl get resourceplacement <rp-name> -n <namespace> -o yaml

# View ClusterResourcePlacement status
kubectl get clusterresourceplacement <crp-name> -o yaml
```

#### Monitor Queue Status on Member Cluster
```bash
# Check LocalQueue status
kubectl get localqueue <lq-name> -n <namespace>

# Check ClusterQueue status
kubectl get clusterqueue <cq-name> -o wide

# Check Job status
kubectl get job <job-name> -n <namespace>
```

## Related Resources

### 📚 Documentation
- [Kueue Documentation](https://kueue.sigs.k8s.io/docs/) - Complete Kueue setup and configuration guide
- [ClusterResourcePlacement Concepts](../concepts/crp.md) - Understanding cluster-scoped resource propagation
- [ResourcePlacement Concepts](../concepts/rp.md) - Namespace-scoped resource scheduling
- [Properties-based Scheduling](./property-based-scheduling.md) - Advanced cluster selection strategies

### 🔗 Related How-To Guides
- [Managing Cluster Resources](./clusters.md) - Setting up and configuring member clusters
- [Resource Override](./resource-override.md) - Customizing resources per cluster
- [Affinities](./affinities.md) - Advanced placement constraints