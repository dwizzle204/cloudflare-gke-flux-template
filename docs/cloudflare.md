# Cloudflare Edge

Cloudflare is the only public endpoint in this template.

## Managed by Terraform

- zone lookup from `cloudflare_zone_name`
- proxied DNS record to the GCP global external load balancer IP
- Authenticated Origin Pulls enabled at the zone level

## Intent

- client TLS terminates at Cloudflare
- Cloudflare forwards to the GCP origin over HTTPS
- Cloudflare remains the only supported public entrypoint

## Notes

- This template enables Authenticated Origin Pulls at Cloudflare.
- Origin-side certificate and trust implementation must align with your chosen GCP HTTPS certificate strategy.
- Do not introduce Cloudflare tunnels or alternate public records for the same service.
