# Architecture

This template implements a fixed ingress model.

```text
Internet
  -> Cloudflare
  -> Cloudflare Authenticated Origin Pulls
  -> GCP Global External HTTP(S) Load Balancer
  -> GKE Multi-Cluster Gateway (external only)
  -> Services in Cluster A and Cluster B
```

## Traffic Rules

- Cloudflare is the only supported public endpoint.
- The GCP global external load balancer exists behind Cloudflare.
- Gateway resources exist only on Cluster A.
- Services are exported from both clusters through MCS.
- HTTPRoute targets the `ServiceImport` created from those `ServiceExport` resources.

## Platform Responsibilities

### Cloudflare

- public DNS
- WAF and edge termination
- Authenticated Origin Pulls enabled at the zone

### GCP

- VPC, subnets, NAT
- global static IP
- regional GKE clusters
- Fleet, MCS, and multi-cluster ingress prerequisites

### Flux

- GitOps ownership of Kubernetes resources after bootstrap
- Cluster A manages Gateway and HTTPRoute
- both clusters run the sample app and `ServiceExport`

## Ownership Boundary

- Terraform owns infrastructure and declarative Flux Operator bootstrap primitives on both clusters.
- Flux owns Kubernetes manifests after the operator installs the controllers and cluster sync resources.
- Both clusters reconcile from Git declaratively; only Cluster A carries the Gateway layer.
