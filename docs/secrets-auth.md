# Secrets and Authentication

This template is designed to keep long-lived credentials out of the repository.

## Recommended authentication model

### GCP

Use GitHub Actions OIDC with Workload Identity Federation for live Terraform apply.

Required GitHub Actions secrets:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

The `terraform-apply` workflow uses these values with `google-github-actions/auth@v2`.

### Cloudflare

Use a scoped Cloudflare API token.

Required value:

- `cloudflare_api_token`

For GitHub Actions, provide it inside the `TERRAFORM_TFVARS` secret or your chosen secret injection method.

### Git / Flux sync credentials

The template currently uses an HTTPS Git credential secret for the Flux sync source.

Required value:

- `github_token`

This token is stored in-cluster as the sync secret consumed by each `FluxInstance`.

## Recommended workflow secret model

For this generic template, the simplest protected-environment setup is:

- GitHub Actions secret: `TERRAFORM_TFVARS`
- GitHub Actions secret: `GCP_WORKLOAD_IDENTITY_PROVIDER`
- GitHub Actions secret: `GCP_SERVICE_ACCOUNT_EMAIL`

`TERRAFORM_TFVARS` should contain the full live `terraform.tfvars` content for the target environment.

## Why this template uses `TERRAFORM_TFVARS`

This keeps the apply workflow generic:

- no hardcoded environment-specific values in the repo
- one protected environment can hold one complete deployment configuration
- secret and non-secret values can be managed together for early template adoption

If you later want stronger separation, split non-secret values into GitHub environment variables and keep only secret values in GitHub secrets.

## Required secret handling rules

- Never commit `terraform.tfvars`
- Never commit API tokens or Git tokens
- Prefer OIDC over static GCP credentials
- Scope the Cloudflare token to only the required zone/settings/DNS permissions
- Scope the Git token to the minimum repository permissions needed for Flux sync
