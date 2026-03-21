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
      config_membership = google_container_cluster.cluster_a.fleet[0].membership
    }
  }

  depends_on = [
    google_container_cluster.cluster_a,
    google_container_cluster.cluster_b
  ]
}
