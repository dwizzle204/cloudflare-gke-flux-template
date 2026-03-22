# Template Customization

Use this page before the first apply.

## Step 1: Set Terraform inputs

Prepare real values for:

- `project_id`
- `region_a`
- `region_b`
- `cloudflare_zone_name`
- `cloudflare_hostname`
- `gateway_hostname`
- `git_repository_owner`
- `git_repository_name`
- `git_branch`

Provide secure values for:

- `cloudflare_api_token`

## Step 2: Replace GitOps placeholders

This template intentionally ships with placeholders in the GitOps manifests.

Expected placeholders:

- `REPLACE_ME_GATEWAY_STATIC_IP_NAME`
- `REPLACE_ME_GATEWAY_HOSTNAME`
- `REPLACE_ME_GATEWAY_CERTIFICATE_MAP_NAME`
- `REPLACE_ME_GIT_BRANCH`
- `ssh://git@github.com/REPLACE_ME/REPLACE_ME`

These appear in:

- `gitops/infrastructure/gateway/gateway.yaml`
- `gitops/infrastructure/gateway/httproute.yaml`
- `gitops/clusters/cluster-a/flux-system/gotk-sync.yaml`
- `gitops/clusters/cluster-b/flux-system/gotk-sync.yaml`

## Step 3: Render placeholders

Run:

```bash
export GATEWAY_STATIC_IP_NAME="your-reserved-ip-name"
export GATEWAY_HOSTNAME="api.your-domain.example"
export GATEWAY_CERTIFICATE_MAP_NAME="your-gateway-cert-map"
export GIT_BRANCH="main"
export GIT_REPOSITORY_SSH_URL="ssh://git@github.com/your-org/your-repo"
python3 scripts/render-placeholders.py
```

Expected result:

- the GitOps manifests point at your real repository, branch, hostname, static IP name, and certificate map name

## Step 4: Prepare the SSH deploy key

Before running Flux bootstrap, create a read-only deploy key on the target GitHub repository.

Use the same repository SSH URL and branch that you rendered into the bootstrap placeholders.

## Step 5: Configure apply workflow secrets

If you use the built-in apply workflow, configure these GitHub Actions secrets:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`
- `TERRAFORM_TFVARS`

`TERRAFORM_TFVARS` should contain the full live tfvars content for the environment.

## Step 6: Validate before apply

Run:

```bash
terraform -chdir=terraform validate
terraform -chdir=terraform/ci validate
go test -v ./tests/terratest/... -count=1 -timeout 30m
flux migrate -f . --dry-run
kustomize build gitops/infrastructure/gateway
python3 scripts/check-template-placeholders.py
```
