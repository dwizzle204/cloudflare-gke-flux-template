resource "flux_bootstrap_git" "cluster_a" {
  provider = flux.cluster_a

  path      = "flux/clusters/cluster-a"
  interval  = "1m0s"
  namespace = "flux-system"
  version   = "v2.4.0"

  components = [
    "source-controller",
    "kustomize-controller",
    "helm-controller",
    "notification-controller"
  ]

  depends_on = [
    module.cluster_a,
    google_gke_hub_feature.mcs,
    google_gke_hub_feature.ingress
  ]
}

resource "flux_bootstrap_git" "cluster_b" {
  provider = flux.cluster_b

  path      = "flux/clusters/cluster-b"
  interval  = "1m0s"
  namespace = "flux-system"
  version   = "v2.4.0"

  components = [
    "source-controller",
    "kustomize-controller",
    "helm-controller",
    "notification-controller"
  ]

  depends_on = [
    module.cluster_b,
    google_gke_hub_feature.mcs
  ]
}
