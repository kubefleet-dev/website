---
title: Managing clusters
description: How to join or remove a cluster from a fleet, and how to view the status of and label a member cluster
weight: 2
---

This how-to guide discusses how to manage member cluster lifecycle in a fleet, specifically:

* how to add a cluster to a fleet; and
* how to remove a cluster from a fleet; and
* how to add labels to a member cluster.

## Add a cluster to a fleet

A cluster can join in a fleet if:

* it runs a [Kubernetes version](https://kubernetes.io/releases/version-skew-policy/) currently supported by KubeFleet ; and
* it has network connectivity to the hub cluster of the fleet.

### Use script to join clusters

For your convenience, KubeFleet provides scripts [(`join-member-clusters.sh`)](https://github.com/kubefleet-dev/kubefleet/tree/main/hack/quickstart/join-member-clusters.sh) and [(`join-member-clusters.ps1`)](https://github.com/kubefleet-dev/kubefleet/tree/main/hack/quickstart/join-member-clusters.ps1) that can automate the process of joining one or more cluster to a fleet.

To use this script successfully make sure:

* You know the hub cluster name (kf-hub-01) and member cluster names (my-member-cluster-01, my-member-cluster-02, my-member-cluster-03).
* Your kubeconfig includes all clusters. This includes the hub and all members you want to join.
* You have the KubeFleet version to deploy (i.e. 0.3.1)
* You have the IP address of the hub cluster (i.e. 172.18.0.2)

Unless you made any modifications, the hub cluster's API server will listen on port 6443.

On MacOSX or Linux you can use this shell script:

```sh
./join-member-clusters.sh 0.3.1 kf-hub-01 https://172.18.0.2:6443/ my-member-cluster-01 my-member-cluster-02 my-member-cluster-03
```

On Windows you can use PowerShell:

```powershell
.\join-member-clusters.ps1 0.3.1 kf-hub-01 https://172.18.0.2:6443/ my-member-cluster-01 my-member-cluster-02 my-member-cluster-03
```

> Note: you can add multiple member clusters to join by adding them on the end of the argument list.

It may take a few minutes for the script to finish running. Once it is completed, the script will print out something
like this:

```output
NAME                  JOINED   AGE   MEMBER-AGENT-LAST-SEEN   NODE-COUNT   AVAILABLE-CPU   AVAILABLE-MEMORY
my-member-cluster-01  True     30s   28s                      1             748m           2870328Ki
my-member-cluster-02  True     20s   18s                      1             748m           2870328Ki
my-member-cluster-03  True     10s   8s                       1             748m           2870328Ki
```

The newly joined cluster should have the `JOINED` status field set to `True`.

If you see that the cluster is still in an unknown state, it might be that the member cluster is still connecting to the hub cluster. Should this state persist for a prolonged period, refer to the [Troubleshooting Guide](/docs/troubleshooting) for more information.

Alternatively, if you would like to find out the exact steps the script performs, or if you feel like fine-tuning some of the steps, you may join a cluster manually to your fleet with the instructions below:

<details>

<summary>Joining a member cluster manually</summary>

1. Make sure that you have installed `kubectl`, `helm`, `curl`, `jq`, and `base64` in your
system.

2. Create a Kubernetes service account in your hub cluster:

    ```sh
    # Replace YOUR-HUB-CLUSTER-CONTEXT with the name of the kubeconfig
    # context you use for accessing your hub cluster.
    export HUB_CLUSTER_CONTEXT="YOUR-HUB-CLUSTER-CONTEXT"

    # Replace YOUR-MEMBER-CLUSTER with a name you would like 
    # to assign to the new member cluster.    
    # Note that the value of MEMBER_CLUSTER_NAME will be used as 
    # the name the member cluster registers with the hub cluster.
    export MEMBER_CLUSTER_NAME="YOUR-MEMBER-CLUSTER"

    export SERVICE_ACCOUNT="$MEMBER_CLUSTER_NAME-hub-cluster-access"

    kubectl config use-context $HUB_CLUSTER_CONTEXT
    # The service account can, in theory, be created in any namespace; for simplicity reasons,
    # here you will use the namespace reserved by KubeFleet installation, `fleet-system`.
    #
    # Note that if you choose a different value, commands in some steps below need to be
    # modified accordingly.
    kubectl create serviceaccount $SERVICE_ACCOUNT -n fleet-system
    ```

3. Create a Kubernetes secret of the service account token type, which the member cluster will use to access the hub cluster.

    ```sh
    export SERVICE_ACCOUNT_SECRET="$MEMBER_CLUSTER_NAME-hub-cluster-access-token"
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Secret
    metadata:
        name: $SERVICE_ACCOUNT_SECRET
        namespace: fleet-system
        annotations:
            kubernetes.io/service-account.name: $SERVICE_ACCOUNT
    type: kubernetes.io/service-account-token
    EOF
    ```

    After the secret is created successfully, extract the token from the secret:

    ```sh
    export TOKEN=$(kubectl get secret $SERVICE_ACCOUNT_SECRET -n fleet-system -o jsonpath='{.data.token}' | base64 -d)
    ```

    > Note: keep the token in a secure place; anyone with access to this token can access the hub cluster in the same way as the Fleet member cluster does.

    You may have noticed that at this moment, no access control has been set on the service account; KubeFleet will set things up when the member cluster joins. The service account will be given the minimum set of permissions for the KubeFleet member cluster to connect to the
    hub cluster; its access will be restricted to one namespace, specifically reserved for the member cluster, as per security best practices.

4. Register the member cluster with the hub cluster; KubeFleet manages cluster membership by creating a `MemberCluster` resource:

    ```sh
    cat <<EOF | kubectl apply -f -
    apiVersion: cluster.kubernetes-fleet.io/v1
    kind: MemberCluster
    metadata:
        name: $MEMBER_CLUSTER_NAME
    spec:
        identity:
            name: $SERVICE_ACCOUNT
            kind: ServiceAccount
            namespace: fleet-system
            apiGroup: ""
        heartbeatPeriodSeconds: 60
    EOF
    ```

5. Set up the member agent, the KubeFleet component that works on the member cluster end, to enable fleet connection:

    ```sh
    # Install the member agent helm chart on the member cluster.

    # Replace YOUR-MEMBER-CLUSTER-CONTEXT with the name of the kubeconfig context you use
    # for member cluster access.
    export MEMBER_CLUSTER_CONTEXT="YOUR-MEMBER-CLUSTER-CONTEXT"

    # Extract the hub cluster CA for secure TLS verification.
    # Run this while connected to the hub cluster context:
    export HUB_CA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"$HUB_CLUSTER_CONTEXT\")].cluster.certificate-authority-data}")

    # Configure bits to pull from OCI repo
    export KUBEFLEET_VERSION="0.3.1"
    export HUB_CONTROL_PLANE_URL="https://172.18.0.2:6443/"
    export MEMBER_AGENT_IMAGE="member-agent"
    export REFRESH_TOKEN_IMAGE="refresh-token"

    kubectl config use-context $MEMBER_CLUSTER_CONTEXT
    # Create the secret with the token extracted previously for member agent to use.
    kubectl create secret generic hub-kubeconfig-secret --from-literal=token=$TOKEN

    helm install member-agent oci://ghcr.io/kubefleet-dev/kubefleet/charts/member-agent \
      --version $KUBEFLEET_VERSION \
      --set config.hubURL=$HUB_CONTROL_PLANE_URL \
      --set config.hubCA=$HUB_CA \
      --set config.memberClusterName=$MEMBER_CLUSTER_NAME \
      --set logFileMaxSize=100000 \
      --namespace fleet-system \
      --create-namespace 

    # Enable Beta APIs by adding argument --set enableV1Beta1APIs=true
    ```

6. Verify that the installation of the member agent is successful on the member cluster:

    ```sh
    kubectl get pods -n fleet-system
    ```

    You should see that all the returned pods are up and running. Note that it may take a few minutes for the member agent to be ready.

7. Verify that the member cluster has joined the fleet successfully:

    ```sh
    kubectl config use-context $HUB_CLUSTER_CONTEXT
    kubectl get membercluster $MEMBER_CLUSTER_NAME
    ```

</details>

## Remove a cluster from a fleet

KubeFleet uses the `MemberCluster` resource to manage cluster memberships. To remove a member cluster from a fleet, delete the corresponding `MemberCluster` resource from the hub cluster:

```sh
# Replace YOUR-MEMBER-CLUSTER with the name of the
# member cluster you would like to remove from a fleet.
export MEMBER_CLUSTER_NAME=YOUR-MEMBER-CLUSTER
kubectl delete membercluster $MEMBER_CLUSTER_NAME
```

It may take a while before the member cluster leaves the fleet successfully. KubeFleet will perform some cleanup and all resources placed onto the cluster by KubeFleet will be removed.

After the member cluster leaves, you can remove the member agent installation from the cluster using Helm:

```sh
# Replace YOUR-MEMBER-CLUSTER-CONTEXT with the name of the
# kubeconfig context you use for member cluster access.
export MEMBER_CLUSTER_CONTEXT=YOUR-MEMBER-CLUSTER-CONTEXT
kubectl config use-context $MEMBER_CLUSTER_CONTEXT
helm uninstall member-agent
```

It may take a few moments before the uninstallation completes.

## Viewing the status of a member cluster

You can use `MemberCluster` on the hub cluster to view the status of a member cluster:

```sh
# Replace YOUR-MEMBER-CLUSTER with the name of the member 
# cluster of which you would like to view the status.
export MEMBER_CLUSTER_NAME=YOUR-MEMBER-CLUSTER
kubectl get membercluster $MEMBER_CLUSTER_NAME -o jsonpath="{.status}"
```

The status consists of:

* an array of conditions, including:

  * the `ReadyToJoin` condition, which signals whether the hub cluster is ready to accept
    the member cluster; and
  * the `Joined` condition, which signals whether the cluster has joined the fleet; and
  * the `Healthy` condition, which signals whether the cluster is in a healthy state.

    Typically, a member cluster should have all three conditions set to true. Refer to the [Troubleshooting Guide](/docs/troubleshooting) for help if a cluster fails to join into a fleet.

* the resource usage of the cluster; at this moment KubeFleet reports the capacity and the allocatable amount of each resource in the cluster, summed up from all nodes in the cluster.

* an array of agent status, which reports the status of specific KubeFleet agents installed in the cluster; each entry features:

  * an array of conditions, in which `Joined` signals whether the specific agent has been successfully installed in the cluster, and `Healthy` signals whether the agent is in a healthy state; and
  * the timestamp of the last received heartbeat from the agent.

## Adding labels to a member cluster

You can add labels to a `MemberCluster` resource in the same as with any other Kubernetes resource. These labels can then be used for targeting specific clusters in resource placement. To add a label, run the command below on the hub cluster:

```sh
# Replace the values of MEMBER_CLUSTER_NAME, LABEL_KEY, and LABEL_VALUE with those of your own.
export MEMBER_CLUSTER_NAME=YOUR-MEMBER-CLUSTER
export LABEL_KEY=YOUR-LABEL-KEY
export LABEL_VALUE=YOUR-LABEL-VALUE
kubectl label membercluster $MEMBER_CLUSTER_NAME $LABEL_KEY=$LABEL_VALUE
```
