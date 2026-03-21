# How it works

## 1. Terraform creates the platform

Terraform provisions:

- VPC and two subnets
- Cloud NAT
- two GKE clusters
- fleet membership
- Multi-Cluster Services feature
- fleet ingress feature with Cluster A as the config cluster
- one global static IP for the external Gateway
- a Cloudflare proxied DNS record
- Flux bootstrap for Cluster A and Cluster B

## 2. Flux takes over Kubernetes resources

After bootstrap, Flux reconciles the manifests under `flux/clusters/*`.

### Cluster A syncs
- namespace
- sample app
- ServiceExport
- external multi-cluster Gateway
- HTTPRoute

### Cluster B syncs
- namespace
- sample app
- ServiceExport

## 3. Google programs the external load balancer

The multi-cluster Gateway controller is Google-hosted. It watches the Gateway resources on Cluster A, uses MCS for cross-cluster service discovery, and programs the global load balancer.

## 4. Cloudflare fronts the hostname

The template creates a proxied Cloudflare DNS record. Users hit the Cloudflare endpoint, which fronts the reserved GCP global IP.

## Why the route points to ServiceImport

For multi-cluster Gateway, `HTTPRoute` backend references must point to `ServiceImport`, not `Service`.

Reference:
- https://docs.cloud.google.com/kubernetes-engine/docs/how-to/prepare-environment-multi-cluster-gateways
