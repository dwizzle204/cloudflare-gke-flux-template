# Template Customization Checklist

Use this checklist before your first real deployment.

## Required replacements

### Terraform inputs

- Set `project_id`
- Set `region_a`
- Set `region_b`
- Set `cloudflare_zone_name`
- Set `cloudflare_hostname`
- Set `gateway_hostname`
- Set `git_repository_owner`
- Set `git_repository_name`
- Provide secure values for:
  - `cloudflare_api_token`
  - `github_token`

## GitHub Actions apply prerequisites

If you use the built-in `terraform-apply` workflow, configure these GitHub Actions secrets:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`
- `TERRAFORM_TFVARS`

`TERRAFORM_TFVARS` should contain the complete live tfvars content for the environment.

### GitOps placeholders

The following placeholders are expected in the template until you render or replace them:

- `REPLACE_ME_GATEWAY_STATIC_IP_NAME`
- `REPLACE_ME_GATEWAY_HOSTNAME`
- `https://github.com/REPLACE_ME/REPLACE_ME`

They appear in:

- `gitops/infrastructure/gateway/gateway.yaml`
- `gitops/infrastructure/gateway/httproute.yaml`
- `gitops/clusters/cluster-a/apps-sample.yaml`
- `gitops/clusters/cluster-b/apps-sample.yaml`

## Recommended rendering step

Export the real values and run:

```bash
export GATEWAY_STATIC_IP_NAME="your-reserved-ip-name"
export GATEWAY_HOSTNAME="api.your-domain.example"
export GIT_REPOSITORY_URL="https://github.com/your-org/your-repo"
python3 scripts/render-placeholders.py
```

## Cloudflare TLS expectations

This template enforces:

- Authenticated Origin Pulls enabled
- Cloudflare SSL mode set to `strict`
- `always_use_https` enabled

That means the GCP external HTTPS origin must present a certificate Cloudflare accepts for the configured hostname.

## Final pre-apply checks

Run:

```bash
terraform -chdir=terraform validate
terraform -chdir=terraform/ci validate
go test -v ./tests/terratest/... -count=1 -timeout 30m
flux migrate -f . --dry-run
kustomize build gitops/infrastructure/gateway
python3 scripts/check-template-placeholders.py
```
