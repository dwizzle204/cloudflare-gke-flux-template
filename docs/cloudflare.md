# Cloudflare Edge

This template uses Cloudflare as the only public edge.

## What Terraform configures

- zone lookup from `cloudflare_zone_name`
- proxied DNS record for the public hostname
- unproxied DNS authorization record for Google Certificate Manager
- Authenticated Origin Pulls enabled at the zone level
- SSL mode set to `strict`
- `always_use_https` enabled

## Traffic model

1. the client connects to Cloudflare
2. Cloudflare terminates client TLS
3. Cloudflare forwards traffic to the GCP HTTPS origin
4. Cloudflare validates the origin certificate because SSL mode is `strict`
5. Authenticated Origin Pulls authenticate Cloudflare to the origin

## What you must provide

- `cloudflare_zone_name`
- `cloudflare_hostname`
- `cloudflare_api_token`

## What success looks like

- the public hostname is orange-cloud proxied
- Cloudflare serves HTTPS to clients
- Cloudflare can validate the GCP origin certificate chain
- direct alternate ingress paths are not introduced

## What not to add

- Cloudflare tunnels
- alternate public DNS records for the same service path
- a second ingress path that bypasses Cloudflare

## mTLS Authentication

### Overview

The template requires end-to-end mTLS authentication at Cloudflare edge by default. This means:

1. Clients must present a valid client certificate signed by the Cloudflare-managed CA
2. Cloudflare validates the certificate before allowing requests to proceed
3. After validation, Cloudflare inspects traffic for WAF/DDoS protection
4. Only authenticated requests reach the GCP origin

### Why mTLS at Cloudflare?

**Inspection capability:** If mTLS were implemented at the GKE Gateway, Cloudflare would be unable to inspect request content for WAF rules or analyze traffic patterns for DDoS detection after TLS termination. With Cloudflare edge mTLS, the client certificate is validated, then traffic is decrypted for inspection.

**Unified security posture:** All Cloudflare protections (WAF, DDoS, mTLS) operate in the same inspection pipeline, allowing policies to work together coherently.

**Resource protection:** Unauthorized clients are blocked at the edge, preventing them from consuming GCP compute, load balancer capacity, or triggering rate limits on internal infrastructure.

**Operational simplicity:** Certificate management, revocation, and enforcement are handled by Cloudflare's global edge network without per-cluster configuration complexity.

### How it works

1. **Certificate generation:** Cloudflare generates and manages a CA certificate (Cloudflare-managed, available for all plans)
2. **Client certificates:** You generate client certificates signed by this CA for your authorized clients
3. **Hostname enforcement:** mTLS is enforced for the specific hostname via API Shield
4. **Validation flow:**
   - Client connects to Cloudflare with client certificate
   - Cloudflare validates certificate against the managed CA
   - If valid: Cloudflare decrypts traffic for WAF/DDoS inspection
   - If invalid: Request is blocked (default action)
5. **Origin connection:** Cloudflare forwards to GCP LB via Authenticated Origin Pulls

### Client certificate requirements

Clients must:

- Present a certificate signed by the Cloudflare-managed CA
- Include the appropriate SAN (Subject Alternative Name) matching the hostname
- Have a valid certificate chain and not be expired
- Present the certificate during the TLS handshake

### Generating client certificates

After Terraform apply, retrieve the Cloudflare-managed CA certificate from the Cloudflare dashboard and use it to sign client certificates:

```bash
# Example: Generate client key and CSR
openssl req -newkey rsa:4096 -keyout client-key.pem -out client.csr

# Sign with Cloudflare CA (via Cloudflare dashboard or your own CA)
# Then test with:
curl https://<hostname> --cert client-cert.pem --key client-key.pem
```

### Enforcement configuration

**Important:** mTLS enforcement (blocking/logging requests) must be configured in the **Cloudflare Dashboard** under **Security > API Shield > mTLS**. The Terraform provider uploads the certificate, but enforcement action and hostname selection is configured in the Cloudflare UI.

**Steps to configure enforcement:**
1. Go to **Cloudflare Dashboard** → **Security** → **API Shield** → **mTLS**
2. Select the hostname (`<your-gateway-hostname>`)
3. Choose the certificate uploaded by Terraform (`<your-ca-name>`)
4. Set the enforcement action:
   - **block:** Default. Reject requests without valid client certificates.
   - **log:** Allow requests but log validation failures for monitoring and troubleshooting.
   - **challenge:** Present a CAPTCHA challenge to unauthenticated clients (Enterprise feature).

### Disabling mTLS

Set `enable_cloudflare_mtls = false` in your Terraform configuration. The hostname will be accessible to all clients without certificate validation. **Note:** You must also disable mTLS enforcement in the Cloudflare Dashboard if you disable it here.
