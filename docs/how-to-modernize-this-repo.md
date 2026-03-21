# How To Modernize This Repo Safely

This repository is a learning template, so the goal is not just to change the code. The goal is to make the order of changes understandable, repeatable, and safe for future contributors.

## Why This Order Matters

The infrastructure in this repo has two very different kinds of concerns:

1. Core Google Cloud infrastructure that can be validated with Terraform alone
2. Live integration edges that need real credentials, real clusters, or both

If you mix those together too early, routine validation becomes fragile. That is why the modernization work starts by separating CI-safe Terraform from live bootstrap concerns.

## Recommended Order

### Step 1: Start With CI-Safe Verification

Create or maintain a validation path that does not require live GCP, GitHub, Kubernetes, or Cloudflare credentials.

In this repo, that means:

- `terraform/ci/` is the CI-safe Terraform root
- `terraform/modules/core/` is the reusable core infrastructure module used by CI
- `tests/terratest/` runs `fmt`, `validate`, and `plan` only

Why first:

- You need a safety net before large refactors
- You want contract regressions to show up in CI without needing a real environment
- You avoid blocking contributors on cloud access

Commands:

```bash
cd terraform/ci
terraform init -backend=false
terraform validate
terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars

cd tests/terratest
go test -v ./... -count=1 -timeout 30m
```

### Step 2: Extract Stable Core Infrastructure

Refactor the parts of the stack that are stable, reusable, and mostly provider-driven.

In this repo, that means:

- project API enablement
- VPC and subnets
- Cloud Router and NAT
- GKE cluster creation

Why second:

- These resources benefit most from pinned community modules
- They have well-defined interfaces and outputs
- They are the foundation for everything else in the repo

### Step 3: Replace Raw Resources With Pinned Modules Where It Helps

Use pinned versions so learning examples stay reproducible.

Current preferred module choices in this repo:

- `terraform-google-modules/project-factory/google//modules/project_services` `18.2.0`
- `terraform-google-modules/network/google` `16.1.0`
- `terraform-google-modules/cloud-router/google` `8.3.0`
- `terraform-google-modules/kubernetes-engine/google` `44.0.0`

Why these stay pinned:

- Provider compatibility becomes explicit
- Teaching examples do not drift unexpectedly
- CI failures are easier to diagnose

### Step 4: Keep Integration Edges Explicit

Do not force every resource into a module.

Keep these raw in this repo:

- `google_gke_hub_feature.mcs`
- `google_gke_hub_feature.ingress`
- `google_project_iam_member.mcs_network_viewer`
- `google_compute_global_address.gateway_ip`
- `flux_bootstrap_git.*`
- `cloudflare_dns_record.gateway`

Why:

- They are small, repo-specific, and easier to teach as direct resources
- Some depend on live cluster connectivity or external providers
- Wrapping them would hide more than it would simplify

### Step 5: Rewire Dependent Providers Only After Cluster Outputs Stabilize

The Kubernetes and Flux providers should consume stable cluster outputs after the GKE refactor.

In this repo:

- `terraform/providers.tf` reads cluster endpoint and CA data from the GKE module outputs
- `terraform/flux.tf` depends on the module-managed clusters and Fleet features

Why later:

- Provider wiring is brittle if the cluster implementation is still moving
- You want one stable source of truth for endpoint and CA values

### Step 6: Keep Terratest Focused On Contracts, Not Internals

The Terratest suite should verify behavior that matters to contributors:

- formatting still passes
- Terraform still validates
- the CI-safe plan still contains the expected resource contract
- pinned module and provider expectations do not drift silently

Why:

- Contract tests survive refactors better than implementation-detail tests
- They are faster and safer for default CI

## What To Verify After Each Change

Run these in order:

```bash
cd terraform && terraform fmt -check -recursive
cd terraform && terraform init -upgrade -backend=false && terraform validate
cd terraform/ci && terraform init -upgrade -backend=false && terraform validate
cd tests/terratest && go test -v ./... -count=1 -timeout 30m
/home/dm/.local/bin/kustomize build gitops/infrastructure/gateway > /tmp/gateway.yaml
/home/dm/.local/bin/kustomize build gitops/apps/sample-app/overlays/cluster-a > /tmp/cluster-a.yaml
/home/dm/.local/bin/kustomize build gitops/apps/sample-app/overlays/cluster-b > /tmp/cluster-b.yaml
```

## When To Use Real Infrastructure

Use real infrastructure only when the question is specifically about:

- Flux bootstrap behavior
- Cloudflare DNS behavior
- Fleet feature behavior against real GKE memberships
- Gateway behavior across live clusters

Routine CI and local verification should stay plan-based.

## How Agents Should Approach This Repo

- Start with `terraform-style-guide`
- Use `refactor-module` before extracting or replacing Terraform modules
- Use the global `terratest-module-testing` agent for Go Terratest work
- Prefer CI-safe changes first, live integration changes second
- Explain not only what changed, but why the ordering matters
