# Skill Audit Report

This report summarizes the repo-only audit work done with the installed Flux, GitHub Actions, and GKE skills.

## Flux Audit

### What was validated

- Flux resource discovery completed successfully.
- Flux CR manifests validated successfully.
- Kustomize builds for the sample app overlays and gateway manifests completed successfully.

### Changes applied

- Added `timeout` to both `GitRepository` resources.
- Added `retryInterval` and `timeout` to all Flux `Kustomization` resources.

These changes improve retry behavior and make reconciliation more predictable when source fetches or applies fail transiently.

### Deprecated API check status

The installed `gitops-repo-audit` skill uses `flux migrate -f . --dry-run` as its preferred deprecated-API check. That design is correct because it uses Flux's own migration logic instead of a handwritten rule set.

After upgrading the local Flux CLI to `v2.8.3`, the check worked as expected and reported:

- `no custom resources found that require migration`

Recommended repo practice:

1. Require a modern Flux CLI for repository audits.
2. Use `flux migrate -f . --dry-run` as the standard deprecated-API audit.
3. Treat fallback static manifest scanning as legacy-only troubleshooting, not the normal workflow.

Current repo state appears clean for the Flux APIs in use:

- `source.toolkit.fluxcd.io/v1`
- `kustomize.toolkit.fluxcd.io/v1`

## GitHub Actions Audit

### Changes applied

- Added least-privilege `permissions: contents: read` to PR workflows.
- Added `concurrency` controls to existing workflows.
- Updated `gitops-validate.yaml` to use pinned `kustomize` `v5.8.1` instead of the mutable `latest` download URL.
- Updated `terratest.yaml` so Terraform changes in the live root also trigger Terratest.
- Added `cache-dependency-path` for Go dependency caching in the Terratest workflow.
- Added `.github/workflows/actionlint.yaml` to lint workflow files.

### Why these changes matter

- Prevent unnecessary concurrent CI runs on stale PR states.
- Reduce workflow supply-chain drift by pinning tool downloads.
- Ensure Terraform changes that affect contracts still exercise the Terratest suite.
- Add dedicated workflow linting, which was previously missing.

## GKE Repo-Only Review

See `docs/gke-layout-review.md` for the full review.

High-level findings:

- The repo favors teaching clarity over production-level resiliency.
- The two-cluster zonal design is easy to understand but not highly available.
- Fixed-size pools are simple and predictable but not cost- or capacity-adaptive.
- The Fleet and Gateway design is explicit and understandable.
- Live review is still required for operational validation.

## Next Recommended Follow-Ups

1. Add variable descriptions in the live Terraform root for consistency with the stronger CI/module style.
2. Decide whether to keep the repo's default cluster layout intentionally zonal, or document an optional regional reference architecture.
3. Keep the repo audit environment on a modern Flux CLI so `flux migrate -f . --dry-run` remains the expected check.
