resource "google_gke_hub_feature" "mcs" {
  provider = google-beta
  name     = "multiclusterservicediscovery"
  location = "global"

  depends_on = [module.project_services]
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
      config_membership = module.cluster_a.fleet_membership
    }
  }

  depends_on = [
    module.cluster_a,
    module.cluster_b
  ]
}
