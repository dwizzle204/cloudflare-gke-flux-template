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
