variable "cluster_a_name" {
  description = "Name of the config cluster in region A."
  type        = string
}

variable "cluster_b_name" {
  description = "Name of the workload cluster in region B."
  type        = string
}

variable "cluster_release_channel" {
  description = "GKE release channel to use for both clusters."
  type        = string
  default     = "REGULAR"
}

variable "gateway_static_ip_name" {
  description = "Name of the reserved global address used by the gateway."
  type        = string
  default     = "mcg-external-ip"
}

variable "machine_type" {
  description = "Machine type used by both node pools."
  type        = string
  default     = "e2-standard-2"
}

variable "network_name" {
  description = "Name of the shared VPC network."
  type        = string
  default     = "gke-mcg-vpc"
}

variable "node_count" {
  description = "Node count for each cluster node pool."
  type        = number
  default     = 2
}

variable "pods_range_a" {
  description = "Secondary pod CIDR for cluster A."
  type        = string
  default     = "10.10.0.0/16"
}

variable "pods_range_b" {
  description = "Secondary pod CIDR for cluster B."
  type        = string
  default     = "10.30.0.0/16"
}

variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region_a" {
  description = "Primary region for Cluster A and its regional networking resources."
  type        = string
}

variable "region_b" {
  description = "Primary region for Cluster B and its regional networking resources."
  type        = string
}

variable "services_range_a" {
  description = "Secondary services CIDR for cluster A."
  type        = string
  default     = "10.20.0.0/20"
}

variable "services_range_b" {
  description = "Secondary services CIDR for cluster B."
  type        = string
  default     = "10.40.0.0/20"
}

variable "subnet_cidr_a" {
  description = "Primary subnet CIDR for cluster A."
  type        = string
  default     = "10.0.0.0/20"
}

variable "subnet_cidr_b" {
  description = "Primary subnet CIDR for cluster B."
  type        = string
  default     = "10.1.0.0/20"
}

variable "subnet_name_a" {
  description = "Subnet name for cluster A."
  type        = string
  default     = "gke-a"
}

variable "subnet_name_b" {
  description = "Subnet name for cluster B."
  type        = string
  default     = "gke-b"
}
