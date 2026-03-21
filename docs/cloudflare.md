# Cloudflare Edge

Cloudflare is the only public endpoint in this template.

## Managed by Terraform

- zone lookup from `cloudflare_zone_name`
- proxied DNS record to the GCP global external load balancer IP
- Authenticated Origin Pulls enabled at the zone level
- Cloudflare SSL mode set to `strict`
- `always_use_https` enabled

## Intent

- client TLS terminates at Cloudflare
- Cloudflare forwards to the GCP origin over HTTPS with strict origin validation
- Cloudflare remains the only supported public entrypoint

## Notes

- This template enables Authenticated Origin Pulls at Cloudflare.
- The GCP HTTPS origin must present a certificate Cloudflare accepts for the configured hostname.
- Authenticated Origin Pulls authenticate Cloudflare to the origin, while `ssl = strict` enforces origin certificate validation.
- Do not introduce Cloudflare tunnels or alternate public records for the same service.
