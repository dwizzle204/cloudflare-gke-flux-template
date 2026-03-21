# GitOps Structure

The `gitops/` tree is split by cluster role and shared infrastructure.

```text
gitops/
├── apps/sample-app/
├── clusters/cluster-a/
├── clusters/cluster-b/
└── infrastructure/gateway/
```

## Cluster A

Cluster A is the config cluster.

It reconciles:

- sample app overlay for Cluster A
- multi-cluster Gateway Kustomization

## Cluster B

Cluster B is workload-only.

It reconciles:

- sample app overlay for Cluster B

## Shared infrastructure

`gitops/infrastructure/gateway` contains the external multi-cluster Gateway resources that must exist only on Cluster A.

## Bootstrap model

Both clusters run Flux through Flux Operator.

- Cluster A FluxInstance syncs `gitops/clusters/cluster-a`
- Cluster B FluxInstance syncs `gitops/clusters/cluster-b`

This keeps Flux installation declarative on both clusters while preserving the asymmetric Gateway ownership model.

## How FluxInstance maps to this repo

Each cluster has the same operator-managed control plane shape:

- `FluxInstance` name: `flux`
- namespace: `flux-system`
- source kind: `GitRepository`
- source URL: this repository
- source ref: the configured Git branch

Only the sync path changes between clusters.

### Cluster A syncs

- `gitops/clusters/cluster-a`
- This path includes the app overlay Kustomization for Cluster A
- This path also includes the multi-cluster Gateway Kustomization

### Cluster B syncs

- `gitops/clusters/cluster-b`
- This path includes only the app overlay Kustomization for Cluster B
- It does not include Gateway resources

This is the key best-practice split in the template:

- Flux installation is symmetric
- Gateway ownership is asymmetric
