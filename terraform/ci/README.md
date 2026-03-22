# Terraform CI Root

This directory is the CI-safe Terraform root.

## What it is for

Use `terraform/ci/` to validate the reusable core infrastructure contract without needing:

- Cloudflare credentials
- Flux bootstrap credentials
- live cluster access

It exists for local no-cloud checks and CI plan validation.

## What it includes

- the reusable `terraform/modules/core` module
- fake but syntactically valid input values from `tests/terratest/testdata/ci.auto.tfvars`
- provider configuration that supports validation and contract planning

## What it does not include

- Cloudflare edge resources
- Certificate Manager edge/bootstrap integration in the live root
- standard Flux bootstrap steps
- live Kubernetes or Git authentication

## When to use it

Use this root when you want to:

1. validate the core infrastructure shape
2. run a CI-safe `terraform plan`
3. catch regressions without cloud credentials

## When not to use it

Do not use `terraform/ci/` to deploy the platform.

Use `terraform/` for the real infrastructure deployment path.

## Commands

```bash
cd terraform/ci
terraform init -backend=false
terraform validate
terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars
```
