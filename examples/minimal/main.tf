module "core" {
  source = "../../terraform/modules/core"

  cluster_a_name          = "example-cluster-a"
  cluster_b_name          = "example-cluster-b"
  cluster_release_channel = "REGULAR"
  gateway_static_ip_name  = "example-gateway-ip"
  machine_type            = "e2-standard-2"
  network_name            = "example-network"
  node_count              = 2
  pods_range_a            = "10.10.0.0/16"
  pods_range_b            = "10.30.0.0/16"
  project_id              = "example-project-12345"
  region_a                = "us-central1"
  region_b                = "us-east1"
  services_range_a        = "10.20.0.0/20"
  services_range_b        = "10.40.0.0/20"
  subnet_cidr_a           = "10.0.0.0/20"
  subnet_cidr_b           = "10.1.0.0/20"
  subnet_name_a           = "example-a"
  subnet_name_b           = "example-b"
}
