# GKE Layout Review

This review is intentionally repo-only. It evaluates the cluster architecture declared in Terraform and Flux without assuming `gcloud`, kubeconfig, or live cluster access.

## Declared Architecture

- Two regional Standard GKE clusters are declared in `terraform/gke.tf`.
- `cluster_a` acts as the config cluster for multicluster ingress in `terraform/fleet.tf`.
- Both clusters share a single global-routing VPC with region-local subnets and dedicated pod/services secondary ranges in `terraform/networking.tf`.
- Each cluster uses a single fixed-size node pool with `e2-standard-2` and `node_count = 2`.
- Gateway API standard channel and Fleet project membership are enabled for both clusters.
- Flux and Kubernetes providers are wired directly from the cluster module outputs in `terraform/providers.tf`.

## What This Layout Optimizes For

### Teaching clarity

The design is easy to follow:

- one VPC
- one subnet per region
- one cluster per region
- one node pool per cluster
- one config cluster for multicluster gateway

That makes the repo easier to understand than a more production-realistic multi-pool or shared-services design.

### Cost control

Zonal clusters with fixed-size pools are simpler and cheaper than regional clusters with autoscaling. That fits a learning repo better than a highly available production baseline.

### Integration visibility

The repo keeps Fleet, Flux bootstrap, Cloudflare, and Gateway concerns visible instead of hiding them behind additional abstractions.

## Strengths

- Uses pinned `terraform-google-modules/kubernetes-engine/google` `44.0.0`.
- Uses VPC-native networking with dedicated secondary CIDRs.
- Uses Workload Identity via `identity_namespace`.
- Uses release channels instead of unmanaged version pinning.
- Keeps the config-cluster choice explicit in `terraform/fleet.tf`.
- Keeps cluster provider wiring centralized in `terraform/providers.tf`.

## Risks And Trade-Offs

### Zonal clusters

Both clusters are zonal, not regional. That is acceptable for a teaching repo, but it reduces control-plane and node-plane availability compared to a production-style regional design.

### Fixed node pools

Each cluster has a single fixed-size pool with no autoscaling. That keeps the repo predictable, but it also means:

- less resilience during spikes
- less cost efficiency during idle periods
- no separation between system and application workloads

### Tight provider coupling

`terraform/providers.tf` depends on live cluster outputs. This is fine for bootstrap flows, but it means the main Terraform root remains unsuitable for default CI planning.

### Config cluster concentration

`cluster_a` is the only config cluster for multicluster ingress. That matches the intended pattern, but it makes the architecture asymmetric by design and should stay documented wherever cluster responsibilities are described.

## Recommended Repo-Only Improvements

### High priority

1. Add variable descriptions in `terraform/variables.tf` so the live root matches the stronger style already used in `terraform/ci/` and `terraform/modules/core/`.
2. Document why zonal clusters were chosen over regional clusters in a repo-facing doc so readers do not mistake the layout for a production default.
3. Add a short note in docs that the single node pool per cluster is for teaching simplicity, not workload isolation.

### Medium priority

1. Consider a second documented layout option for "production-like" regional clusters without changing the default implementation.
2. Consider a repo-only note on when autoscaling would be preferred.
3. Add a checklist for live review later: cluster versions, Fleet memberships, Gateway health, node pool sizing, and recommendation data.

## What Requires Live Review Later

The following cannot be confirmed from repo state alone:

- actual cluster version and patch level
- whether the release channel has drifted from expectations
- Fleet membership health
- Gateway reconciliation success
- MCS and ServiceImport behavior
- node utilization and sizing fitness
- real upgrade risk and recommendation output

## Suggested Next Live Review Inputs

When live access is available, review:

- `list_clusters`
- `get_cluster`
- `list_recommendations`
- GKE upgrade risk and best-practice reports from the MCP bundle

That should be treated as a separate phase from repo-only review.
