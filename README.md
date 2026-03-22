# Cloudflare + GKE + Flux Multi-Cluster Gateway Template

This repository is a reusable template for running two GKE clusters behind a single Cloudflare-protected public hostname.

## Architecture

```text
Internet
  -> Cloudflare (DNS, WAF, optional edge mTLS, client-facing TLS)
  -> Cloudflare Authenticated Origin Pulls
  -> GCP Global External HTTP(S) Load Balancer
  -> GKE Multi-Cluster Gateway (external only)
  -> Services running in Cluster A and Cluster B
```

Cloudflare can optionally provide edge mTLS for client certificate authentication. This template documents that step, but it is configured manually today and not provisioned by Terraform.

## What the template builds

- Cloudflare as only public edge
- shared GCP VPC, subnets, and Cloud NAT
- two regional GKE clusters
  - Cluster A: workload + config cluster
  - Cluster B: workload cluster
- Fleet membership, Multi-Cluster Services, and multi-cluster Gateway prerequisites
- one global static IP for external load balancer
- standard Flux bootstrap on both clusters
- GitOps-managed Gateway, HTTPRoute, workloads, and `ServiceExport`

## Read docs in this order

1. `docs/index.md`
2. `docs/deployment.md`
3. `docs/template-customization.md`
4. `docs/secrets-auth.md`
5. `docs/cloudflare.md`
6. `docs/gitops.md`
7. `docs/operations.md`

## Quick start

1. Create target GitHub repository and commit this template into it.
2. Replace required placeholders in `gitops/`.
3. Prepare Terraform inputs from `terraform/terraform.tfvars.example`.
4. Apply Terraform from `terraform/`.
5. Bootstrap Flux on Cluster A and Cluster B with standard Flux bootstrap using SSH deploy key authentication.
6. Confirm both clusters reconcile their own `gitops/clusters/<cluster-name>` path.
7. Verify public hostname resolves through Cloudflare to GCP external load balancer.

## Optional: Enable mTLS at Cloudflare Edge

For production deployments, enable mTLS at Cloudflare Edge for client certificate authentication.

**Security Best Practice:** Edge mTLS protects your API by requiring client certificates, allowing Cloudflare to inspect decrypted traffic for WAF and DDoS protection.

**How to enable:**

1. Go to **Cloudflare Dashboard** → **Security** → **API Shield** → **mTLS**
2. Generate or upload your client CA certificate
3. Select hostname(s) to protect
4. Set enforcement action: **block** (default), **log** (for troubleshooting), or **challenge** (Enterprise)
5. Generate and distribute client certificates signed by your CA
6. Test connectivity with `curl` using client certificates

**Note:** This configuration is done in Cloudflare Dashboard, not via Terraform. This template documents the setup process for reference.

## Template repository policy

This upstream repository is intended to be used as a template.

- Issues are welcome.
- Forks are welcome.
- Pull requests are not accepted against the upstream template repository.

If you want to make changes, create your own copy from the template and run the live workflows there.

## What this template does not do

- no third cluster
- no internal multi-cluster gateway
- no alternate ingress controller such as NGINX or Istio
- no Cloudflare tunnels
- no Terraform-managed workloads after Flux bootstrap

## Template repository note

This template keeps Flux bootstrap simple and recognizable.

- Terraform provisions infrastructure only.
- Flux is bootstrapped afterward with standard `flux bootstrap git` commands.
- Both clusters use SSH deploy key authentication for Git sync.

## Validation

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test

cd examples/minimal
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
