module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "16.1.0"

  project_id   = var.project_id
  network_name = var.network_name

  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  subnets = [
    {
      subnet_name           = var.subnet_name_a
      subnet_ip             = var.subnet_cidr_a
      subnet_region         = var.region_a
      subnet_private_access = "true"
    },
    {
      subnet_name           = var.subnet_name_b
      subnet_ip             = var.subnet_cidr_b
      subnet_region         = var.region_b
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    (var.subnet_name_a) = [
      {
        range_name    = "${var.subnet_name_a}-pods"
        ip_cidr_range = var.pods_range_a
      },
      {
        range_name    = "${var.subnet_name_a}-services"
        ip_cidr_range = var.services_range_a
      }
    ]
    (var.subnet_name_b) = [
      {
        range_name    = "${var.subnet_name_b}-pods"
        ip_cidr_range = var.pods_range_b
      },
      {
        range_name    = "${var.subnet_name_b}-services"
        ip_cidr_range = var.services_range_b
      }
    ]
  }
}

module "router_a" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "6.2.0"

  name    = "${var.cluster_a_name}-router"
  project = var.project_id
  region  = var.region_a
  network = module.vpc.network_self_link

  nats = [
    {
      name                               = "${var.cluster_a_name}-nat"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    }
  ]
}

module "router_b" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "6.2.0"

  name    = "${var.cluster_b_name}-router"
  project = var.project_id
  region  = var.region_b
  network = module.vpc.network_self_link

  nats = [
    {
      name                               = "${var.cluster_b_name}-nat"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    }
  ]
}

resource "google_compute_global_address" "gateway_ip" {
  name = var.gateway_static_ip_name
}
