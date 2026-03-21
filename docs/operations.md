# Operations

## Validate cluster registration

```bash
gcloud container fleet memberships list --project "$PROJECT_ID"
```

## Validate GatewayClasses on the config cluster

```bash
kubectl --context "$CONFIG_CONTEXT" get gatewayclasses
```

You should see `gke-l7-global-external-managed-mc`.

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

- Terraform changes:
  - infrastructure
  - cluster lifecycle
  - static IP
  - Cloudflare DNS
  - Flux bootstrap

- Flux changes:
  - Gateway / HTTPRoute
  - app manifests
  - namespace resources
  - ServiceExport
