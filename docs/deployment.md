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

Terraform provisions GCP infrastructure, Cloudflare edge resources, and bootstraps Flux on Cluster A only.

## Step 3: Bootstrap Cluster B Flux

After Terraform completes, bootstrap Flux on Cluster B using the same repository and the `gitops/clusters/cluster-b` path.

Example:

```bash
flux bootstrap github \
  --owner=<git_repository_owner> \
  --repository=<git_repository_name> \
  --branch=<git_branch> \
  --path=gitops/clusters/cluster-b
```

This keeps Terraform responsible for bootstrap on Cluster A only while still allowing Flux to manage Cluster B workloads.

## Step 4: Verify GitOps reconciliation

Check that:

- Cluster A reconciles `gitops/clusters/cluster-a`
- Cluster B reconciles `gitops/clusters/cluster-b`
- Gateway and HTTPRoute exist only on Cluster A
- `ServiceExport` exists in both clusters

## Step 5: Verify ingress

Confirm that the Cloudflare hostname resolves through Cloudflare and routes to the sample workload through the GCP global external load balancer and multi-cluster Gateway.
