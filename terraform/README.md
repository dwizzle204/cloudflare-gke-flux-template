# Terraform layout

This directory contains the infrastructure layer.

## Main responsibilities

- create network and subnets
- create two GKE clusters
- enable required APIs
- register both clusters into the fleet
- enable MCS
- enable fleet ingress and point it at Cluster A as the config cluster
- reserve one global static IP for the external Gateway
- leave both clusters ready for standard Flux bootstrap
- create a Cloudflare proxied DNS record and enable Authenticated Origin Pulls

## Important

The repo you apply from must already exist in GitHub. Terraform prepares the infrastructure, while Flux is bootstrapped afterward with the standard Flux CLI flow on each cluster.

## Two Terraform roots

This repository intentionally has two Terraform entry points.

### `terraform/`

This is the live deployment root.

Use it to:

- provision GCP infrastructure
- configure the Cloudflare edge
- provision certificate resources for the HTTPS origin path

This is the root you use for a real deployment.

### `terraform/ci/`

This is the CI-safe validation root.

Use it to:

- validate the reusable core infrastructure contract
- run a no-cloud `terraform plan`
- support Terratest and workflow validation without live credentials

It is not a deployment entry point.

See `terraform/ci/README.md` for the exact purpose and commands.

## Suggested workflow

1. copy `terraform.tfvars.example` to your private secret store or local `terraform.tfvars`
2. run `terraform plan`
3. review
4. run `terraform apply`
5. bootstrap each cluster with `flux bootstrap git` using SSH deploy key auth
6. verify both clusters reconcile their cluster-specific Git paths
