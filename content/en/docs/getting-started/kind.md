---
title: KubeFleet quickstart using kind clusters
description: Use kind clusters to learn about KubeFleet
weight: 3
---

In this tutorial, you deploy KubeFleet on [kind](https://kind.sigs.k8s.io/) clusters, which are Kubernetes clusters running locally via [Docker](https://docker.com/).

We'll help you understand KubeFleet's key architectural components, and introduce the custom resources and processes you can use for day-to-day multi-cluster management experience with very little setup needed.

> Note
>
> kind is a tool for setting up a Kubernetes environment for experimental purposes; Some instructions for running KubeFleet on kind clusters may not apply to other environments, and there might also be some minor differences in the KubeFleet experience.

## Before you begin

To complete this tutorial, you will need:

* The following tools on your local machine:
  * `docker`, to run agent images (and optionally build locally if you want)
  * `kind`, for running Kubernetes clusters on your local machine
  * `helm`, the Kubernetes package manager
  * `git`
  * `curl`
  * `jq`
  * `base64`

## Create kind clusters

The KubeFleet project provides a scalable multi-cluster solution that uses a hub and spoke pattern, consisting of one hub cluster and one or more member clusters:

* The hub cluster is the control plane to which every member cluster connects; it also serves as an interface for centralized management. You can perform a number of tasks focused on orchestrating Kubernetes resources across member clusters.
* A member cluster connects to the hub cluster and runs your workloads as orchestrated by the hub cluster.

In this tutorial you will create two kind clusters - one of which serves as the KubeFleet hub cluster, and the other the KubeFleet member cluster. Run the commands below to create them:

```sh
# Replace YOUR-KIND-IMAGE with a kind node image name of your
# choice. It should match with the version of kind installed
# on your system; for more information, see
# [kind releases](https://github.com/kubernetes-sigs/kind/releases).
export KIND_IMAGE=YOUR-KIND-IMAGE
# Replace YOUR-KUBECONFIG-PATH with the path to a Kubernetes
# configuration file of your own, typically $HOME/.kube/config.
export KUBECONFIG_PATH=YOUR-KUBECONFIG-PATH

# The names of the kind clusters; you may use values of your own if you'd like to.
export HUB_CLUSTER_NAME=hub
export MEMBER_CLUSTER_NAME=cluster-1

kind create cluster --name $HUB_CLUSTER_NAME \
    --image=$KIND_IMAGE \
    --kubeconfig=$KUBECONFIG_PATH
kind create cluster --name $MEMBER_CLUSTER_NAME \
    --image=$KIND_IMAGE \
    --kubeconfig=$KUBECONFIG_PATH

# Export the configurations for the kind clusters.
kind export kubeconfig -n $HUB_CLUSTER_NAME
kind export kubeconfig -n $MEMBER_CLUSTER_NAME
```

## Set up KubeFleet hub cluster

To set up the hub cluster, run the commands below.

Select the KubeFleet version you want to run by looking at the [KubeFleet GitHub Releases page](https://github.com/kubefleet-dev/kubefleet/releases) and pick a version.

```sh
# Set KubeFleet version
export KUBEFLEET_VERSION=0.2.2 
# Set the KubeFleet version you want to run (see )
# Replace YOUR-HUB-CLUSTER-CONTEXT with the name of the kubeconfig context for your hub cluster.
export HUB_CLUSTER_CONTEXT=YOUR-HUB-CLUSTER-CONTEXT
kubectl config use-context $HUB_CLUSTER_CONTEXT

# Install the helm chart for running KubeFleet agents on the hub cluster.
helm install hub-agent oci://ghcr.io/kubefleet-dev/kubefleet/charts/hub-agent \
    --version $KUBEFLEET_VERSION \
    --namespace fleet-system \
    --create-namespace \
    --set logFileMaxSize=100000
```

It will take a few seconds for the installation to complete. Once it finishes, verify that the KubeFleet hub agent is up and running with the commands below:

```sh
kubectl get pods -n fleet-system
```

You should see that all the hub-agent pods are in the ready state.

```output
NAME                         READY   STATUS    RESTARTS      AGE
hub-agent-7758b6559b-6w2t8   1/1     Running   0             117m
```

> Note: the hub cluster's Kubernetes API must be accessible to your member clusters. If it isn't possible to join member clusters to the fleet.

## Set up the KubeFleet member custer(s)

Next, let's set another kind cluster as a member cluster, which requires installing the KubeFleet member agent on the cluster and connecting it to the KubeFleet hub cluster.

For your convenience, KubeFleet provides a [quickstart script (`join-member-clusters.sh`)](https://github.com/kubefleet-dev/kubefleet/tree/main/hack/quickstart/join-member-clusters.sh) that can automate the process of joining a cluster into a KubeFleet. To use the script, follow the steps below:

```sh
# Clone KubeFleet repository, or download file to your computer.
# Run the script.
chmod +x ./hack/quickstart/join-member-clusters.sh
./hack/quickstart/join-member-clusters.sh <HUB-CLUSTER-NAME> <KUBEFLEET-VERSION> <MEMBER-CLUSTER-NAME-1> <MEMBER-CLUSTER-NAME-2> <MEMBER-CLUSTER-NAME-3> ...
```

It may take a few minutes for the script to finish running. Once it is completed, the script will print out something
like this:

```output
NAME              JOINED   AGE   MEMBER-AGENT-LAST-SEEN   NODE-COUNT   AVAILABLE-CPU   AVAILABLE-MEMORY
hub-cluster       True     30s   28s                      1             748m           2870328Ki
```

The newly joined cluster should have the `JOINED` status field set to `True`. If you see that the cluster is still in an unknown state, it might be that the member cluster is still connecting to the hub cluster. Should this state persist for a prolonged period, refer to the [Troubleshooting Guide](/docs/troubleshooting) for more information.

> Note
>
> If you would like to know more about the steps the script runs, or would like to join > a cluster into a KubeFleet manually, refer to the [Managing Clusters](/docs/how-tos/clusters) How-To Guide.

## Use `ClusterResourcePlacement` to place resources on member clusters

KubeFleet offers an API, `ClusterResourcePlacement`, which helps orchestrate workloads, i.e., any group Kubernetes resources, among all member clusters. In this last part of the tutorial, you will use this API to place some Kubernetes resources automatically into the member clusters via the hub cluster, saving the trouble of having to create them one by one in each member cluster.

### Create the resources for placement

Run the commands below to create a namespace and a config map, which will be placed onto the
member clusters.

```sh
kubectl create namespace kubefleet-sample
kubectl create configmap app -n kubefleet-sample --from-literal=data=test
```

It may take a few seconds for the commands to complete.

### Create the `ClusterResourcePlacement` API object

Next, create a `ClusterResourcePlacement` API object in the hub cluster:

```yaml
kubectl apply -f - <<EOF
apiVersion: placement.kubernetes-KubeFleet.io/v1
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
EOF
```

Note that the CRP object features a resource selector, which targets the `work` namespace you just created. This will instruct the CRP to place the namespace itself, and all resources registered under the namespace, such as the config map, to the target clusters. Also, in the `policy` field, a `PickAll` placement type has been specified. This allows the CRP to automatically perform the placement on all member clusters in the KubeFleet, including those that join after the CRP object is created.

It may take a few seconds for KubeFleet to successfully place the resources. To check up on the progress, run the commands below:

```sh
kubectl get clusterresourceplacement sample-crp
```

Verify that the placement has been completed successfully; you should see that the `APPLIED` status field has been set to `True`. You may need to repeat the commands a few times to wait for the completion.

### Confirm the placement

Now, log into the member clusters to confirm that the placement has been completed.

```sh
kubectl config use-context $MEMBER_CLUSTER_CONTEXT
kubectl get ns
kubectl get configmap -n kubefleet-sample
```

You should see the namespace `work` and the config map `app` listed in the output.

## Clean things up

To remove all the resources you just created, run the commands below:

```sh
# This would also remove the namespace and config map placed in all member clusters.
kubectl delete crp sample-crp

kubectl delete ns kubefleet-sample
kubectl delete configmap app -n kubefleet-sample
```

To uninstall KubeFleet, run the commands below:

```sh
kubectl config use-context $HUB_CLUSTER_CONTEXT
helm uninstall hub-agent -n fleet-system
kubectl config use-context $MEMBER_CLUSTER_CONTEXT
helm uninstall member-agent -n fleet-system
```

## What's next

Congratulations! You have completed the getting started tutorial for KubeFleet. To learn more about
KubeFleet:

* [Read about KubeFleet concepts](/docs/concepts)
* [Read about the ClusterResourcePlacement API](/docs/how-tos/crp)
* [Read the KubeFleet API reference](/docs/api-reference)
