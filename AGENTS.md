# AGENTS.md

## Purpose

This repository is a reusable template for a Cloudflare-fronted, two-cluster GKE platform with Flux GitOps and an external multi-cluster Gateway.
Keep changes generic, production-aligned, and consistent with the documented traffic flow.

## Non-Negotiable Architecture

```text
Internet
  -> Cloudflare (DNS, WAF, TLS termination, mTLS validation)
  -> Cloudflare Authenticated Origin Pulls
  -> GCP Global External HTTP(S) Load Balancer
  -> GKE Multi-Cluster Gateway (external only)
  -> Services in Cluster A and Cluster B
```

- Cloudflare is the only public endpoint.
- mTLS validation (default) happens at Cloudflare edge, enabling WAF/DDoS inspection.
- mTLS can be disabled via `enable_cloudflare_mtls = false`.
- Gateway resources exist only on Cluster A.
- Cluster A is the config cluster.
- Cluster B is workload-only.
- Flux owns Kubernetes resources after bootstrap.

## Required Skills and Agents

- Start Terraform work with `terraform-style-guide`.
- Use `refactor-module` before changing Terraform module boundaries.
- Use `gitops-repo-audit` for Flux/GitOps review.
- Use the global `terratest-module-testing` agent for Go Terratest updates.
- Use the global `github-actions-expert` agent for workflow changes.
- Use the global Cloudflare skills for Cloudflare Terraform changes.
- Prefer CI-safe validation over real-cloud apply unless the task explicitly needs live infrastructure.

## Repository Layout

```text
.
├── .github/workflows/        # CI validation, plan, apply, and docs/workflow linting
├── docs/                     # User-facing technical how-to and reference docs
├── gitops/                   # Flux-managed cluster and infrastructure manifests
├── scripts/                  # Small utilities such as placeholder rendering/auditing
├── examples/minimal/         # Minimal no-cloud consumer example for modules/core
├── terraform/                # Live Terraform root
│   ├── ci/                   # CI-safe Terraform root
│   └── modules/core/         # Core infra module used by the CI-safe path
└── tests/terratest/          # Go Terratest suite
```

## Build, Lint, and Test Commands

### Terraform root

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
```

### Minimal example

```bash
cd examples/minimal
terraform init -backend=false
terraform validate
```

### CI-safe Terraform root

```bash
cd terraform/ci
terraform init -backend=false
terraform validate
terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars
```

### Terratest

```bash
cd tests/terratest
go test -v ./... -count=1 -timeout 30m
```

### Run one Terratest

```bash
cd tests/terratest
go test -v ./... -run TestTerraformFmt -count=1 -timeout 30m
go test -v ./... -run TestTerraformValidate -count=1 -timeout 30m
go test -v ./... -run TestTerraformPlanContract -count=1 -timeout 30m
go test -v ./... -run TestPinnedModuleAndProviderVersions -count=1 -timeout 30m
```

### GitOps validation

```bash
flux migrate -f . --dry-run
kustomize build gitops/infrastructure/gateway > /tmp/gateway.yaml
kustomize build gitops/apps/sample-app/overlays/cluster-a > /tmp/cluster-a.yaml
kustomize build gitops/apps/sample-app/overlays/cluster-b > /tmp/cluster-b.yaml
python3 scripts/check-template-placeholders.py
```

### Workflow linting

```bash
actionlint
```

### Docs structure validation

```bash
mkdocs build --strict
```

## Terraform Guidance

- Use lowercase snake_case for variables, locals, resources, and outputs.
- Keep `required_version` and `required_providers` in `versions.tf`.
- Keep provider configuration in `providers.tf`.
- Every variable and output must include `description`.
- Mark tokens and credentials as `sensitive = true`.
- Prefer pinned upstream modules over handwritten abstractions when they fit the architecture.
- Keep standard Flux bootstrap, Cloudflare, Certificate Manager, and provider-wiring edges explicit when modules do not improve clarity.

## GitOps Guidance

- Keep `gitops/` organized by cluster role and shared infrastructure.
- Cluster A syncs `gitops/clusters/cluster-a` and owns Gateway resources.
- Cluster B syncs `gitops/clusters/cluster-b` and does not own Gateway resources.
- Keep placeholders intentional and audit them with `scripts/check-template-placeholders.py`.
- Use `kustomization.yaml` to compose manifests and keep overlays minimal.

## Workflow Guidance

- Keep workflows pinned to immutable SHAs where already used.
- Keep downloaded CLI binaries checksum-verified.
- Default to `permissions: contents: read`; add only what is required.
- Keep apply paths manual and protected.

## Files To Treat Carefully

- `terraform/cloudflare.tf` and `terraform/certificates.tf` define the live edge model.
- `gitops/clusters/*/flux-system/*` define the standard Flux bootstrap model.
- `examples/minimal/*` should stay a minimal no-cloud consumer of `terraform/modules/core` only.
- `gitops/infrastructure/gateway/*` controls the external ingress path.
- `tests/terratest/testdata/ci.auto.tfvars` must remain fake but syntactically valid.

## Recommended Verification Before Finishing

```bash
cd terraform && terraform fmt -check -recursive && terraform init -backend=false && terraform validate
cd terraform && terraform test
cd examples/minimal && terraform init -backend=false && terraform validate
cd terraform/ci && terraform init -backend=false && terraform validate && terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars
cd tests/terratest && go test -v ./... -count=1 -timeout 30m
flux migrate -f . --dry-run
python3 scripts/check-template-placeholders.py
kustomize build gitops/infrastructure/gateway > /tmp/gateway.yaml
actionlint
mkdocs build --strict
```

## Known Constraints

- The live Terraform root still depends on real cloud credentials, but no longer bootstraps Flux through Terraform-managed cluster providers.
- The CI-safe Terraform root is the default path for contract-style validation.
- Multi-cluster Gateway behavior, Cloudflare DNS propagation, and Flux reconciliation still require live environment validation.
