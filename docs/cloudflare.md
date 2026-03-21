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
