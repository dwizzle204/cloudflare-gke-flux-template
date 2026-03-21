module "core" {
  source = "../modules/core"

  cluster_a_name          = var.cluster_a_name
  cluster_b_name          = var.cluster_b_name
  cluster_release_channel = var.cluster_release_channel
  gateway_static_ip_name  = var.gateway_static_ip_name
  machine_type            = var.machine_type
  network_name            = var.network_name
  node_count              = var.node_count
  pods_range_a            = var.pods_range_a
  pods_range_b            = var.pods_range_b
  project_id              = var.project_id
  region_a                = var.region_a
  region_b                = var.region_b
  services_range_a        = var.services_range_a
  services_range_b        = var.services_range_b
  subnet_cidr_a           = var.subnet_cidr_a
  subnet_cidr_b           = var.subnet_cidr_b
  subnet_name_a           = var.subnet_name_a
  subnet_name_b           = var.subnet_name_b
}
