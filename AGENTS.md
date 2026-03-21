# AGENTS.md

## Purpose

This repository is a learning template for multi-region GKE, fleet features, Flux GitOps, and Cloudflare-backed ingress.
Prefer safe, reviewable changes that keep the repo usable as a teaching reference.

## Agent Workflow

- Use the globally installed Terraform skills on this server when they apply.
- Start with `terraform-style-guide` for Terraform authoring and review.
- Use `refactor-module` before extracting reusable Terraform modules.
- Use `terraform-test` when creating or reviewing `.tftest.hcl` tests.
- Use `terraform-stacks` only if introducing Terraform Stacks files.
- Use `run-acceptance-tests` only for real acceptance tests that touch cloud resources.
- Use the global `terratest-module-testing` agent for Go Terratest work, especially CI-safe tests, negative-path tests, staged tests, and workflow updates.
- Prefer CI-safe validation and plan-based tests over `terraform apply`; this repo should not require real credentials for routine verification.

## Repository Layout

```text
.
├── .github/workflows/        # CI validation and Terratest workflows
├── docs/                     # Architecture and operations notes
├── gitops/                   # GitOps-managed Kubernetes manifests
├── scripts/                  # Small repo utilities
├── terraform/                # Primary Terraform root
│   ├── ci/                   # CI-safe Terraform root without Flux/Cloudflare
│   └── modules/core/         # Core infra module for CI-safe plan testing
└── tests/terratest/          # Go Terratest suite
```

## Build, Lint, and Test Commands

### Terraform Root

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

### Terraform CI Wrapper

Use the CI-safe root for plan-based checks that must not touch Flux, Cloudflare, or live clusters.

```bash
cd terraform/ci
terraform init -backend=false
terraform validate
terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars
```

### Single Terraform-Focused Verification

```bash
cd terraform
terraform fmt terraform/modules/core

cd terraform/ci
terraform validate
```

### Terratest

```bash
cd tests/terratest
go mod tidy
go test -v ./... -count=1 -timeout 30m
```

### Run A Single Terratest

```bash
cd tests/terratest
go test -v ./... -run TestTerraformFmt -count=1 -timeout 30m
go test -v ./... -run TestTerraformValidate -count=1 -timeout 30m
go test -v ./... -run TestTerraformPlanContract -count=1 -timeout 30m
```

### Flux / GitOps Validation

```bash
kustomize build gitops/infrastructure/gateway > /tmp/gateway.yaml
kustomize build gitops/apps/sample-app/overlays/cluster-a > /tmp/cluster-a.yaml
kustomize build gitops/apps/sample-app/overlays/cluster-b > /tmp/cluster-b.yaml
```

### Run A Single Manifest Build

```bash
kustomize build gitops/infrastructure/gateway
kustomize build gitops/apps/sample-app/overlays/cluster-a
kustomize build gitops/apps/sample-app/overlays/cluster-b
```

### GitHub Actions

```bash
gh workflow run terraform-validate.yaml
gh workflow run gitops-validate.yaml
gh workflow run terratest.yaml
```

## Terraform Design Guidance

- Prefer Google verified modules or well-maintained `terraform-google-modules/*` modules when they clearly improve reuse.
- Pin module versions explicitly when using registry modules.
- Keep simple integration edges as raw resources when modules do not add clarity, especially Fleet features, Flux bootstrap, and Cloudflare DNS.
- Favor a layered structure: core cloud infrastructure in reusable modules, external/bootstrap integrations at the root.
- Keep CI-safe Terraform separate from live/bootstrap Terraform when providers need real credentials or cluster endpoints.

## Terraform Code Style

- Use lowercase snake_case for variables, locals, resources, and outputs.
- Put `required_version` and `required_providers` in `versions.tf`.
- Put provider configuration in `providers.tf`.
- Keep variables and outputs descriptive; every new variable and output should include `description`.
- Use 2-space indentation and rely on `terraform fmt`.
- Prefer `for_each` over `count` for stable addressing when iterating resources.
- Keep locals focused on shared values or derived expressions; do not hide core logic in large locals blocks.
- Use explicit `depends_on` only when Terraform cannot infer the dependency.
- Mark secrets and tokens as `sensitive = true`.
- Do not hardcode environment-specific values outside examples or test fixtures.

## Imports, Naming, and Types

- For Go Terratest code, keep imports grouped by standard library, third-party, then internal packages.
- Keep Go packages small and purpose-specific: `internal/testenv` for paths/env and `internal/terraformrun` for shell-based helpers.
- Prefer concrete types for decoded plan structures instead of `map[string]interface{}` everywhere.
- Use clear test names that describe behavior, e.g. `TestTerraformPlanContract`.
- Keep Terraform resource names descriptive but concise, e.g. `cluster_a`, `gateway_ip`, `required`.

## Error Handling and Testing Expectations

- Prefer tests that fail for contract regressions, not implementation details.
- For Terratest negative-path scenarios, prefer `terraform.InitAndApplyE` and assert stable error substrings.
- For CI-safe tests in this repo, prefer `terraform validate`, `terraform plan`, and `terraform show -json`; avoid `apply` unless the user explicitly wants real integration testing.
- Keep cleanup explicit for any future apply-based tests.
- Use `t.Parallel()` only when tests do not share mutable working state.
- Do not depend on live GCP, GitHub, or Cloudflare credentials in default CI.

## Flux / Kubernetes Manifest Style

- Use `kustomization.yaml` to compose resources.
- Keep base manifests reusable and overlays minimal.
- Use lowercase resource names.
- Avoid environment-specific duplication when a patch or overlay is enough.
- Keep manifests minimal and composable for teaching clarity.

## Files To Treat Carefully

- `terraform/providers.tf` wires live Kubernetes and Flux providers from real cluster outputs.
- `terraform/flux.tf` and `terraform/cloudflare.tf` are live-integration concerns and are not part of the CI-safe Terratest plan path.
- `tests/terratest/testdata/ci.auto.tfvars` must stay fake but syntactically valid.

## Recommended Verification Before Finishing

```bash
cd terraform && terraform fmt -check -recursive
cd terraform && terraform init -backend=false && terraform validate
cd terraform/ci && terraform init -backend=false && terraform validate
cd tests/terratest && go test -v ./... -count=1 -timeout 30m
kustomize build gitops/infrastructure/gateway > /tmp/gateway.yaml
```

## Known Constraints

- The main Terraform root cannot be fully planned in CI without live credentials because Flux, Kubernetes, and Cloudflare providers are part of the graph.
- Use `terraform/ci` for contract-style plan tests.
- Multi-cluster Gateway behavior, Flux bootstrap, and Cloudflare DNS still require manual or integration validation against real infrastructure.
