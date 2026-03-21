module "cluster_a" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "44.0.0"

  providers = {
    google = google
  }

  project_id = var.project_id
  name       = var.cluster_a_name

  regional = true
  region   = var.region_a

  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets["${var.region_a}/${var.subnet_name_a}"].name

  ip_range_pods     = "${var.subnet_name_a}-pods"
  ip_range_services = "${var.subnet_name_a}-services"

  release_channel     = var.cluster_release_channel
  gateway_api_channel = "CHANNEL_STANDARD"
  identity_namespace  = "${var.project_id}.svc.id.goog"
  fleet_project       = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  node_pools = [
    {
      name         = "${var.cluster_a_name}-pool"
      autoscaling  = false
      node_count   = var.node_count
      machine_type = var.machine_type
    }
  ]

  node_pools_oauth_scopes = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  depends_on = [module.project_services]
}

module "cluster_b" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "44.0.0"

  providers = {
    google = google
  }

  project_id = var.project_id
  name       = var.cluster_b_name

  regional = true
  region   = var.region_b

  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets["${var.region_b}/${var.subnet_name_b}"].name

  ip_range_pods     = "${var.subnet_name_b}-pods"
  ip_range_services = "${var.subnet_name_b}-services"

  release_channel     = var.cluster_release_channel
  gateway_api_channel = "CHANNEL_STANDARD"
  identity_namespace  = "${var.project_id}.svc.id.goog"
  fleet_project       = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  node_pools = [
    {
      name         = "${var.cluster_b_name}-pool"
      autoscaling  = false
      node_count   = var.node_count
      machine_type = var.machine_type
    }
  ]

  node_pools_oauth_scopes = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  depends_on = [module.project_services]
}
