# Deployment Order

Use this page as the main runbook.

## Prerequisites

You need:

- Terraform
- `gcloud`
- `kubectl`
- `flux` v2.8 or newer
- `kustomize`
- an existing Cloudflare zone
- an existing GitHub repository that contains this template

## Step 1: Prepare the repository

Push this template to the GitHub repository that Flux will sync from.

Expected result:

- the repository exists
- the default branch exists
- Flux can later read from the final Git URL

## Step 2: Replace template placeholders

Follow `template-customization.md` before you run Terraform.

At minimum, replace the placeholders used by:

- `gitops/clusters/cluster-a/apps-sample.yaml`
- `gitops/clusters/cluster-b/apps-sample.yaml`
- `gitops/infrastructure/gateway/gateway.yaml`
- `gitops/infrastructure/gateway/httproute.yaml`

Expected result:

- GitOps manifests point at your real repository, branch, hostname, and certificate map name

## Step 3: Prepare Terraform inputs

Copy `terraform/terraform.tfvars.example` into your private tfvars source and fill in real values.

Required categories:

- GCP project and regions
- Cloudflare zone and hostname
- Cloudflare account ID for mTLS
- Git repository owner, name, and branch
- Gateway hostname
- Secrets and tokens
- mTLS configuration (enabled by default, Cloudflare-managed CA)

If you want a no-cloud smoke check before apply, run the minimal example and native Terraform tests first.

```bash
cd terraform
terraform init -backend=false
terraform test

cd ../examples/minimal
terraform init -backend=false
terraform validate
```

If you want a CI-safe contract plan before the live apply, also run the dedicated CI root:

```bash
cd ../terraform/ci
terraform init -backend=false
terraform validate
terraform plan -refresh=false -lock=false -input=false -var-file=../../tests/terratest/testdata/ci.auto.tfvars
```

What this does:

- validates the reusable core infrastructure path
- confirms the core resource contract still plans cleanly

What this does not do:

- provision Cloudflare resources
- provision certificate resources in the live root
- bootstrap Flux
- deploy the platform

## Step 3.5: Configure mTLS (enabled by default)

By default, the template requires mTLS authentication. Configure these in your `terraform.tfvars`:

```hcl
# Cloudflare account for mTLS certificate management
cloudflare_account_id = "<your-cloudflare-account-id>"

# mTLS configuration (enabled by default)
# Set to false to disable mTLS and allow public access
enable_cloudflare_mtls = true

# Action when mTLS validation fails: block, log, or challenge
mtls_enforcement_action = "block"

# Name of Cloudflare-managed CA certificate
cloudflare_client_ca_name = "mtls-client-ca"
```

**Important:**
- `enable_cloudflare_mtls = true` is the default. All clients must present valid client certificates.
- To disable mTLS and allow public access, set `enable_cloudflare_mtls = false`.
- The Cloudflare-managed CA is generated automatically during `terraform apply`.
- Retrieve the CA certificate from the Cloudflare dashboard after apply to generate client certificates.

### After Terraform apply

1. Go to **Cloudflare Dashboard** → **SSL/TLS** → **Client Certificates**
2. Download the Cloudflare-managed CA certificate
3. Use this CA to sign client certificates for your authorized clients
4. Test connectivity with `curl` using client certificates

### Troubleshooting tip

If you need to test or troubleshoot mTLS validation, temporarily change `mtls_enforcement_action` from `"block"` to `"log"`. This allows requests without valid certificates but logs validation failures for analysis. Remember to switch back to `"block"` for production.

## Step 4: Apply Terraform

Run:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform will:

- create the GCP network and clusters
- configure the Cloudflare edge
- create the certificate resources for the HTTPS origin path
- leave both clusters ready for standard Flux bootstrap

## Step 5: Bootstrap Flux on both clusters

Use standard Flux bootstrap with SSH deploy key authentication.

Create a read-only deploy key in the target GitHub repository, then run the bootstrap command once per cluster context.

Cluster A:

```bash
flux bootstrap git \
  --url=ssh://git@github.com/<owner>/<repo> \
  --branch=<branch> \
  --path=gitops/clusters/cluster-a \
  --private-key-file=<path-to-private-key> \
  --components=source-controller,kustomize-controller,helm-controller
```

Cluster B:

```bash
flux bootstrap git \
  --url=ssh://git@github.com/<owner>/<repo> \
  --branch=<branch> \
  --path=gitops/clusters/cluster-b \
  --private-key-file=<path-to-private-key> \
  --components=source-controller,kustomize-controller,helm-controller
```

Expected result:

- Flux is installed in `flux-system` on both clusters
- Cluster A syncs `gitops/clusters/cluster-a`
- Cluster B syncs `gitops/clusters/cluster-b`

## Step 6: Verify Flux bootstrap

Fetch cluster credentials first:

```bash
gcloud container clusters get-credentials <cluster-a-name> --region <region-a> --project <project-id>
gcloud container clusters get-credentials <cluster-b-name> --region <region-b> --project <project-id>
```

Then verify the standard Flux resources:

```bash
kubectl --context <cluster-a-context> -n flux-system get gitrepositories,kustomizations
kubectl --context <cluster-b-context> -n flux-system get gitrepositories,kustomizations
```

Expected result:

- both clusters report a `GitRepository` and `Kustomization` in `flux-system`

## Step 7: Verify GitOps reconciliation

Check that:

- Cluster A reconciles `gitops/clusters/cluster-a`
- Cluster B reconciles `gitops/clusters/cluster-b`
- Gateway and HTTPRoute exist only on Cluster A
- `ServiceExport` exists in both clusters

## Step 8: Verify ingress

Confirm that:

- Cloudflare proxies the public hostname
- the hostname resolves to the GCP external load balancer path through Cloudflare
- traffic reaches the sample workload through the multi-cluster Gateway
- mTLS is enforced (try connecting without a client certificate - should be blocked by default)
- Valid client certificates can successfully connect

## What to do next

- Use `operations.md` for routine validation commands
- Use `cloudflare.md` for edge-specific details
- Use `gitops.md` if you need to understand how the two cluster sync paths are divided
