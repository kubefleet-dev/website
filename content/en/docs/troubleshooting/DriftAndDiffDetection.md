---
title: CRP Drift Detection and Configuration Difference Check Unexpected Result TSG
description: Troubleshoot situations where CRP drift detection and configuration difference check features are returning unexpected results
weight: 8
---

This document helps you troubleshoot unexpected drift and configuration difference
detection results when using the KubeFleet CRP API.

> Note
>
> If you are looking for troubleshooting steps on diff reporting failures, i.e., when
> the `ClusterResourcePlacementDiffReported` condition on your CRP object is set to
> `False`, see the [CRP Diff Reporting Failure TSG](ClusterResourcePlacementDiffReported)
> instead.

> Note
>
> This document focuses on unexpected drift and configuration difference detection
> results. If you have encountered drift and configuration difference detection
> failures (e.g., no detection results at all with the `ClusterResourcePlacementApplied`
> condition being set to `False` with a detection related error), see the 
> [CRP Apply Op Failure TSG](ClusterResourcePlacementApplied) instead.

## Common scenarios

A drift occurs when a non-KubeFleet agent modifies a KubeFleet-managed resource (i.e., 
a resource that has been applied by KubeFleet). Drift details are reported in the CRP status
on a per-cluster basis (`.status.placementStatuses[*].driftedPlacements` field).
Drift detection is always on when your CRP uses a `ClientSideApply` (default) or
`ServerSideApply` typed apply strategy, however, note the following limitations:

* When you set the `comparisonOption` setting (`.spec.strategy.applyStrategy.comparisonOption` field)
to `partialComparison`, KubeFleet will only detect drifts in managed fields, i.e., fields
that have been explicitly specified on the hub cluster side. A non-KubeFleet agent can then
add a field (e.g., a label or an annotation) to the resource without KubeFleet complaining about it.
To check for such changes (field additions), use the `fullComparison` option for the `comparisonOption` field.
* Depending on your cluster setup, there might exist Kubernetes webhooks/controllers (built-in or from a
third party) that will process KubeFleet-managed resources and add/modify fields as they see fit.
The API server on the member cluster side might also add/modify fields (e.g., enforcing default values)
on resources. If your comparison option allows, KubeFleet will report these as drifts. For
any unexpected drift reportings, verify first if you have installed a source that triggers the changes.
* When you set the `whenToApply` setting (`.spec.strategy.applyStrategy.whenToApply` field)
to `Always` and the `comparisonOption` setting (`.spec.strategy.applyStrategy.comparisonOption` field)
to `partialComparison`, no drifts will ever be found, as apply ops from KubeFleet will
overwrite any drift in managed fields, and drifts in unmanaged fields are always ignored.
* Drift detection does not apply to resources that are not yet managed by KubeFleet. If a resource has
not been created on the hub cluster or has not been selected by the CRP API, there will not be any drift
reportings about it, even if the resource live within a KubeFleet managed namespace. Similarly, if KubeFleet
has been blocked from taking over a pre-existing resource due to your takeover setting
(`.spec.strategy.applyStrategy.whenToTakeOver` field), no drift detection will run on the resource.
* Resource deletion is not considered as a drift; if a KubeFleet-managed resource has been deleted
by a non-KubeFleet agent, KubeFleet will attempt to re-create it as soon as it finds out about the
deletion.
* Drift detection will not block resource rollouts. If you have just updated the resources on
the hub cluster side and triggered a rollout, drifts on the member cluster side might have been 
overwritten.
* When a rollout is in progress, drifts will not be reported on the CRP status for a member cluster if
the cluster has not received the latest round of updates.

KubeFleet will check for configuration differences under the following two conditions:

* When KubeFleet encounters a pre-existing resource, and the `whenToTakeOver` setting
(`.spec.strategy.applyStrategy.whenToTakeOver` field) is set to `IfNoDiff`.
* When the CRP uses an apply strategy of the `ReportDiff` type.

Configuration difference details are reported in the CRP status
on a per-cluster basis (`.status.placementStatuses[*].diffedPlacements` field). Note that the
following limitations apply:

* When you set the `comparisonOption` setting (`.spec.strategy.applyStrategy.comparisonOption` field)
to `partialComparison`, KubeFleet will only check for configuration differences in managed fields,
i.e., fields that have been explicitly specified on the hub cluster side. Unmanaged fields, such
as additional labels and annotations, will not be considered as configuration differences.
To check for such changes (field additions), use the `fullComparison` option for the `comparisonOption` field.
* Depending on your cluster setup, there might exist Kubernetes webhooks/controllers (built-in or from a
third party) that will process resources and add/modify fields as they see fit.
The API server on the member cluster side might also add/modify fields (e.g., enforcing default values)
on resources. If your comparison option allows, KubeFleet will report these as configuration differences.
For any unexpected configuration difference reportings, verify first if you have installed a source that
triggers the changes.
* KubeFleet checks for configuration differences regardless of resource ownerships; resources not
managed by KubeFleet will also be checked.
* The absence of a resource will be considered as a configuration difference.
* Configuration differences will not block resource rollouts. If you have just updated the resources on
the hub cluster side and triggered a rollout, configuration difference check will be re-run based on the
newer versions of resources.
* When a rollout is in progress, configuration differences will not be reported on the CRP status
for a member cluster if the cluster has not received the latest round of updates.

Note also that drift detection and configuration difference check in KubeFleet run periodically.
The reportings in the CRP status might not be up-to-date.

## Investigation steps

If you find an unexpected drift detection or configuration difference check result on a member cluster,
follow the steps below for investigation:

* Double-check the apply strategy of your CRP; confirm that your settings allows proper drift detection
and/or configuration difference check reportings.
* Verify that rollout has completed on all member clusters; see the [CRP Rollout Failure TSG](ClusterResourcePlacementRolloutStarted)
for more information.
* Log onto your member cluster and retrieve the resources with unexpected reportings.
    * Check if its generation (`.metadata.generation` field) matches with the `observedInMemberClusterGeneration` value
    in the drift detection and/or configuration difference check reportings. A mismatch might signal that the
    reportings are not yet up-to-date; they should get refreshed soon.
    * The `kubectl.kubernetes.io/last-applied-configuration` annotation and/or the `.metadata.managedFields` field might
    have some relevant information on which agents have attempted to update/patch the resource. KubeFleet changes
    are executed under the name `work-api-agent`; if you see other manager names, check if it comes from a known source
    (e.g., Kubernetes controller) in your cluster.

[File an issue to the KubeFleet team](https://github.com/kubefleet-dev/kubefleet/issues) if you believe that
the unexpected reportings come from a bug in KubeFleet.
