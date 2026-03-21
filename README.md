# Cloudflare + GKE + Flux Multi-Cluster Gateway Template

This repository is a reusable template for running two GKE clusters behind a single Cloudflare-protected public hostname.

## Architecture

```text
Internet
  -> Cloudflare (DNS, WAF, TLS termination)
  -> Cloudflare Authenticated Origin Pulls
  -> GCP Global External HTTP(S) Load Balancer
  -> GKE Multi-Cluster Gateway (external only)
  -> Services running in Cluster A and Cluster B
```

## What the template builds

- Cloudflare as the only public edge
- shared GCP VPC, subnets, and Cloud NAT
- two regional GKE clusters
  - Cluster A: workload + config cluster
  - Cluster B: workload cluster
- Fleet membership, Multi-Cluster Services, and multi-cluster Gateway prerequisites
- one global static IP for the external load balancer
- Flux Operator and one `FluxInstance` per cluster
- GitOps-managed Gateway, HTTPRoute, workloads, and `ServiceExport`

## Read the docs in this order

1. `docs/index.md`
2. `docs/deployment.md`
3. `docs/template-customization.md`
4. `docs/secrets-auth.md`
5. `docs/cloudflare.md`
6. `docs/gitops.md`
7. `docs/operations.md`

## Quick start

1. Create the target GitHub repository and commit this template into it.
2. Replace the required placeholders in `gitops/`.
3. Prepare Terraform inputs from `terraform/terraform.tfvars.example`.
4. Apply Terraform from `terraform/`.
5. Confirm both clusters reconcile their own `gitops/clusters/<cluster-name>` path.
6. Verify the public hostname resolves through Cloudflare to the GCP external load balancer.

## What this template does not do

- no third cluster
- no internal multi-cluster gateway
- no alternate ingress controller such as NGINX or Istio
- no Cloudflare tunnels
- no Terraform-managed workloads after Flux bootstrap

## Validation

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate

cd terraform/ci
terraform init -backend=false
terraform validate
terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars

cd tests/terratest
go test -v ./... -count=1 -timeout 30m

flux migrate -f . --dry-run
kustomize build gitops/infrastructure/gateway
kustomize build gitops/apps/sample-app/overlays/cluster-a
kustomize build gitops/apps/sample-app/overlays/cluster-b
python3 scripts/check-template-placeholders.py
```
