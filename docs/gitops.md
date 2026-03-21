# GitOps Structure

This template splits GitOps by cluster responsibility.

## Directory layout

```text
gitops/
├── apps/sample-app/
├── clusters/cluster-a/
├── clusters/cluster-b/
└── infrastructure/gateway/
```

## Cluster A

Cluster A is the config cluster.

It syncs:

- the Cluster A app overlay
- the multi-cluster Gateway Kustomization

Cluster A is the only cluster that should own:

- `Gateway`
- `HTTPRoute`
- gateway-related infrastructure manifests

## Cluster B

Cluster B is workload-only.

It syncs:

- the Cluster B app overlay

It does not own Gateway resources.

## Flux bootstrap model

Both clusters run Flux through Flux Operator.

Each cluster has:

- one `FluxInstance` named `flux`
- namespace `flux-system`
- Git source pointing at this repository

The only difference is the sync path:

- Cluster A -> `gitops/clusters/cluster-a`
- Cluster B -> `gitops/clusters/cluster-b`

## Why this split matters

- Flux installation is symmetric on both clusters
- Gateway ownership stays asymmetric
- service exports exist in both clusters
- the external ingress path stays consistent with the template architecture
