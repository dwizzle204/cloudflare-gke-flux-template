variable "cluster_a_name" {
  description = "Name of Cluster A, which acts as both workload cluster and config cluster."
  type        = string
  default     = "cluster-a"
}

variable "cluster_b_name" {
  description = "Name of Cluster B, which acts as a workload-only cluster."
  type        = string
  default     = "cluster-b"
}

variable "cluster_release_channel" {
  description = "GKE release channel applied to both clusters."
  type        = string
  default     = "REGULAR"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with permissions to manage the target zone and Authenticated Origin Pulls settings."
  type        = string
  sensitive   = true
}

variable "cloudflare_hostname" {
  description = "Hostname created in Cloudflare and proxied to the GCP global load balancer IP."
  type        = string
}

variable "cloudflare_zone_name" {
  description = "Cloudflare zone name used to resolve to target zone for DNS and Authenticated Origin Pulls configuration."
  type        = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID for mTLS certificate management. Replace with your account ID."
  type        = string
  default     = "REPLACE_ME_ACCOUNT_ID"
}

variable "cloudflare_client_ca_name" {
  description = "Name of Cloudflare-managed CA certificate used for mTLS authentication."
  type        = string
  default     = "mtls-client-ca"
}

variable "cloudflare_client_ca_certificate" {
  description = "PEM-encoded CA certificate for mTLS validation. For Cloudflare-managed CA, leave as empty string. For custom CA (Enterprise), provide certificate content."
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_cloudflare_mtls" {
  description = "Enable mTLS authentication at Cloudflare edge. Set to false to disable mTLS and allow public access. Note: Enforcement action (block/log/challenge) must be configured in Cloudflare Dashboard under Security > API Shield > mTLS."
  type        = bool
  default     = true
}

variable "mtls_enforcement_action" {
  description = "Action to take when mTLS validation fails. Options: block (default), log (for troubleshooting), challenge (Enterprise)."
  type        = string
  default     = "block"

  validation {
    condition     = contains(["block", "log", "challenge"], var.mtls_enforcement_action)
    error_message = "mtls_enforcement_action must be block, log, or challenge."
  }
}

variable "gateway_hostname" {
  description = "Hostname bound on the external multi-cluster Gateway listener and HTTPRoute."
  type        = string
}

variable "gateway_static_ip_name" {
  description = "Name of the reserved global static IP attached to the external global load balancer."
  type        = string
  default     = "mcg-external-ip"
}

variable "gateway_dns_authorization_name" {
  description = "Name of the Certificate Manager DNS authorization used for the gateway hostname."
  type        = string
  default     = "gateway-dns-auth"
}

variable "gateway_certificate_name" {
  description = "Name of the Certificate Manager certificate used by the external gateway."
  type        = string
  default     = "gateway-certificate"
}

variable "gateway_certificate_map_name" {
  description = "Name of the Certificate Manager certificate map attached to the external gateway."
  type        = string
  default     = "gateway-cert-map"
}

variable "gateway_certificate_map_entry_name" {
  description = "Name of the Certificate Manager certificate map entry for the gateway hostname."
  type        = string
  default     = "gateway-cert-entry"
}

variable "machine_type" {
  description = "Machine type used by the default node pool in both clusters."
  type        = string
  default     = "e2-standard-2"
}

variable "network_name" {
  description = "Name of the shared VPC network used by both clusters."
  type        = string
  default     = "gke-mcg-vpc"
}

variable "node_count" {
  description = "Static node count for the default node pool in each cluster."
  type        = number
  default     = 2
}

variable "pods_range_a" {
  description = "Secondary pod CIDR range for Cluster A."
  type        = string
  default     = "10.10.0.0/16"
}

variable "pods_range_b" {
  description = "Secondary pod CIDR range for Cluster B."
  type        = string
  default     = "10.30.0.0/16"
}

variable "project_id" {
  description = "Google Cloud project ID used for all infrastructure."
  type        = string
}

variable "region_a" {
  description = "Primary Google Cloud region for Cluster A and its subnet."
  type        = string
}

variable "region_b" {
  description = "Primary Google Cloud region for Cluster B and its subnet."
  type        = string
}

variable "services_range_a" {
  description = "Secondary services CIDR range for Cluster A."
  type        = string
  default     = "10.20.0.0/20"
}

variable "services_range_b" {
  description = "Secondary services CIDR range for Cluster B."
  type        = string
  default     = "10.40.0.0/20"
}

variable "subnet_cidr_a" {
  description = "Primary subnet CIDR range for Cluster A."
  type        = string
  default     = "10.0.0.0/20"
}

variable "subnet_cidr_b" {
  description = "Primary subnet CIDR range for Cluster B."
  type        = string
  default     = "10.1.0.0/20"
}

variable "subnet_name_a" {
  description = "Subnet name for Cluster A."
  type        = string
  default     = "gke-a"
}

variable "subnet_name_b" {
  description = "Subnet name for Cluster B."
  type        = string
  default     = "gke-b"
}
