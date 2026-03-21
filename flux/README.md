# Flux configuration

This tree contains the GitOps-managed Kubernetes configuration.

## Cluster responsibilities

### cluster-a
- config cluster
- sample app
- multi-cluster external Gateway
- HTTPRoute

### cluster-b
- sample app only

## Why the Gateway only exists on cluster-a
For multi-cluster Gateway, the `Gateway`, `HTTPRoute`, and policy resources are applied only to the **config cluster**.

## Why both clusters export the same Service
The multi-cluster active-active pattern is simplest when both clusters export the same service name and namespace. MCS creates a `ServiceImport`, and the Gateway routes to that imported service.

References:
- https://docs.cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-services
- https://docs.cloud.google.com/kubernetes-engine/docs/how-to/deploying-multi-cluster-gateways
