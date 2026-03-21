# Secrets and Authentication

This template is built to avoid committing long-lived credentials.

## GCP authentication

Use GitHub Actions OIDC with Workload Identity Federation for live Terraform apply.

Required GitHub Actions secrets:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

The apply workflow uses `google-github-actions/auth` with those values.

## Cloudflare authentication

Use a scoped Cloudflare API token.

Required value:

- `cloudflare_api_token`

For GitHub Actions, provide it through `TERRAFORM_TFVARS` or your own secret injection path.

## Flux Git authentication

The template uses an HTTPS Git credential secret for Flux sync.

Required value:

- `github_token`

That token is written into the sync secret consumed by each `FluxInstance`.

## Apply workflow secrets

The built-in `terraform-apply` workflow expects:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`
- `TERRAFORM_TFVARS`

`TERRAFORM_TFVARS` should contain the complete live tfvars content for the target environment.

## Required rules

- do not commit `terraform.tfvars`
- do not commit API tokens or Git tokens
- prefer OIDC over static GCP credentials
- scope the Cloudflare token to zone/settings/DNS permissions only
- scope the Git token to the minimum repository access Flux needs
