# Operations

Use this page after the initial deployment is complete.

## No-cloud validation stack

Use these checks before you work with real credentials:

```bash
cd terraform
terraform init -backend=false
terraform test

cd examples/minimal
terraform init -backend=false
terraform validate

cd terraform/ci
terraform init -backend=false
terraform validate
terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars

cd tests/terratest
go test -v ./... -count=1 -timeout 30m
```

Use this stack for three different purposes:

- `terraform test` checks module-level config invariants quickly
- `examples/minimal` proves a consumer can call the reusable core module
- `terraform/ci` plus Terratest checks the broader template contract

## Validate cluster registration

```bash
gcloud container fleet memberships list --project "$PROJECT_ID"
```

## Validate GatewayClasses on the config cluster

```bash
kubectl --context "$CONFIG_CONTEXT" get gatewayclasses
```

Expected result: you should see `gke-l7-global-external-managed-mc`.

## Validate ServiceExport

```bash
kubectl --context "$CLUSTER_A_CONTEXT" -n sample-app get serviceexport
kubectl --context "$CLUSTER_B_CONTEXT" -n sample-app get serviceexport
```

## Validate ServiceImport on the config cluster

```bash
kubectl --context "$CONFIG_CONTEXT" -n sample-app get serviceimport
```

## Validate Gateway

```bash
kubectl --context "$CONFIG_CONTEXT" -n gateways get gateway
kubectl --context "$CONFIG_CONTEXT" -n gateways describe gateway sample-external
```

## Validate Flux

```bash
flux --context "$CLUSTER_A_CONTEXT" get all -A
flux --context "$CLUSTER_B_CONTEXT" get all -A
```

## Change management

Use Terraform for:

- infrastructure
- cluster lifecycle
- static IP
- Cloudflare DNS and edge settings
- Flux Operator and FluxInstance bootstrap primitives

Use GitOps for:

- Gateway and HTTPRoute
- application manifests
- namespace resources
- `ServiceExport`
