# Terratest

This suite is intentionally CI-safe.

- It does not call `terraform apply`.
- It validates the real root module with `fmt` and `validate`.
- It plans the isolated `terraform/ci` root with placeholder values and asserts a stable resource contract.

Run locally:

```bash
cd tests/terratest
go test -v ./... -count=1 -timeout 30m
```

Run a single test:

```bash
cd tests/terratest
go test -v ./... -run TestTerraformPlanContract -count=1 -timeout 30m
```
