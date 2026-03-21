# GitOps configuration

This tree contains the GitOps-managed Kubernetes configuration.

## Cluster responsibilities

### cluster-a
- config cluster
- sample app
- multi-cluster external Gateway
- HTTPRoute

### cluster-b
- sample app only
- no Gateway resources

## Why the Gateway only exists on cluster-a
For multi-cluster Gateway, the `Gateway`, `HTTPRoute`, and policy resources are applied only to the **config cluster**.

## Why both clusters export the same Service
The multi-cluster active-active pattern is simplest when both clusters export the same service name and namespace. MCS creates a `ServiceImport`, and the Gateway routes to that imported service.

Both clusters are bootstrapped declaratively through Flux Operator and one `FluxInstance` per cluster.
