resource "flux_bootstrap_git" "cluster_a" {
  provider = flux.cluster_a

  path      = "gitops/clusters/cluster-a"
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
