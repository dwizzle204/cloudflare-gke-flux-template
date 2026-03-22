# Architecture

This template implements one ingress model only.

```text
Internet
  -> Cloudflare
  -> Cloudflare Authenticated Origin Pulls
  -> GCP Global External HTTP(S) Load Balancer
  -> GKE Multi-Cluster Gateway (external only)
  -> Services in Cluster A and Cluster B
```

## Traffic rules

- Cloudflare is the only supported public endpoint.
- The GCP global external load balancer exists behind Cloudflare.
- Gateway resources exist only on Cluster A.
- Services are exported from both clusters through MCS.
- HTTPRoute targets the `ServiceImport` created from those `ServiceExport` resources.

## Platform responsibilities

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

## Ownership boundary

- Terraform owns infrastructure only.
- Flux owns Kubernetes manifests after standard bootstrap installs controllers and sync resources on each cluster.
- Both clusters reconcile from Git. Only Cluster A carries the Gateway layer.
