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
- bootstrap Flux on both clusters
- create a Cloudflare proxied DNS record

## Important

The repo you apply from must already exist in GitHub. Flux bootstrap writes the initial `flux-system` manifests into this same repository.

## Suggested workflow

1. copy `terraform.tfvars.example` to your private secret store or local `terraform.tfvars`
2. run `terraform plan`
3. review
4. run `terraform apply`
