variable "project_id" { type = string }
variable "region_a" { type = string }
variable "region_b" { type = string }
variable "zone_a" { type = string }
variable "zone_b" { type = string }

variable "cluster_a_name" {
  type    = string
  default = "cluster-a"
}

variable "cluster_b_name" {
  type    = string
  default = "cluster-b"
}

variable "network_name" {
  type    = string
  default = "gke-mcg-vpc"
}

variable "subnet_name_a" {
  type    = string
  default = "gke-a"
}

variable "subnet_name_b" {
  type    = string
  default = "gke-b"
}

variable "pods_range_a" {
  type    = string
  default = "10.10.0.0/16"
}

variable "services_range_a" {
  type    = string
  default = "10.20.0.0/20"
}

variable "pods_range_b" {
  type    = string
  default = "10.30.0.0/16"
}

variable "services_range_b" {
  type    = string
  default = "10.40.0.0/20"
}

variable "subnet_cidr_a" {
  type    = string
  default = "10.0.0.0/20"
}

variable "subnet_cidr_b" {
  type    = string
  default = "10.1.0.0/20"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "gateway_static_ip_name" {
  type    = string
  default = "mcg-external-ip"
}

variable "gateway_hostname" { type = string }

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_id" { type = string }
variable "cloudflare_hostname" { type = string }

variable "git_repository_owner" { type = string }
variable "git_repository_name" { type = string }

variable "git_branch" {
  type    = string
  default = "main"
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "cluster_release_channel" {
  type    = string
  default = "REGULAR"
}
