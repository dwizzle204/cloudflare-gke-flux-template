# Cloudflare + GKE + Flux Multi-Cluster Gateway Template

This repository is a reusable, production-aligned template for deploying a two-cluster GKE platform with Cloudflare as the only public entry point.

## Architecture

```text
Internet
  -> Cloudflare (DNS, WAF, TLS termination)
  -> Cloudflare Authenticated Origin Pulls
  -> GCP Global External HTTP(S) Load Balancer
  -> GKE Multi-Cluster Gateway (external only)
  -> Services running in Cluster A and Cluster B
```

## What This Template Provisions

- Cloudflare proxied DNS for the public hostname
- Cloudflare Authenticated Origin Pulls enabled at the zone
- Shared GCP VPC, subnets, and Cloud NAT
- Two regional GKE clusters
  - Cluster A = workload + config cluster
  - Cluster B = workload cluster
- Fleet membership, Multi-Cluster Services, and multi-cluster Gateway prerequisites
- Global static IP for the external load balancer
- Flux Operator installation and FluxInstance bootstrap on both clusters using Terraform
- GitOps-managed Kubernetes resources under `gitops/`

## What This Template Does Not Do

- No third cluster
- No internal multi-cluster gateway
- No alternate ingress controller such as NGINX or Istio
- No Cloudflare tunnels
- No Terraform-managed workloads after Flux bootstrap

## Repository Layout

```text
.
├── .github/workflows/
├── docs/
├── gitops/
│   ├── apps/
│   ├── clusters/
│   └── infrastructure/
├── terraform/
└── tests/terratest/
```

## Deployment Order

1. Prepare input values from `terraform/terraform.tfvars.example`.
2. Apply Terraform in `terraform/` to provision GCP, Cloudflare, Flux Operator, and one FluxInstance per cluster.
3. Let each cluster reconcile its own `gitops/clusters/<cluster-name>` path.
4. Verify Gateway resources reconcile only on Cluster A.
5. Verify the Cloudflare hostname resolves through Cloudflare to the global external load balancer.

## Cluster Responsibilities

### Cluster A

- workload cluster
- config cluster for multi-cluster Gateway
- Gateway and HTTPRoute resources
- sample workload and ServiceExport

### Cluster B

- workload cluster only
- sample workload and ServiceExport
- no Gateway resources

## Variables

See:

- `docs/variables.md`
- `terraform/terraform.tfvars.example`

Required inputs include:

- GCP project and regions
- Cloudflare zone name, hostname, and API token
- GitHub repository owner/name and token
- Gateway hostname

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
```

## Documentation

- `docs/architecture.md`
- `docs/deployment.md`
- `docs/template-customization.md`
- `docs/variables.md`
- `docs/gitops.md`
- `docs/cloudflare.md`
