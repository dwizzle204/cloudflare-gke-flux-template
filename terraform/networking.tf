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
