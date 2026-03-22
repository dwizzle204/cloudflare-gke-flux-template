# Minimal Example

This example shows the smallest practical consumer of `terraform/modules/core`.

## What it proves

- A user can call the reusable core module directly.
- The reusable module interface is coherent.
- The example initializes and validates without real cloud credentials.

## What it does not prove

- live GCP resource creation
- Cloudflare behavior
- Flux bootstrap runtime behavior
- end-to-end Gateway routing

## Run it

```bash
cd examples/minimal
terraform init -backend=false
terraform validate
```

## Why it targets `terraform/modules/core`

The live Terraform root includes Cloudflare, certificate resources, and the inputs needed for standard Flux bootstrap. That makes it the wrong surface for a small no-cloud example.

This example targets the reusable GCP infrastructure module only.
