# Variable Definitions

## GCP

- `project_id`: Google Cloud project ID
- `region_a`: region for Cluster A
- `region_b`: region for Cluster B
- `cluster_a_name`: Cluster A name
- `cluster_b_name`: Cluster B name
- `network_name`: shared VPC name
- `subnet_name_a`: subnet for Cluster A
- `subnet_name_b`: subnet for Cluster B
- `subnet_cidr_a`: subnet CIDR for Cluster A
- `subnet_cidr_b`: subnet CIDR for Cluster B
- `pods_range_a`: pod secondary range for Cluster A
- `pods_range_b`: pod secondary range for Cluster B
- `services_range_a`: services secondary range for Cluster A
- `services_range_b`: services secondary range for Cluster B
- `machine_type`: default node pool machine type
- `node_count`: default node count per cluster
- `cluster_release_channel`: GKE release channel
- `gateway_static_ip_name`: reserved global static IP name

## Cloudflare

- `cloudflare_api_token`: Cloudflare API token
- `cloudflare_zone_name`: Cloudflare zone name
- `cloudflare_hostname`: proxied public hostname managed by Cloudflare DNS

## Git / Flux

- `git_repository_owner`: GitHub owner or organization
- `git_repository_name`: GitHub repository name
- `git_branch`: Git branch for Flux reconciliation
- `github_token`: token used for Terraform bootstrap on Cluster A

See `docs/template-customization.md` for the full replacement checklist and placeholder rendering flow.

## Gateway

- `gateway_hostname`: hostname configured on the Gateway and HTTPRoute
