# How It Works

## 1. Terraform creates the platform

Terraform provisions:

- VPC and two subnets
- Cloud NAT
- Two regional GKE clusters
- Fleet membership
- Multi-Cluster Services feature
- Fleet ingress feature with Cluster A as the config cluster
- One global static IP for the external Gateway
- Certificate Manager resources (DNS authorization, certificate, cert map)
- Cloudflare DNS records (gateway and cert authorization)
- Cloudflare Authenticated Origin Pulls
- Cloudflare SSL mode (strict)
- Cloudflare mTLS configuration (Cloudflare-managed CA)
- Standard Flux bootstrap is NOT managed by Terraform

## 2. Flux takes over Kubernetes resources

After Terraform provisioning, you manually bootstrap Flux on both clusters using standard `flux bootstrap git` commands with SSH deploy key authentication.

After bootstrap, the standard Flux `Kustomization` in `flux-system` on each cluster reconciles its cluster-specific path:

### Cluster A syncs from `gitops/clusters/cluster-a`

- `gateways` namespace
- `sample-app` namespace and workload
- `ServiceExport` for `sample-app`
- External multi-cluster Gateway
- HTTPRoute for routing to `sample-app` via `ServiceImport`

### Cluster B syncs from `gitops/clusters/cluster-b`

- `sample-app` namespace and workload
- `ServiceExport` for `sample-app`

**Important:** Gateway resources exist ONLY on Cluster A. Cluster B only runs workload resources.

## 3. Google programs the external load balancer

The multi-cluster Gateway controller is Google-hosted. It watches the Gateway resources on Cluster A, uses Multi-Cluster Services (MCS) for cross-cluster service discovery, and programs the global load balancer to route traffic to both clusters.

The HTTPRoute backend references a `ServiceImport` (not a `Service`), which allows the Gateway to route to services across multiple clusters.

Reference: https://docs.cloud.google.com/kubernetes-engine/docs/how-to/prepare-environment-multi-cluster-gateways

## 4. Cloudflare fronts the hostname with mTLS

The template creates a proxied Cloudflare DNS record for the public hostname. Traffic flows as follows:

### Traffic flow

1. **Client → Cloudflare:** Users hit the Cloudflare edge
2. **Client certificate validation:** Cloudflare validates the client certificate against the managed CA
   - Invalid certificates: Request is blocked (default action)
   - Valid certificates: Proceed to inspection
3. **Cloudflare TLS termination:** Cloudflare terminates the client TLS connection
4. **WAF/DDoS inspection:** Cloudflare inspects decrypted traffic (this is why mTLS happens at Cloudflare, not GKE)
5. **Origin connection:** Cloudflare forwards to the GCP global IP via Authenticated Origin Pulls
6. **GCP LB:** Traffic hits the GCP Global External HTTP(S) Load Balancer over HTTPS
7. **GKE Gateway:** Gateway routes to services across both clusters

### Why mTLS at Cloudflare (not GKE)

**WAF/DDoS inspection:** If mTLS were implemented at the GKE Gateway, Cloudflare would be unable to inspect decrypted traffic for WAF rules or analyze traffic patterns for DDoS detection after TLS termination. With Cloudflare edge mTLS, the client certificate is validated first, then traffic is decrypted for inspection.

**Single enforcement point:** Client authentication happens at the first hop, blocking unauthorized clients before they consume GCP resources.

**Instant revocation:** Certificate revocation propagates instantly across Cloudflare's edge network.

### Why the HTTPRoute points to ServiceImport

For multi-cluster Gateway, `HTTPRoute` backend references must point to `ServiceImport`, not `Service`. This allows the Gateway to discover and route to services exported from multiple clusters via Multi-Cluster Services.
