locals {
  required_services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "trafficdirector.googleapis.com"
  ]
}

resource "google_project_service" "required" {
  for_each           = toset(local.required_services)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "this" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cluster_a" {
  name                     = var.subnet_name_a
  ip_cidr_range            = var.subnet_cidr_a
  region                   = var.region_a
  network                  = google_compute_network.this.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.subnet_name_a}-pods"
    ip_cidr_range = var.pods_range_a
  }

  secondary_ip_range {
    range_name    = "${var.subnet_name_a}-services"
    ip_cidr_range = var.services_range_a
  }
}

resource "google_compute_subnetwork" "cluster_b" {
  name                     = var.subnet_name_b
  ip_cidr_range            = var.subnet_cidr_b
  region                   = var.region_b
  network                  = google_compute_network.this.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.subnet_name_b}-pods"
    ip_cidr_range = var.pods_range_b
  }

  secondary_ip_range {
    range_name    = "${var.subnet_name_b}-services"
    ip_cidr_range = var.services_range_b
  }
}

resource "google_compute_router" "nat_a" {
  name    = "${var.cluster_a_name}-router"
  region  = var.region_a
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "nat_a" {
  name                               = "${var.cluster_a_name}-nat"
  router                             = google_compute_router.nat_a.name
  region                             = var.region_a
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_router" "nat_b" {
  name    = "${var.cluster_b_name}-router"
  region  = var.region_b
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "nat_b" {
  name                               = "${var.cluster_b_name}-nat"
  router                             = google_compute_router.nat_b.name
  region                             = var.region_b
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_global_address" "gateway_ip" {
  name = var.gateway_static_ip_name
}

resource "google_container_cluster" "cluster_a" {
  provider                 = google-beta
  name                     = var.cluster_a_name
  location                 = var.region_a
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
  location   = var.region_a
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
  location                 = var.region_b
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
  location   = var.region_b
  cluster    = google_container_cluster.cluster_b.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_gke_hub_feature" "mcs" {
  provider = google-beta
  name     = "multiclusterservicediscovery"
  location = "global"

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "mcs_network_viewer" {
  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[gke-mcs/gke-mcs-importer]"
}

resource "google_gke_hub_feature" "ingress" {
  provider = google-beta
  name     = "multiclusteringress"
  location = "global"

  spec {
    multiclusteringress {
      config_membership = google_container_cluster.cluster_a.fleet[0].membership
    }
  }

  depends_on = [
    google_container_cluster.cluster_a,
    google_container_cluster.cluster_b
  ]
}
