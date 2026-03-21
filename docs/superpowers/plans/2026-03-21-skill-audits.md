# Skill Audits Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install the requested Flux, GitHub Actions, and GKE skills globally, apply repo-safe improvements, and produce a repo-only review of Flux, workflows, and cluster layout.

**Architecture:** Use an isolated worktree for repo changes, treat global skill installation separately from repository edits, and keep all verification CI-safe. Prefer built-in validation tools and repo-derived architecture review over live cloud access, and require a modern Flux CLI so the standard deprecated-API audit path uses `flux migrate -f . --dry-run`.

**Tech Stack:** Flux CD, Kustomize, GitHub Actions, Terraform, Terratest, Skillfish, OpenCode global agents/skills.

---

### Task 1: Install requested global capabilities

**Files:**
- Create: `/home/dm/.config/opencode/superpowers/agents/github-actions-expert.md`
- Install: `~/.agents/skills/gke-cluster-creator` via `skillfish`

- [ ] Fetch the GitHub Actions expert agent definition from GitHub.
- [ ] Write it into OpenCode's global agents directory.
- [ ] Install `GoogleCloudPlatform/gke-mcp` skill `gke-cluster-creator` globally with `skillfish`.
- [ ] Verify both installs by listing the installed agent/skill locations.

### Task 2: Re-apply and verify Flux audit improvements

**Files:**
- Modify: `gitops/clusters/cluster-a/apps-sample.yaml`
- Modify: `gitops/clusters/cluster-a/gateway.yaml`
- Modify: `gitops/clusters/cluster-b/apps-sample.yaml`

- [ ] Re-apply the Flux timeout and retryInterval improvements in this worktree.
- [ ] Run the installed Flux audit discovery and validation scripts.
- [ ] Capture any remaining actionable findings.

### Task 3: Harden GitHub Actions workflows

**Files:**
- Modify: `.github/workflows/terraform-validate.yaml`
- Modify: `.github/workflows/gitops-validate.yaml`
- Modify: `.github/workflows/terratest.yaml`

- [ ] Review the workflow files against the GitHub Actions expert guidance.
- [ ] Add least-privilege `permissions` blocks.
- [ ] Add safe `concurrency` settings for PR workflows.
- [ ] Replace unpinned `latest` install behavior where practical.
- [ ] Keep workflow scope aligned with current repo layout.

### Task 4: Document repo-only GKE layout review

**Files:**
- Create: `docs/gke-layout-review.md`

- [ ] Review `terraform/gke.tf`, `terraform/networking.tf`, `terraform/fleet.tf`, and related docs using the GKE skill guidance.
- [ ] Document the declared cluster architecture, strengths, risks, and next live-review prerequisites.
- [ ] Keep the report repo-only; do not assume `gcloud` or cluster access.

### Task 5: Verify all changes

**Files:**
- Verify: `gitops/**`
- Verify: `.github/workflows/**`
- Verify: `docs/gke-layout-review.md`

- [ ] Run Flux validation and kustomize builds.
- [ ] Run Terraform validate for `terraform/` and `terraform/ci/`.
- [ ] Run Terratest.
- [ ] Inspect git status and summarize remaining changes.
