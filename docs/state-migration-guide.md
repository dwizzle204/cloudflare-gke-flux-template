# Terraform State Migration Guide

This guide explains how to move from the original raw-resource layout to the current module-based layout without replacing live infrastructure.

## Why This Matters

Terraform tracks objects by resource address, not just by cloud identity.

When this repo moved from raw resources to modules, these addresses changed:

- `google_project_service.required[*]` -> `module.project_services.*`
- `google_compute_network.this` -> `module.vpc.*`
- `google_compute_subnetwork.cluster_a` -> `module.vpc.*`
- `google_compute_subnetwork.cluster_b` -> `module.vpc.*`
- `google_compute_router.*` -> `module.router_a.*` and `module.router_b.*`
- `google_compute_router_nat.*` -> `module.router_a.*` and `module.router_b.*`
- `google_container_cluster.cluster_a` -> `module.cluster_a.*`
- `google_container_cluster.cluster_b` -> `module.cluster_b.*`
- `google_container_node_pool.cluster_a` -> `module.cluster_a.*`
- `google_container_node_pool.cluster_b` -> `module.cluster_b.*`

If you run `terraform apply` against existing state without reconciling those address changes, Terraform may try to recreate resources.

## Recommended Migration Process

### Step 1: Back Up State

```bash
terraform state pull > state-backup.json
```

### Step 2: Refresh Your Understanding First

Run these before touching state:

```bash
terraform init -upgrade -backend=false
terraform validate
terraform providers
terraform state list
```

### Step 3: Inspect The Planned Address Changes

Use `terraform plan` and compare existing `terraform state list` output to the new module layout.

### Step 4: Move State Addresses Before Apply

Use `terraform state mv` for resources that are the same cloud object with a new Terraform address.

Representative examples:

```bash
terraform state mv google_compute_network.this module.vpc.module.vpc.google_compute_network.network
terraform state mv google_compute_subnetwork.cluster_a 'module.vpc.module.subnets.google_compute_subnetwork.subnetwork["us-central1/gke-a"]'
terraform state mv google_compute_subnetwork.cluster_b 'module.vpc.module.subnets.google_compute_subnetwork.subnetwork["us-east1/gke-b"]'
terraform state mv google_compute_router.nat_a module.router_a.google_compute_router.router
terraform state mv google_compute_router.nat_b module.router_b.google_compute_router.router
terraform state mv google_compute_router_nat.nat_a 'module.router_a.google_compute_router_nat.nats[0]'
terraform state mv google_compute_router_nat.nat_b 'module.router_b.google_compute_router_nat.nats[0]'
```

GKE module addresses can vary more by version and module internals, so inspect them first:

```bash
terraform state list | grep google_container
terraform plan
```

Then move the cluster and node pool addresses only after confirming the exact target addresses Terraform expects.

## Safer Alternative For GKE: Import Instead Of Guessing

For cluster and node pool resources, import can be safer than trying to predict internal module addresses manually.

Recommended workflow:

1. Migrate the simpler networking resources first with `terraform state mv`
2. Let Terraform show you the module-managed GKE addresses
3. Use `terraform import` for the cluster and node pool resources if the target addresses are unclear

## Migration Order

Use this order:

1. project services
2. VPC network
3. subnets and secondary ranges
4. routers and NATs
5. GKE clusters
6. GKE node pools
7. dependent Fleet, Flux, and Cloudflare verification

Why this order:

- Clusters depend on networking
- Provider wiring depends on cluster outputs
- Flux and Cloudflare sit on top of the cluster layer

## What To Avoid

- Do not run `terraform apply` first and hope Terraform matches objects automatically
- Do not guess module-internal resource addresses for GKE without checking `terraform plan`
- Do not migrate Flux or Cloudflare as part of the same risky step as cluster address changes

## Post-Migration Verification

After moves/imports, run:

```bash
terraform plan
```

Expected result:

- no replacement of the existing network, routers, NATs, clusters, or node pools
- only expected drift or intentional updates

Then run the repo verification flow:

```bash
cd terraform && terraform validate
cd terraform/ci && terraform validate
cd tests/terratest && go test -v ./... -count=1 -timeout 30m
```
