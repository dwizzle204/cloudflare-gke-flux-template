# Repo Enhancement Roadmap

This repository now includes a CI-safe Terratest foundation, and the modernization path is intentionally staged so contributors can learn the order as well as the mechanics.

Start with `docs/how-to-modernize-this-repo.md` for the recommended sequence and rationale.

## Immediate Foundation

- `tests/terratest/` provides plan-based and validate-based coverage with no real cloud resources.
- `terraform/ci/` isolates core Google infrastructure so tests avoid Flux, Kubernetes, and Cloudflare providers.
- `terraform/modules/core/` gives the test suite a reusable target for future refactoring.
- The global OpenCode agent `terratest-module-testing` is installed for Terratest generation and refactoring work.

## Preferred Module Migration Targets

When replacing raw Terraform resources with pinned modules, prefer these candidates first:

1. `terraform-google-modules/project-factory/google//modules/project_services` pinned to `18.2.0`
2. `terraform-google-modules/network/google` pinned to `16.1.0`
3. `terraform-google-modules/cloud-router/google` pinned to `8.3.0`
4. `terraform-google-modules/kubernetes-engine/google` pinned to `44.0.0`

## Resources That Should Stay Raw

- `google_gke_hub_feature.mcs`
- `google_gke_hub_feature.ingress`
- `google_project_iam_member.mcs_network_viewer`
- `flux_bootstrap_git.*`
- `cloudflare_dns_record.gateway`
- `google_compute_global_address.gateway_ip`

These edges are either provider-specific, small enough to stay explicit, or not clearly improved by wrapping them in a module.

## Testing Strategy

- Default CI and local verification should use `fmt`, `validate`, and `plan` only.
- Flux, Cloudflare, and live cluster behavior should remain manual or dedicated integration-test concerns.
- Negative-path Terratest cases should assert stable error substrings and avoid real applies unless explicitly requested.

## Agent Guidance

- Use `terraform-style-guide` before authoring Terraform changes.
- Use `refactor-module` before extracting or replacing modules.
- Use `terratest-module-testing` for any new Go-based Terraform tests.
- Use `verification-before-completion` before claiming the repo changes are done.
