# Cloudflare Edge

This template uses Cloudflare as the only public edge.

## What Terraform configures

- zone lookup from `cloudflare_zone_name`
- proxied DNS record for the public hostname
- unproxied DNS authorization record for Google Certificate Manager
- Authenticated Origin Pulls enabled at zone level
- SSL mode set to `strict`
- `always_use_https` enabled

## Traffic model

1. Client connects to Cloudflare
2. Cloudflare terminates client TLS
3. Cloudflare forwards traffic to GCP HTTPS origin
4. Cloudflare validates origin certificate because SSL mode is `strict`
5. Authenticated Origin Pulls authenticate Cloudflare to origin

## What you must provide

- `cloudflare_zone_name`
- `cloudflare_hostname`
- `cloudflare_api_token`

## What success looks like

- Public hostname is orange-cloud proxied
- Cloudflare serves HTTPS to clients
- Cloudflare can validate GCP origin certificate chain
- Direct alternate ingress paths are not introduced

## What not to add

- Cloudflare tunnels
- Alternate public DNS records for the same service path
- A second ingress path that bypasses Cloudflare

## Client-facing Cloudflare edge mTLS (optional)

### Overview

This template does NOT provision Cloudflare edge mTLS via Terraform. If you want client certificate authentication for your API, configure it separately in Cloudflare Dashboard.

### Why not Terraform-managed?

Cloudflare's Terraform provider does not expose client certificate or mTLS rule management as documented resources. The official documentation explicitly states there are no corresponding Terraform resources for API Shield client certificates or mTLS configuration.

### What Terraform manages

- Public DNS record for hostname
- Unproxied DNS authorization record for Google Certificate Manager
- Authenticated Origin Pulls (AOP) at zone level
- SSL mode set to `strict`
- Always-use-HTTPS enabled

### How to configure Cloudflare edge mTLS (optional)

If you require client certificate authentication:

1. Go to **Cloudflare Dashboard** → **Security** → **API Shield** → **mTLS**
2. Generate or upload your client CA certificate
3. Select hostname(s) to protect
4. Set enforcement action: **block** (default), **log** (for troubleshooting), or **challenge** (Enterprise)
5. Generate and distribute client certificates signed by your CA
6. Test connectivity with `curl` using client certificates

### Traffic flow with optional mTLS

Without mTLS (default template):
- Client → Cloudflare → WAF/DDoS inspection → AOP → GCP → GKE

With Cloudflare edge mTLS configured:
- Client → Cloudflare (presents cert) → mTLS validation → WAF/DDoS inspection → AOP → GCP → GKE

### Why mTLS at Cloudflare (not GKE)?

If mTLS were implemented at GKE Gateway, Cloudflare would be unable to inspect decrypted traffic for WAF rules or analyze traffic patterns for DDoS detection after TLS termination. With Cloudflare edge mTLS, the client certificate is validated, then traffic is decrypted for inspection.

**Single enforcement point:** Client authentication happens at the first hop, blocking unauthorized clients before they consume GCP resources.

**Instant revocation:** Certificate revocation propagates instantly across Cloudflare's edge network.

### Generating client certificates

After configuring mTLS in the Cloudflare Dashboard, retrieve your CA certificate and use it to sign client certificates:

```bash
# Example: Generate client key and CSR
openssl req -newkey rsa:4096 -keyout client-key.pem -out client.csr

# Sign with Cloudflare CA (via Cloudflare dashboard or your own CA)
# Then test with:
curl https://<hostname> --cert client-cert.pem --key client-key.pem
```
