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
- install Flux Operator on both clusters
- create one FluxInstance on each cluster
- create a Cloudflare proxied DNS record and enable Authenticated Origin Pulls

## Important

The repo you apply from must already exist in GitHub. Terraform installs Flux Operator and creates one FluxInstance per cluster so both clusters reconcile declaratively from this repository.

## Suggested workflow

1. copy `terraform.tfvars.example` to your private secret store or local `terraform.tfvars`
2. run `terraform plan`
3. review
4. run `terraform apply`
5. verify both FluxInstance resources reconcile their cluster-specific Git paths
