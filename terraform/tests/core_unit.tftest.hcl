variables {
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

provider "google" {
  access_token = "mock-access-token"
  project      = "example-project-12345"
  region       = "us-central1"
}

provider "google-beta" {
  access_token = "mock-access-token"
  project      = "example-project-12345"
  region       = "us-central1"
}

run "core_module_plan" {
  command = plan

  module {
    source = "./modules/core"
  }

  assert {
    condition     = output.cluster_a_name == "example-cluster-a"
    error_message = "Cluster A output should match the input name."
  }

  assert {
    condition     = output.cluster_b_name == "example-cluster-b"
    error_message = "Cluster B output should match the input name."
  }

  assert {
    condition     = output.config_cluster_name == "example-cluster-a"
    error_message = "Config cluster output should point to Cluster A."
  }

  assert {
    condition     = output.network_name == "example-network"
    error_message = "Network output should match the input network name."
  }

  assert {
    condition     = length(output.subnet_names) == 2
    error_message = "The core module should output exactly two subnet names."
  }
}
