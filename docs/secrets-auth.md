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

The template uses SSH deploy key authentication for Flux sync.

Recommended model:

- create a read-only SSH deploy key in the target GitHub repository
- use that key with `flux bootstrap git`
- let Flux create the in-cluster `flux-system` authentication secret during bootstrap

## mTLS client certificates

When mTLS is enabled (default behavior), clients must present valid certificates signed by the Cloudflare-managed CA.

### What Terraform creates

- Cloudflare-managed CA certificate for client authentication
- mTLS enforcement rules for the protected hostname

### What you must do

1. After `terraform apply`, retrieve the CA certificate from the Cloudflare dashboard
2. Generate client certificates signed by this CA for your authorized clients
3. Distribute client certificates to authorized clients
4. Configure clients to present certificates during the TLS handshake

### CA certificate location

Cloudflare Dashboard → SSL/TLS → Client Certificates → View/Download CA

### Do not commit

- Private keys for the CA or client certificates
- Any certificate material to the repository

### Custom CA (Enterprise)

If you need to use your own CA instead of the Cloudflare-managed CA, provide the `cloudflare_client_ca_certificate` variable with your PEM-encoded CA certificate content (Enterprise plan required).

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
- keep deploy key material out of the repository itself
