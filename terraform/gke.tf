resource "google_container_cluster" "cluster_a" {
  provider                 = google-beta
  name                     = var.cluster_a_name
  location                 = var.zone_a
  network                  = google_compute_network.this.id
  subnetwork               = google_compute_subnetwork.cluster_a.name
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  release_channel {
    channel = var.cluster_release_channel
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.subnet_name_a}-pods"
    services_secondary_range_name = "${var.subnet_name_a}-services"
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  fleet {
    project = var.project_id
  }

  depends_on = [google_project_service.required]
}

resource "google_container_node_pool" "cluster_a" {
  name       = "${var.cluster_a_name}-pool"
  location   = var.zone_a
  cluster    = google_container_cluster.cluster_a.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_container_cluster" "cluster_b" {
  provider                 = google-beta
  name                     = var.cluster_b_name
  location                 = var.zone_b
  network                  = google_compute_network.this.id
  subnetwork               = google_compute_subnetwork.cluster_b.name
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  release_channel {
    channel = var.cluster_release_channel
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.subnet_name_b}-pods"
    services_secondary_range_name = "${var.subnet_name_b}-services"
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  fleet {
    project = var.project_id
  }

  depends_on = [google_project_service.required]
}

resource "google_container_node_pool" "cluster_b" {
  name       = "${var.cluster_b_name}-pool"
  location   = var.zone_b
  cluster    = google_container_cluster.cluster_b.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
