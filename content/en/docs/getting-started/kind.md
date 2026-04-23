---
title: KubeFleet quickstart using kind clusters
description: Use kind clusters to learn about KubeFleet
weight: 3
---

In this tutorial, you deploy KubeFleet on [kind](https://kind.sigs.k8s.io/) clusters, which are Kubernetes clusters running locally via [Docker](https://docker.com/).

We'll help you understand KubeFleet's key architectural components, and introduce the custom resources and processes you can use for day-to-day multi-cluster management experience with very little setup needed.

> Note: kind is a tool for setting up a Kubernetes environment for experimental purposes; Some instructions for running KubeFleet on kind clusters may not apply to other environments, and there might also be some minor differences in the KubeFleet experience.

## Before you begin

To complete this tutorial, you will need the following tools on your local machine:

* **docker** (or alternatives): run agent images (and optionally build locally if you want). [Docker Desktop installation guide](https://docs.docker.com/desktop/)
* **kind**, for running Kubernetes clusters on your local machine. [Installation guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
* **helm**, the Kubernetes package manager. [Installation guide](https://helm.sh/docs/intro/install/)

Other tools that may be useful, or are bundled with your operation system:

* **git**
* **curl**
* **jq**
* **base64**
* **PowerShell**

## Getting help

If you run into issues when using this quickstart please consider opening a [GitHub Issue](https://github.com/kubefleet-dev/kubefleet/issues/new?template=bug_report.md) so the team is aware and can help you out.

## Create kind clusters

KubeFleet provides a scalable multi-cluster solution that uses a hub and spoke pattern, consisting of one hub cluster and one or more member clusters:

* The hub cluster is the control plane to which every member cluster connects; it also serves as an interface for centralized management. You can perform a number of tasks focused on orchestrating Kubernetes resources across member clusters.
* Each member cluster connects to the hub cluster and runs workloads you place on it via the hub cluster.

In this tutorial you will create two kind clusters - one of which serves as the KubeFleet hub cluster, and the other the KubeFleet member cluster.

### Selecting Kubernetes version

If you want to control the Kubernetes version of your kind clusters, see [kind releases](https://github.com/kubernetes-sigs/kind/releases) and set the Kubernetes version by passing the correct value to `--image` parameter. For example `--image kindest/node:v1.32.8` will create a Kubernetes cluster running 1.32.8.

> Note: there may be compatibility issues with older Kubernetes versions, so we recommend using at most an N-2 Kubernetes release (where N is the most recent release).

The following commands create a cluster using defaults, including the most recent Kubernetes version kind supports.

```sh
kind create cluster --name kf-hub-01
```

The output will look similar to the following.

```output
Creating cluster "kf-hub-01" ...
 ✓ Ensuring node image (kindest/node:v1.35.0) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kf-hub-01"
You can now use your cluster with:

kubectl cluster-info --context kind-kf-hub-01
```

Next, create a member cluster, again with defaults.

```sh
kind create cluster --name kf-member-01
```

The output will look similar that from the hub cluster creation above.

> Note: the cluster name you provided is prefixed with `kind`, so in later steps make sure to use the full name. For example `kind-kf-hub-01`.

## Configure KubeFleet hub cluster

To set up the hub cluster use the following process.

### Obtain hub cluster's Kubernetes API URL

First, we need to get the URL for the hub cluster's Kubernetes API. When using running multiple kind clusters his will be different to the URL that's present in your kubeconfig. This is because your user sessions runs outside of the Docker network and the kind clusters all run inside the same Docker network (typically in the IP address space 172.x.x.x).

Retrieve the IP address of the hub cluster using the following command. Replace `kf-hub-01` with the name you provided when creating your hub cluster (without the `kind` prefix).

```sh
docker inspect kf-hub-01-control-plane --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

Record the IP address that's returned.

```output
172.18.0.2
```

### Select KubeFleet version

Next, select the KubeFleet version to run by looking at the [KubeFleet GitHub Releases page](https://github.com/kubefleet-dev/kubefleet/releases) and picking a version - for example 0.3.1.

> Note: we recommend using the most recent KubeFleet release for the best experience.

### Deploy KubeFleet hub agent

Make sure your session is connected to the hub kind cluster.

```sh
kubectl config use-context kind-kf-hub-01
```

Use helm to install the hub agent on the cluster. The following command provides the minimum required parameters to start the agent successfully.

```sh
helm upgrade --install hub-agent oci://ghcr.io/kubefleet-dev/kubefleet/charts/hub-agent \
    --version 0.3.1 \
    --namespace fleet-system \
    --create-namespace \
    --set logFileMaxSize=100000
```

It will take a few seconds for the installation to complete. Output looks similar to the following.

```output
Pulled: ghcr.io/kubefleet-dev/kubefleet/charts/hub-agent:0.3.1
Digest: sha256:xxxxxx
NAME: hub-agent
LAST DEPLOYED: Tue Mar 24 11:14:03 2026
NAMESPACE: fleet-system
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
```

Once the deployment finishes, verify that the KubeFleet hub agent is up and running with the commands below:

```sh
kubectl get pods -n fleet-system
```

Which will produce output similar to the following.

```output
NAME                         READY   STATUS    RESTARTS      AGE
hub-agent-7758b6559b-6w2t8   1/1     Running   0             117m
```

## Configure KubeFleet member clusters

Next, let's create a member cluster. You can repeat this step multiple times to add more members.

This step requires installing the KubeFleet member agent on the cluster and connecting it to the KubeFleet hub cluster.

### Use script to join clusters

For your convenience, KubeFleet provides quickstart scripts [(`join-member-clusters.sh`)](https://github.com/kubefleet-dev/kubefleet/tree/main/hack/quickstart/join-member-clusters.sh) and [(`join-member-clusters.ps1`)](https://github.com/kubefleet-dev/kubefleet/tree/main/hack/quickstart/join-member-clusters.ps1) that can automate the process of joining one or more cluster to a fleet.

To use this script successfully make sure:

* You know the hub and member cluster names.
* Your kubeconfig includes all clusters. This includes the hub and all members you want to join.
* You have the KubeFleet version to deploy (i.e. 0.3.1)
* You have the IP address of the hub cluster (i.e. 172.18.0.2)

Unless you made any modifications, the hub cluster's API server will listen on port 6443.

On MacOSX or Linux you can use this shell script:

```sh
./join-member-clusters.sh 0.3.1 kind-kf-hub-01 https://172.18.0.2:6443/ kind-kf-member-01
```

On Windows you can use PowerShell:

```powershell
.\join-member-clusters.ps1 0.3.1 kind-kf-hub-01 https://172.18.0.2:6443/ kind-kf-member-01
```

> Note: you can add multiple member clusters to join by adding them on the end of the argument list.

It may take a few minutes for the script to finish running. Once it is completed, the script will print out something
like this:

```output
NAME                  JOINED   AGE   MEMBER-AGENT-LAST-SEEN   NODE-COUNT   AVAILABLE-CPU   AVAILABLE-MEMORY
kind-kf-member-01     True     30s   28s                      1             748m           2870328Ki
```

The newly joined cluster should have the `JOINED` status field set to `True`.

If you see that the cluster is still in an unknown state, it might be that the member cluster is still connecting to the hub cluster. Should this state persist for a prolonged period, refer to the [Troubleshooting Guide](/docs/troubleshooting) for more information.

> Note: if you would like to know more about the steps the script runs, or would like to join a cluster into a KubeFleet manually, refer to the [Managing Clusters](/docs/how-tos/clusters) How-To Guide.

## Use KubeFleet to distribute resources to member clusters

KubeFleet offers two core APIs are used to schedule Kubernetes resources from the hub cluster to one or more member cluster:

* **ClusterResourcePlacement** - select cluster-scoped resources or entire namespaces and distribute to member clusters ([read more](../concepts/crp.md)).
* **ResourcePlacement** - select namespace-scoped resources and distribute to member clusters ([read more](../concepts/rp.md)).

For the purpose of this quickstart we will keep the example simple and use a ClusterResourcePlacement.

There are a comprehensive set of policies that can be used to determine how clusters are selected , how placements are rolled out using [staged update runs](../concepts/staged-update.md), and performing useful activities such as [drift detection](../how-tos/drift-detection.md) and [configuration overrides](../concepts/override.md).

### Create sample resources

First, let's make sure we're on our KubeFleet hub cluster.

```sh
kubectl config use-context kind-kf-hub-01
```

Next, create a namespace and a config map, which will be placed onto the member clusters.

```sh
kubectl create namespace kubefleet-sample
kubectl create configmap kf-cm -n kubefleet-sample --from-literal=data=test
```

It may take a few seconds for the commands to complete.

### Create placement policy

Now, let's create a simple `ClusterResourcePlacement` that will place the namespace and the config map it contains onto all member clusters.

Apply the following to your KubeFleet hub cluster.

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourcePlacement
metadata:
  name: sample-crp
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      version: v1
      name: kubefleet-sample
  policy:
    placementType: PickAll
```

The default rollout strategy is [RollingUpdate](../concepts/safe-rollout.md) for `ClusterResourcePlacement` and `ResourcePlacement`. When you submit the request, the rollout begins immediately. If you want more control you can used [staged update runs](../concepts/staged-update.md).

It may take a few seconds for KubeFleet to successfully place the resources. To check up on the progress, run the commands below:

```sh
kubectl get clusterresourceplacement sample-crp
```

> Note: you can shorten `clusterresourceplacement` to `crp` when using kubectl.

Verify that the placement has been completed successfully; you should see that the `SCHEDULED` status field has been set to `True`. You may need to repeat the commands a few times to wait for the completion.

```output
NAME         GEN   SCHEDULED   SCHEDULED-GEN   AVAILABLE   AVAILABLE-GEN   AGE
sample-crp   1     True        1               True        1               7s
```

### Confirm the placement

Now, connect to a member cluster to confirm that the placement has been completed and expected resources are present.

```sh
kubectl config use-context kind-kf-member-01
kubectl get ns
kubectl get configmap -n kubefleet-sample
```

You should see the namespace `kubefleet-sample` and the config map `kf-cm` listed in the output.

```output
NAME               DATA   AGE
kf-cm              1      15s
kube-root-ca.crt   1      15s
```

## Clean things up

To remove all the resources you just created, run the commands below:

```sh
# This would also remove the namespace and config map placed in all member clusters.
kubectl delete crp sample-crp

kubectl delete ns kubefleet-sample
kubectl delete configmap app -n kubefleet-sample
```

To uninstall KubeFleet components on the clusters, run the commands below:

```sh
kubectl config use-context kind-kf-member-01
helm uninstall member-agent -n fleet-system

kubectl config use-context kind-kf-hub-01
helm uninstall hub-agent -n fleet-system
```

## What's next

Congratulations! You have completed the getting started tutorial for KubeFleet. To learn more about KubeFleet:

* [Read about KubeFleet concepts](/docs/concepts)
* [Read about the ClusterResourcePlacement API](/docs/how-tos/crp)
* [Read about the ResourcePlacement API](/docs/how-tos/rp)
* [Read the KubeFleet API reference](/docs/api-reference)
