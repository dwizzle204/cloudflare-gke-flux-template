# Deployment Steps

## Prerequisites

- Terraform
- `gcloud`
- `kubectl`
- `flux` v2.8 or newer
- `kustomize`
- existing Cloudflare zone
- existing GitHub repository

## Step 1: Prepare variables

Copy `terraform/terraform.tfvars.example` and provide real values through `terraform.tfvars` or your secret injection path.

## Step 2: Apply Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform provisions GCP infrastructure, Cloudflare edge resources, installs Flux Operator on both clusters, and creates one FluxInstance per cluster.

## Step 3: Verify Flux Operator bootstrap

After Terraform completes, confirm that both clusters have a `flux` FluxInstance in the `flux-system` namespace.

Example:

```bash
kubectl --context <cluster-a-context> -n flux-system get fluxinstance flux
kubectl --context <cluster-b-context> -n flux-system get fluxinstance flux
```

Both FluxInstance resources should sync the cluster-specific Git paths declaratively:

- Cluster A -> `gitops/clusters/cluster-a`
- Cluster B -> `gitops/clusters/cluster-b`

## Migrating from Flux bootstrap to Flux Operator

If you already have clusters bootstrapped with `flux bootstrap`, migrate them before adopting this template's operator-managed pattern.

Recommended sequence:

1. Upgrade to a modern Flux CLI (`v2.8+`).
2. Run the migration check from the repo root:

```bash
flux migrate -f . --dry-run
```

3. Follow the Flux Operator migration guide for existing bootstrapped clusters:

https://fluxoperator.dev/docs/guides/migration/

4. After migration, the steady-state model should be:

- Flux Operator installed on both clusters
- one `FluxInstance` named `flux` in `flux-system` on each cluster
- cluster-specific `sync.path` values pointing at this repository

Do not keep a mixed model where one cluster uses operator-managed Flux and another still depends on manual bootstrap.

## Step 4: Verify GitOps reconciliation

Check that:

- Cluster A reconciles `gitops/clusters/cluster-a`
- Cluster B reconciles `gitops/clusters/cluster-b`
- Gateway and HTTPRoute exist only on Cluster A
- `ServiceExport` exists in both clusters

## Step 5: Verify ingress

Confirm that the Cloudflare hostname resolves through Cloudflare and routes to the sample workload through the GCP global external load balancer and multi-cluster Gateway.
