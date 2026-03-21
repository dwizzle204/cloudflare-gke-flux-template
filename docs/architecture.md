# Architecture

## High-level flow

```text
Internet
  -> Cloudflare proxied DNS
  -> GCP global external Application Load Balancer (via multi-cluster Gateway)
  -> Cluster A + Cluster B backends
```

## Cluster roles

### Cluster A
- workload cluster
- fleet member
- config cluster for fleet ingress / multi-cluster Gateway
- Flux bootstrap target

### Cluster B
- workload cluster
- fleet member
- Flux bootstrap target

## Why this split works

Google's multi-cluster Gateway model requires a **config cluster** where `Gateway`, `HTTPRoute`, and related policy objects are applied. The multi-cluster Gateway controller is Google-hosted and uses MCS to discover exported services across the fleet.

References:
- https://docs.cloud.google.com/kubernetes-engine/docs/concepts/multi-cluster-gateways
- https://docs.cloud.google.com/kubernetes-engine/docs/how-to/prepare-environment-multi-cluster-gateways

## DNS model

The template reserves a global static IP in Terraform and injects that name into the Gateway manifest using a `NamedAddress`. Cloudflare creates a proxied DNS record pointing to that IP.

Reference:
- https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-gateways

## Flux model

Terraform bootstraps Flux to both clusters. Cluster A syncs the gateway objects and the sample app. Cluster B syncs only the sample app. That keeps the GitOps model simple and avoids remote-cluster reconciliation complexity.

Reference:
- https://v2-0.docs.fluxcd.io/flux/installation/
