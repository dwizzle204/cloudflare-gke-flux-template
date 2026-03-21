# GKE + Cloudflare + Flux Multi-Cluster Gateway Template

This repository is a reusable template for standing up:

- a shared GCP VPC
- two GKE clusters in two regions
- fleet registration and Multi-Cluster Services (MCS)
- a **config cluster** model where **Cluster A** is the multi-cluster Gateway config cluster
- Flux bootstrap from Terraform
- Flux-managed manifests that create a **global external multi-cluster Gateway**
- a static global IP and a Cloudflare proxied DNS record pointing at that IP
- a small sample application deployed into both clusters to validate the multi-cluster Gateway path

The template contains **no company-specific naming, domains, or policies**. Everything environment-specific is provided through variables.

## Architecture

- **Terraform owns** cloud infrastructure, GKE clusters, fleet features, static IPs, Cloudflare DNS, and Flux bootstrap.
- **Flux owns** Kubernetes objects after bootstrap, including:
  - Gateway
  - HTTPRoute
  - Namespace
  - sample app manifests
  - ServiceExport objects

## Design choices

### Why two clusters instead of three?
This template uses **two clusters total**:

- `cluster-a` = workload cluster **and** config cluster
- `cluster-b` = workload cluster

That keeps cost and operational overhead down while still supporting a multi-cluster Gateway.

### Why Flux on both clusters?
Flux is bootstrapped to both clusters:

- Cluster A syncs:
  - gateway objects
  - sample app
- Cluster B syncs:
  - sample app only

That avoids hub-spoke remote-apply complexity while still keeping Cluster A as the config cluster for the Google-hosted multi-cluster Gateway controller.

## Repository layout

```text
.
├── .github/workflows/
├── docs/
├── flux/
│   ├── apps/
│   │   └── sample-app/
│   └── clusters/
│       ├── cluster-a/
│       └── cluster-b/
└── terraform/
```

## Prerequisites

You need:

- a GCP project
- a Cloudflare zone already onboarded to Cloudflare
- a private GitHub repository you control
- Terraform/OpenTofu
- `gcloud`
- `kubectl`

You also need credentials for:

- Google Cloud
- Cloudflare API token
- GitHub PAT with repo write access for Flux bootstrap

## Supported platform notes

This template is designed around currently documented GKE multi-cluster Gateway prerequisites and Flux bootstrap patterns.

Key references:
- GKE multi-cluster Gateway prep: https://docs.cloud.google.com/kubernetes-engine/docs/how-to/prepare-environment-multi-cluster-gateways
- GKE multi-cluster Gateway deployment: https://docs.cloud.google.com/kubernetes-engine/docs/how-to/deploying-multi-cluster-gateways
- GKE Gateway named static addresses: https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-gateways
- Flux bootstrap with Terraform: https://v2-0.docs.fluxcd.io/flux/installation/
- Flux remote and workload identity docs: https://fluxcd.io/flux/components/kustomize/kustomizations/
- Cloudflare Terraform docs: https://developers.cloudflare.com/terraform/tutorial/

## Quick start

1. Create a private GitHub repository.
2. Copy this template into that repository.
3. Fill in `terraform/terraform.tfvars.example` and save it as `terraform.tfvars` or inject values through your pipeline.
4. Run Terraform from `terraform/`:
   - `terraform init`
   - `terraform plan`
   - `terraform apply`
5. Wait for Flux bootstrap to commit `flux-system` manifests into:
   - `flux/clusters/cluster-a/flux-system`
   - `flux/clusters/cluster-b/flux-system`
6. Let Flux reconcile the sample application and the multi-cluster Gateway.
7. Confirm:
   - `ServiceExport` exists in both clusters
   - `ServiceImport` is present on the config cluster
   - the Gateway gets the reserved global IP
   - the Cloudflare DNS name resolves to the Cloudflare proxied endpoint backed by the GCP global IP

## Apply sequence

### Terraform stage
Terraform does the following:

- enables required Google APIs
- creates the VPC and subnets
- creates Cluster A and Cluster B
- registers both clusters with the fleet
- enables MCS
- enables fleet ingress and sets Cluster A as the config cluster
- reserves the global IP used by the external Gateway
- bootstraps Flux to both clusters
- creates the Cloudflare DNS record

### Flux stage
Flux then applies:

- sample namespace
- sample Deployment / Service / ServiceExport
- Gateway
- HTTPRoute

The multi-cluster Gateway controller uses the config cluster plus MCS to discover backends across both clusters.

## Variables you must set

Minimum required values:

- `project_id`
- `region_a`
- `region_b`
- `zone_a`
- `zone_b`
- `cluster_a_name`
- `cluster_b_name`
- `cloudflare_api_token`
- `cloudflare_zone_id`
- `cloudflare_hostname`
- `git_repository_owner`
- `git_repository_name`
- `git_branch`
- `github_token`
- `gateway_hostname`

## Security notes

This template intentionally keeps security controls generic:

- Cloudflare DNS record is proxied
- the Gateway uses a reserved static global IP
- sample manifests are HTTP-only internally; you should add:
  - HTTPS listeners
  - Certificate Manager or Secret-backed certificates
  - Cloud Armor / GCPGatewayPolicy
  - Cloudflare AOP / origin auth
  - optional client mTLS at the GCP ingress layer

## CI/CD

The `.github/workflows` directory includes examples for:

- Terraform formatting and validation
- GitOps manifest validation with `kustomize`

The example workflows validate only. They do not auto-apply.

## Known caveats

- The bootstrap step requires the target GitHub repository to already exist.
- Some fleet-related Terraform resources may require the `google-beta` provider even when the underlying GCP feature itself is GA. This is a provider-surface issue, not necessarily a product-preview issue.
- This template keeps the sample application simple so you can validate the pattern before layering on product-specific software such as MuleSoft.

## Next hardening steps

After initial validation, add:

- Certificate Manager or Secret-backed HTTPS
- Cloudflare AOP and origin restrictions
- Cloud Armor policies
- SOPS or external secret management
- workload identity annotations for Flux controllers if you want remote-cluster management or GCP-integrated controllers
