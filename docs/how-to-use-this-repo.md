# How to Use This Repository



Step-by-step walkthrough for setting up the Cloudflare + GKE + Flux multi-cluster platform.

 This guide is for junior developers or operators following a guided setup.  

## Purpose

This runbook guides you through setting up a two-cluster GKE platform with Cloudflare edge protection and Flux GitOps.  

- **Who this is for**: Junior developers or operators setting up this template for the first time  
- **What you'll accomplish**: Working platform with public ingress reachable through Cloudflare  
- **Time estimate**: ~60-90 minutes (excluding cloud resource creation time)

## Prerequisites

You need the following tools installed and authenticated:

- **Terraform** 1.5 or newer  
- **gcloud** CLI (authenticated to target GCP project)  
- **kubectl**  
- **flux** CLI v2.8 or newer  
- **kustomize**  
- **python3** (for placeholder rendering script)  

## Required Access and Credentials

### GCP Access

You need a GCP project with sufficient permissions to create:

- VPC, subnets, Cloud NAT  
- 2 regional GKE clusters  
- Certificate Manager resources  
- Fleet membership and Multi-Cluster Services  

**To authenticate**:
```bash
gcloud auth application-default login
```

### Cloudflare Access

- Existing Cloudflare zone (will be looked up by name)  
- Cloudflare API token with **Zone:Edit**, **DNS:Edit** permissions  
- Zone:Read permission for zone lookup  

### GitHub Access

- Target GitHub repository (template cloned into your org)  
- Read-only deploy key created in repository settings  
- SSH private key for the deploy key (stored securely)  

### Local Setup

- Git repository cloned locally  
- Working internet connection  

---

## 1. Repository Setup

### Steps

1. **Clone the repository** to your local machine:
   ```bash
   git clone https://github.com/<your-org>/<your-repo>.git
   cd <your-repo>
   ```

2. **Verify the repository structure** exists:
   ```bash
   ls -la
   ```
   Expected: You should see `terraform/`, `gitops/`, `docs/` directories, and `scripts/render-placeholders.py`

3. **Create a branch** for your deployment (optional but recommended):
   ```bash
   git checkout -b your-branch
   ```

4. **Verify required scripts exist**:
   ```bash
   ls scripts/
   ```
   Expected: `render-placeholders.py` script exists

### Success Indicator
You can run `ls -la` and see `terraform/`, `gitops/`, `docs/` directories, and `scripts/render-placeholders.py` exists.

---

## 2. Terraform Variable Setup

### Steps

1. **Copy the example tfvars file**:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. **Edit the file** and replace all placeholder values with real values

3. **Verify no "replace-me" values remain**:
   ```bash
   grep -r "replace-me" terraform/terraform.tfvars
   ```
   Expected: No results

4. **(Optional) Run placeholder audit script** to catch missed placeholders:
   ```bash
   python3 scripts/render-placeholders.py --check-only
   ```

### Required Variables to Fill

| Variable | Description | Example Value |
|---------|-----------|-------------|
| `project_id` | GCP project ID | `123456789012` |
| `region_a` | First Cluster region | `canada-central1` |
| `region_b` | Second Cluster region | `northamerica-northeast1` |
| `cluster_a_name` | Name for Cluster A | `gke-config-a` |
| `cluster_b_name` | Name for Cluster B | `gke-workload-b` |
| `gateway_hostname` | Public hostname for the gateway | `api.example.com` |
| `cloudflare_hostname` | Same as gateway_hostname | `api.example.com` |
| `cloudflare_zone_name` | Cloudflare zone name | `example.com` |

### Secret Variables

Keep these secure:

- `cloudflare_api_token` - Your Cloudflare API token

**⚠️ STOP**: Before proceeding to Terraform, verify all variables are set correctly. Terraform will fail if any values are missing or invalid.

  

### Success Indicator
Running `terraform validate` in `terraform/` directory passes with no errors:
```bash
cd terraform
terraform validate
```

---

## 3. Running Terraform

### Steps

1. **Navigate to the terraform directory**:
   ```bash
   cd terraform
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```
   Read the output carefully to understand what will be created.

  

4. **Apply the plan**:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted.

### What Terraform Creates

Terraform provisions:

- GCP VPC with two regional subnets  
- Cloud NAT for outbound internet access  
- Two regional GKE clusters (Cluster A and Cluster B)  
- GCP Fleet membership and Multi-Cluster Services  
- One global static IP for the external Gateway  
- Certificate Manager resources (DNS auth, certificate, cert map)  
- Cloudflare DNS records (proxied hostname, unproxied DNS auth)  
- Cloudflare Authenticated Origin Pulls enabled  
- Cloudflare SSL mode set to `strict`  
- Cloudflare always-use-HTTPS enabled

### Success Indicator
Terraform apply completes with `Apply complete!` and outputs cluster connection details.

  

---

## 4. Verifying Infrastructure

### Steps

1. **Verify clusters exist**:
   ```bash
   gcloud container clusters list --project <project-id>
   ```
   Expected: Both clusters show status "RUNNING"

2. **Verify static IP exists**:
   ```bash
   gcloud compute addresses list --project<project-id>
   ```
   Expected: Static IP shows status "RESERVED"

3. **Verify Cloudflare DNS records**:
   Check Cloudflare Dashboard for A record with orange cloud icon.

4. **Verify certificate resources**:
   ```bash
   gcloud certificate-manager maps list --project<project-id>
   ```
   Expected: Certificate map shows status "ACTIVE"

### Success Indicators
- Both clusters show status "RUNNING"  
- Static IP shows status "RESERVED"  
- Cloudflare DNS record is proxied (orange cloud)  
- Certificate map shows status "ACTIVE"

**⚠️ STOP**: If any verification fails, do not proceed to Flux bootstrap. Terraform must complete successfully first.

  

---

## 5. Bootstrapping Flux on Cluster A

**IMPORTANT**: Cluster A is the config cluster - it owns the Gateway resources.

  

### Steps

1. **Get credentials for Cluster A**:
   ```bash
   gcloud container clusters get-credentials <cluster-a-name> --region <region-a> --project <project-id>
   ```

2. **Verify you can connect to Cluster A**:
   ```bash
   kubectl --context <cluster-a-context> get nodes
   ```
   Expected: List of nodes returned.

3. **Bootstrap Flux on Cluster A**:
   ```bash
   flux bootstrap git \
     --url=ssh://git@github.com/<owner>/<repo> \
     --branch=<branch> \
     --path=gitops/clusters/cluster-a \
     --private-key-file=<path-to-private-key> \
     --components=source-controller,kustomize-controller,helm-controller
   ```

### Success Indicator
Flux reports "✔ bootstrap finished" and shows GitRepository and Kustomization resources.

  

---

## 6. Bootstrapping Flux on Cluster B

**IMPORTANT**: Cluster B is workload-only - it does not own Gateway resources.  

### Steps

1. **Get credentials for Cluster B**:
   ```bash
   gcloud container clusters get-credentials <cluster-b-name> --region <region-b> --project<project-id>
   ```

2. **Verify you can connect to Cluster B**:
   ```bash
   kubectl --context <cluster-b-context> get nodes
   ```
   Expected: List of nodes returned.

3. **Bootstrap Flux on Cluster B**:
   ```bash
   flux bootstrap git \
     --url=ssh://git@github.com/<owner>/<repo> \
     --branch=<branch> \
     --path=gitops/clusters/cluster-b \
     --private-key-file=<path-to-private-key> \
     --components=source-controller,kustomize-controller,helm-controller
   ```

### Success Indicator
Flux reports "✔ bootstrap finished" on Cluster B.

  

---

## 7. Verifying Flux Reconciliation

### Steps

1. **Check Flux resources on Cluster A**:
   ```bash
   kubectl --context <cluster-a-context> -n flux-system get gitrepositories,kustomizations
   ```

2. **Check Flux resources on Cluster B**:
   ```bash
   kubectl --context <cluster-b-context> -n flux-system get gitresources,kustomizations
   ```

3. **Verify Cluster A syncs correct path**:
   ```bash
   kubectl --context <cluster-a-context> -n flux-system describe kustomization flux-system | grep path
   ```
   Expected: `path: gitops/clusters/cluster-a`

4. **Verify Cluster B syncs correct path**:
   ```bash
   kubectl --context <cluster-b-context> -n flux-system describe kustomization flux-system | grep path
   ```
   Expected: `path: gitops/clusters/cluster-b`

5. **Check Gateway exists on Cluster A only**:
   ```bash
   kubectl --context <cluster-a-context> get gateways -A
   kubectl --context <cluster-b-context> get gateways -A
   ```
   Expected: Gateway exists on Cluster A, NOT on Cluster B.

6. **Check ServiceExport exists on both clusters**:
   ```bash
   kubectl --context <cluster-a-context> get serviceexports -A
   kubectl --context <cluster-b-context> get serviceexports -A
   ```
   Expected: `sample-app` ServiceExport exists on both clusters.

### Success Indicators
- All resources show `Ready=True` status  
- Paths are correct for each cluster  
- Gateway exists only on Cluster A  
- ServiceExport exists on both clusters

**⚠️ STOP**: If any Flux resources show errors, do not proceed to ingress verification. Fix reconciliation issues first.  

---

## 8. Verifying Public Ingress Through Cloudflare

### Steps

1. **Wait for Gateway to become ready** (may take 5-10 minutes):
   ```bash
   kubectl --context <cluster-a-context> get gateways -A -w
   ```
   Wait until status shows `Ready=True` and `Address` is populated.

2. **Wait for HTTPRoute to be ready**:
   ```bash
   kubectl --context <cluster-a-context> get httproutes -A
   ```
   Expected: Status shows `Ready=True`

3. **Test ingress with curl**:
   ```bash
   curl https://<cloudflare-hostname>
   ```

4. **Verify response**:
   - You should see the sample app response (not a Cloudflare error)  
   - HTTP status code should be 200 or similar

5. **Verify traffic goes through Cloudflare**:
   ```bash
   curl -v https://<cloudflare-hostname> 2>&1 | grep "CF-RAY"
   ```
   Expected: Header contains `CF-RAY: <value>`

### Success Indicator
Curl returns successful HTTP response from the sample app with Cloudflare Ray ID in headers.  

---

## 9. Optional Cloudflare Edge mTLS

**📋 OPTIONAL SECTION**: Skip for initial setup. Only configure if you need client certificate authentication.  

**⚠️ IMPORTANT**: Cloudflare edge mTLS is manual configuration via Cloudflare Dashboard. Terraform does NOT provision mTLS resources.  

### Why Not Terraform-Managed?

Cloudflare's Terraform provider does not expose client certificate or mTLS rule management as documented resources. The official documentation explicitly states there are no corresponding Terraform resources for API Shield client certificates or mTLS configuration.  

### Steps

1. **Log in to Cloudflare Dashboard**

2. **Navigate to**: **Security** → **API Shield** → **mTLS**

3. **Choose CA management**:
   - Option A: Let Cloudflare generate a managed CA (simplest)  
   - Option B: Upload your own CA certificate

4. **Generate or upload your client CA certificate**

5. **Select the hostname(s) to protect** (e.g., `api.example.com`)

6. **Set enforcement action**:
   - **block** (recommended): Rejects requests without valid client certificate  
   - **log** (for troubleshooting): Logs but allows traffic  
   - **challenge** (Enterprise only): Challenges user for certificate

7. **Save the mTLS policy**

8. **Generate and distribute client certificates**:
   - Retrieve your CA certificate from Cloudflare Dashboard  
   - Sign client certificates with your CA  
   - Distribute client certificates to authorized users/services

9. **Test with client certificate**:
   ```bash
   curl https://<hostname> --cert <client-cert.pem> --key <client-key.pem>
   ```
   Expected: Successful HTTP response (200)

10. **Test without client certificate** (should be blocked by default):
   ```bash
   curl https://<hostname>
   ```
   Expected: HTTP 403 Forbidden or similar error

### Success Indicators
- Requests with valid client certificate succeed (HTTP 200)  
- Requests without client certificate are blocked (HTTP 403 or similar)

### What to Document for Your Team

- Where to getthe CA certificate  
- How to generate client certificates  
- How to configure clients to presentthe certificate  

---

## 10. Common Problems

### Problem: Terraform Fails with "Insufficient Permissions"

**Symptom**: Terraform apply fails with permission denied errors.  

**Solution**:
- Verify your GCP account has the necessary roles (Compute Admin, Cluster Admin, Certificate Manager Admin)  
- Verify: `gcloud auth list` shows correct account

### Problem: Flux Bootstrap Fails with SSH Key Error

**Symptom**: Flux reports "authentication failed" or "permission denied (publickey)".  

**Solution**:
- Verify deploy key exists in GitHub repository settings  
- Verify SSH private key file path is correct  
- Test SSH connection manually: `ssh -i <private-key> git@github.com`  
- Verify: SSH connection to GitHub succeeds

### Problem: Flux Reconciliation Fails on Cluster A or B

**Symptom**: Kustomization shows `Ready=False` or has errors in describe output.  

**Solution**:
- Check GitRepository is reachable: `kubectl get gitrepository -n flux-system`  
- Verify placeholders were replaced correctly in GitOps manifests  
- Check kubectl context is correct  
- Run `flux get kustomizations -A` to see detailed status  

**Verify**: All Kustomizations show `Ready=True`

### Problem: Gateway Never Becomes Ready

**Symptom**: Gateway stays in `Ready=False` for more than 15 minutes.  

**Solution**:
- Check if static IP is reserved: `gcloud compute addresses list`  
- Check if certificate map is active: `gcloud certificate-manager maps list`  
- Verify Fleet ingress is enabled: `gcloud container fleet ingress describe`  
- Check Gateway events: `kubectl describe gateway <gateway-name> -n gateways`  

**Verify**: Gateway shows `Ready=True` and `Address` is populated.

### Problem: Cloud Returns 502/503 Errors

**Symptom**: Curl returns 502 Bad Gateway or 503 Service Unavailable.  

**Solution**:
- Verify HTTPRoute exists: `kubectl get httproutes -A`  
- Verify ServiceImport exists on both clusters: `kubectl get serviceimports -A`  
- Check sample app pods are running: `kubectl get pods -A | grep sample-app`  
- Check backend service has endpoints: `kubectl get endpoints -A`  

**Verify**: Sample app responds with HTTP 200.

### Problem: Cloudflare Returns 1000 Error "DNS Points to Prohibited IP"

**Symptom**: Cloudflare returns error 1000.  

**Solution**:
- Verify Cloudflare DNS record is not using reserved/banned IP ranges  
- Check Cloudflare status page for outages  
- Try purging Cloudflare cache  

**Verify**: Cloudflare DNS resolves correctly.

### Problem: Cannot Connect to Clusters with kubectl

**Symptom**: `kubectl get nodes` returns connection refused or timeout.  

**Solution**:
- Verify credentials are current: Run `gcloud container clusters get-credentials` again  
- Check kubectl context: `kubectl config get-contexts`  
- Verify cluster is running: `gcloud container clusters list`  
- Check network connectivity to GKE control plane  

**Verify**: `kubectl get nodes` returns node list.

---

## 11. Completion Checklist

### Infrastructure

- ☐ GCP VPC and subnets created  
- ☐ Cloud NAT configured and working  
- ☐ Two GKE clusters running (Cluster A and Cluster B)  
- ☐ Fleet membership enabled on both clusters  
- ☐ Global static IP reserved  
- ☐ Certificate Manager resources created and active  
- ☐ Cloudflare DNS records configured (proxied)  
- ☐ Cloudflare Authenticated Origin Pulls enabled  
- ☐ Cloudflare SSL mode set to "strict"

### GitOps

- ☐ Flux installed on Cluster A  
- ☐ Flux installed on Cluster B  
- ☐ Cluster A syncing from `gitops/clusters/cluster-a`  
- ☐ Cluster B syncing from `gitops/clusters/cluster-b`  
- ☐ Gateway exists only on Cluster A  
- ☐ ServiceExport exists on both clusters  
- ☐ All Flux resources show `Ready=True`

### Ingress

- ☐ Gateway is ready with address populated  
- ☐ HTTPRoute is ready  
- ☐ Public hostname resolves through Cloudflare  
- ☐ Sample app responds with HTTP 200  
- ☐ Cloudflare Ray ID present in response headers

### Optional mTLS (if configured)

- ☐ Cloudflare mTLS policy created  
- ☐ CA certificate available for client generation  
- ☐ Client certificates can be generated  
- ☐ Requests with valid client certificate succeed  
- ☐ Requests without client certificate are blocked

### Final Success

🎉 You have a working two-cluster GKE platform with Cloudflare edge protection and Flux GitOps!

### Next Steps

- Review `docs/operations.md` for routine maintenance commands  
- Customize the sample app for your workload  
- Add your own applications to the GitOps repository  
- Configure monitoring and alerting for production use  
- Set up CI/CD pipelines for automated deployments
