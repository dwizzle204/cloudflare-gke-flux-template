# AGENTS.md

## Build, Lint, Test Commands

### Terraform
```bash
cd terraform
terraform init                      # Initialize provider and backend
terraform fmt -check -recursive      # Check formatting
terraform validate                    # Validate syntax
terraform plan                        # Preview changes
terraform apply                       # Apply changes
terraform show                        # Show current state
terraform destroy -auto-confirm       # Destroy infrastructure
```

### Flux/GitOps
```bash
# Validate flux manifests
kustomize build flux/infrastructure/gateway > /tmp/gateway.yaml
kustomize build flux/apps/sample-app/overlays/cluster-a > /tmp/cluster-a.yaml
kustomize build flux/apps/sample-app/overlays/cluster-b > /tmp/cluster-b.yaml

# Apply to clusters
kubectl apply -f flux/infrastructure/gateway/
kubectl apply -f flux/apps/sample-app/base/
```

### GitHub Actions (CI/CD)
```bash
# Run terraform validation (in CI)
gh workflow run terraform-validate.yaml

# Run gitops validation (in CI)
gh workflow run gitops-validate.yaml
```

## Code Style Guidelines

### Terraform Code Style

**Organization**
- Group resources by logical domain: `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `versions.tf`
- Use `locals` blocks for shared values and calculated expressions
- Use `for_each` for multiple similar resources instead of `count`
- Avoid `count = 0` for resources that should never be created

**Naming Conventions**
- Resources: `snake_case`, e.g., `google_container_cluster.cluster_a`
- Variables: `lowercase_snake_case`, e.g., `project_id`, `region_a`
- Outputs: `uppercase_snake_case`, e.g., `cluster_a_endpoint`
- Locals: `lowercase_snake_case`, e.g., `required_services`
- Providers: Use `google` for GA APIs, `google-beta` for preview features

**Formatting**
- Use 2 spaces for indentation
- Place `required_version` at the top of `versions.tf`
- Add blank lines between resources
- Place provider configuration first in `providers.tf`
- Use `terraform fmt -check -recursive` before committing

**Variable and Output Styles**
- Group variables logically with `locals` section separators
- Provide descriptive `description` for all variables and outputs
- Use type constraints where appropriate: `string`, `number`, `bool`, or custom types
- Set sensible defaults for required values
- Use `validation` blocks for custom validation logic

**Error Handling**
- Use `depends_on` explicitly when relationships aren't clear
- Document sensitive values in variable defaults with `sensitive = true`
- For provider conflicts, specify provider in resource: `provider = google-beta`
- Use `for_each` to handle multiple resources with idempotent configs

### Flux/Kubernetes Manifest Style

**Manifest Organization**
- Use `kustomization.yaml` to group related manifests
- Organize by component: `base/` (common), `overlays/` (specific environments)
- Use `patchesStrategicMerge` for environment-specific overrides
- Use `images` list for image versioning

**Naming Conventions**
- Namespaces: `lowercase`, e.g., `production`
- Deployments: `lowercase`, e.g., `gateway-controller`
- Services: `lowercase`, e.g., `gateway-svc`
- Ingress/Gateway: `lowercase`, e.g., `api-gateway`

**Best Practices**
- Use resource annotations for Flux compatibility
- Avoid hardcoding values; use Helm charts when possible
- Keep manifests minimal and composable
- Use `flux reconcile` for cluster-specific updates

## Testing Approach

This repository uses validation workflows rather than automated testing:

1. **Terraform Validation**: Run `terraform validate` locally before committing
2. **Flux Validation**: Build manifests with `kustomize build` and validate YAML syntax
3. **CI/CD Workflows**: GitHub Actions run formatting and validation checks
4. **Manual Testing**: After applying changes, validate infrastructure and Gateway configuration in clusters

No unit tests exist; validation focuses on syntax and structural correctness.
