---
title: Cluster Claim Fulfillment
description: How a placement policy asks for clusters it cannot find, and how a cluster provider delivers them
weight: 2
---

A placement policy describes the clusters a workload needs. When the fleet has no cluster that
satisfies one of its selectors, the policy can ask for one: KubeFleet issues a **cluster claim**,
and a **cluster provider** — a controller you run, built on KubeFleet's fulfiller framework —
provisions a cluster for it and registers it with the fleet. This page describes the contract
between the two sides.

The claim is a hint, not a cluster specification. It carries the selector terms a cluster has to
satisfy; what a cluster looks like is the provider's business, described by a blueprint of the
provider's own (a Cluster API `ClusterClass`, for example).

## The objects

### `ClusterProviderClass`

A cluster-scoped, admin-owned object that routes claims to a provider and carries the knobs of
the provider's lifecycle, in the shape of a `StorageClass` or a `GatewayClass`:

```yaml
apiVersion: placement.kubefleet.dev/v1alpha1
kind: ClusterProviderClass
metadata:
  name: standard
  annotations:
    placement.kubefleet.dev/is-default-class: "true"
spec:
  provisionerName: capi.fulfiller.kubefleet.dev   # which provider serves this class; immutable
  parameters:                                     # opaque to KubeFleet, passed to the provider
    clusterClassName: standard
    kubernetesVersion: v1.33.0
    identity: fleet-member-agent-sa
  selectorVocabulary:                             # what the provider can act on
    labelKeys:
      - key: topology.kubernetes.io/region
        values: [eastus, westus]                  # optional; any value when omitted
    propertyKeys:
      - key: kubernetes-fleet.io/node-count
        min: "1"                                  # optional bounds
        max: "100"
  approval: Manual                                # the default; or Automatic
  pendingClaimTTL: 30m                            # from approval to acceptance (default 30m)
  maxProvisionDuration: 60m                       # from acceptance to completion (default 60m)
  joinTimeout: 30m                                # from completion to the cluster joining (default 30m)
  onFailure: Hold                                 # the default; or Retry, with retryAfter (default 15m)
```

A policy names its class in `spec.clusterProviderClassName`; a policy that names none uses the
fleet's single default class (the one annotated `placement.kubefleet.dev/is-default-class:
"true"`). With no class, or more than one default, no claim is issued and the policy's
`Scheduled` condition says why.

The **selector vocabulary** is what a selector may ask a provider for. A selector term outside it
— a label key or value the class does not list, a property key it does not list, or a property
comparison no value within the bounds can satisfy — gets no claim, and the policy's `Scheduled`
message names the term. Only terms that say what to provision are claimable: label matchers,
`In` label expressions, and `Eq`/`Gt`/`Ge`/`Lt`/`Le` property comparisons. `NotIn`, `Exists`,
`DoesNotExist` and `Ne` say what *not* to provision, which no blueprint can act on. A class with
no vocabulary admits only a selector with no terms. The vocabulary is checked when a claim would
be issued; a claim already outstanding is not withdrawn because its class vanished or its
vocabulary narrowed afterwards.

### `ClusterClaim`

A cluster-scoped object KubeFleet issues for each unfulfilled selector of a policy that has
`whenUnfulfilled: AddClusterClaim` (the default), one claim per selector, within the limits
below. Its spec is KubeFleet's: the policy it serves, the selector terms, and the class it was
routed to. Its status is written by three parties, one condition each:

| Condition   | Written by                                  | Meaning                                                                                                                                                             |
| ----------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Approved`  | an approver, or KubeFleet for `Automatic` classes | `True` lets a provider act; `False/Denied` is terminal and always held.                                                                                                |
| `Accepted`  | the provider                                | The provider took the claim; it also holds the `kubefleet.dev/fulfiller` finalizer from then on, which counts as acceptance by itself.                                   |
| `Completed` | the provider                                | `True/Fulfilled` with `status.provisionedClusterName` once the cluster is registered; `False/Failed` is terminal.                                                     |
| `Expired`   | KubeFleet                                   | `True` is terminal: `PendingTimeout` (nobody accepted within `pendingClaimTTL`), `JoinTimeout` (the cluster did not become eligible within `joinTimeout`), `NotMatching` (it did, but never satisfied the selector). |

An unapproved claim never expires: approval is the brake. Approval can be enforced by a
`ValidatingAdmissionPolicy` the hub agent's admission policy manager installs: only a requester
holding the `approve` verb on `clusterclaims` may add, remove, or change the `Approved` condition,
the way `CertificateSigningRequest` approval is gated. Grant the verb through RBAC to your
approvers; the hub agent holds it for automatic approvals. The policy is off until you enable it
(see [Enabling the APIs](#enabling-the-apis)); without it, anyone who may write a claim's status
may approve it.

A claim is **withdrawn** — deleted — when its selector is satisfied by other clusters, when the
selector's terms or the policy's class change, or when the policy is deleted. A claim whose
cluster joined and was counted is withdrawn too, and re-issued under the same name when the
selector still needs more: one claim yields one cluster.

A **terminal** claim (`Failed`, `Expired`, or `Denied`) is the record of what happened. It keeps
its name and its slot, is never written to again, and is named in the policy's `Scheduled`
message as held. Under `onFailure: Hold` it stays until the selector or class changes or an admin
deletes it; under `Retry` KubeFleet withdraws it `retryAfter` after it became terminal and issues
a fresh claim — except a denial and a `NotMatching` expiry, which are always held: the one is a
human's decision, the other's cluster is a fleet member nobody deprovisions.

### Limits

A policy has at most `spec.maxConcurrentClusterClaims` claims outstanding (default 1, at most 10,
in any state — terminal and unapproved claims occupy slots too), never more than the hub agent's
fleet-wide limit (`--max-concurrent-cluster-claims`, default 1, at most 100). The fleet-wide limit
counts the claims that hold a provider's attention: approved ones and those of `Automatic`
classes. It is exact for `Automatic` classes. For `Manual` classes it bounds issuance only —
approving several outstanding claims at once can exceed it, and the provider's own concurrency
limit is the backstop.

## Enabling the APIs

The placement policy APIs are off by default. The hub agent chart installs their CRDs either way;
the controllers, and the hub agent's RBAC for the group (including the `approve` verb on cluster
claims), come with `enablePlacementPolicyAPIs: true` (`--enable-placement-policy-apis`, which
also requires the v1beta1 APIs), and the fleet-wide claim limit with `maxConcurrentClusterClaims`
(`--max-concurrent-cluster-claims`). To gate approval, enable the admission policy manager
(`enableAdmissionPolicyManager: true`) and add `restrictClusterClaimApproval: {}` to its
configuration — a configuration file replaces the
manager's defaults, so list the other generators you want alongside it.

## Writing a cluster provider

A provider is a controller built on `pkg/v1/fulfiller`. It implements two methods and runs the
framework's reconciler, which watches the claims whose class names its `provisionerName`:

```go
type Provisioner interface {
    // Provision is called every PollInterval until it returns nil: the cluster named
    // Request.ClusterName is registered as a MemberCluster carrying Request.OwnershipLabels().
    // Any other error means "still provisioning"; wrap one with fulfiller.Permanent to fail
    // the claim at once.
    Provision(ctx context.Context, req Request) error
    // Deprovision removes whatever Provision created, and returns nil once nothing is left.
    Deprovision(ctx context.Context, req Request) error
}
```

The framework does the rest of the contract for you:

- it ignores claims that are unapproved, terminal, or stale (KubeFleet re-evaluates a claim
  when a cluster joins; a claim whose freshness marker is older than the newest cluster waits);
- it accepts a claim in two writes — its finalizer first, then `Accepted` — and never calls
  `Provision` on a claim that expired meanwhile;
- it derives the cluster name (`<claim name, truncated>-<hash of the claim UID>`, a DNS label of
  at most 49 characters) and records it on the claim before the first `Provision` call, so a
  restarted provider resumes rather than duplicates;
- it decides, on every call, whether this claim's own cluster already exists (resume), whether a
  previous claim of the same name left a registered cluster that stopped being eligible
  (`Remediate` it if the provider implements `Remediator`, else fail), or whether a new cluster
  is needed;
- it writes `Completed`, and turns transient errors into a failure once `maxProvisionDuration`
  has elapsed since acceptance;
- it applies **the one rule under every deprovision**: a cluster is deprovisioned only if it never
  joined the fleet *and* is not eligible for scheduling right now. A cluster that joined — on
  withdrawal, on `JoinTimeout`, on `NotMatching` — is left alone; it belongs to the fleet.

Run the conformance suite from `pkg/v1/fulfiller/conformance` in your provider's tests to prove
the pair: it starts an API server with KubeFleet's CRDs, runs the framework over your provider,
plays the policy controller and the approver, and asserts the contract above.

The hub agent's chart does not deploy providers. Give yours the two ClusterRoles under
`config/rbac/fulfiller/` (the framework's, and the provider's for creating and deleting
`MemberCluster` objects), bound to its own identity.

### The reference provider and the Cluster API bridge

`pkg/v1/fulfiller/reference` registers a `MemberCluster` and, when asked, simulates the member
agent's join — on a hub with a hub agent, by writing the `InternalMemberCluster`'s agent status,
which the hub's member-cluster webhook admits only from a whitelisted identity. It provisions
nothing; it exists for tests, demos, and as the smallest example of a provider.

`cmd/capi-fulfiller` (a binary and Dockerfile in the repository; no image or chart is released
yet) bridges claims to Cluster API: it renders a `Cluster` from a `ClusterClass`
named in the class's parameters (`clusterClassName`, `kubernetesVersion`, `namespace`), maps the
selector's `topology.kubernetes.io/region` label to the `region` variable by default
(`variable.<name>: <label key>` parameters add mappings), and registers the `MemberCluster` once
Cluster API reports the cluster provisioned. Label expressions and property terms have no inverse
that would pick an instance shape; the bridge refuses them as unsupported, and such a claim fails.

## The join hook

Registering a cluster is not joining it. A `MemberCluster` becomes eligible for scheduling only
once a member agent runs in the cluster and reports in, authenticating as the hub
`ServiceAccount` the `MemberCluster`'s `spec.identity` names — the one the class's `identity`
parameter gives the provider — which, with its token, must already exist, the way the member join
script creates them; nothing in KubeFleet creates either. Installing that agent is the platform's
step, after the provider registers the cluster and before `joinTimeout` runs out. The Cluster API
bridge hands off the cluster's kubeconfig by naming its Secret on the `MemberCluster`, in the
`capi.fulfiller.kubefleet.dev/kubeconfig-secret` annotation; an operator hook that watches for it,
installs the agent, and lets it join closes the loop. A cluster that never joins expires as
`JoinTimeout` and is deprovisioned.
