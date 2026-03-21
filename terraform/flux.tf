locals {
  flux_components = [
    "source-controller",
    "kustomize-controller",
    "helm-controller",
    "notification-controller"
  ]

  git_repository_url = "https://github.com/${var.git_repository_owner}/${var.git_repository_name}.git"
}

resource "kubernetes_namespace_v1" "flux_system_cluster_a" {
  provider = kubernetes.cluster_a

  metadata {
    name = "flux-system"
  }

  depends_on = [
    module.cluster_a,
    google_gke_hub_feature.mcs,
    google_gke_hub_feature.ingress
  ]
}

resource "kubernetes_namespace_v1" "flux_system_cluster_b" {
  provider = kubernetes.cluster_b

  metadata {
    name = "flux-system"
  }

  depends_on = [
    module.cluster_b,
    google_gke_hub_feature.mcs
  ]
}

resource "helm_release" "flux_operator_cluster_a" {
  provider = helm.cluster_a

  name             = "flux-operator"
  namespace        = kubernetes_namespace_v1.flux_system_cluster_a.metadata[0].name
  create_namespace = false
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  version          = "0.23.0"

  depends_on = [kubernetes_namespace_v1.flux_system_cluster_a]
}

resource "helm_release" "flux_operator_cluster_b" {
  provider = helm.cluster_b

  name             = "flux-operator"
  namespace        = kubernetes_namespace_v1.flux_system_cluster_b.metadata[0].name
  create_namespace = false
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  version          = "0.23.0"

  depends_on = [kubernetes_namespace_v1.flux_system_cluster_b]
}

resource "kubernetes_secret_v1" "flux_sync_cluster_a" {
  provider = kubernetes.cluster_a

  metadata {
    name      = "flux-system"
    namespace = kubernetes_namespace_v1.flux_system_cluster_a.metadata[0].name
  }

  data = {
    username = "git"
    password = var.github_token
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "flux_sync_cluster_b" {
  provider = kubernetes.cluster_b

  metadata {
    name      = "flux-system"
    namespace = kubernetes_namespace_v1.flux_system_cluster_b.metadata[0].name
  }

  data = {
    username = "git"
    password = var.github_token
  }

  type = "Opaque"
}

resource "kubernetes_manifest" "flux_instance_cluster_a" {
  provider = kubernetes.cluster_a

  manifest = {
    apiVersion = "fluxcd.controlplane.io/v1"
    kind       = "FluxInstance"
    metadata = {
      name      = "flux"
      namespace = kubernetes_namespace_v1.flux_system_cluster_a.metadata[0].name
      annotations = {
        "fluxcd.controlplane.io/reconcileEvery"         = "1h"
        "fluxcd.controlplane.io/reconcileArtifactEvery" = "10m"
        "fluxcd.controlplane.io/reconcileTimeout"       = "5m"
      }
    }
    spec = {
      distribution = {
        version  = "2.x"
        registry = "ghcr.io/fluxcd"
        artifact = "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests"
      }
      components = local.flux_components
      cluster = {
        type          = "gcp"
        size          = "medium"
        multitenant   = false
        networkPolicy = true
        domain        = "cluster.local"
      }
      sync = {
        kind       = "GitRepository"
        url        = local.git_repository_url
        ref        = "refs/heads/${var.git_branch}"
        path       = "gitops/clusters/cluster-a"
        pullSecret = kubernetes_secret_v1.flux_sync_cluster_a.metadata[0].name
      }
      wait = true
    }
  }

  depends_on = [
    helm_release.flux_operator_cluster_a,
    kubernetes_secret_v1.flux_sync_cluster_a
  ]
}

resource "kubernetes_manifest" "flux_instance_cluster_b" {
  provider = kubernetes.cluster_b

  manifest = {
    apiVersion = "fluxcd.controlplane.io/v1"
    kind       = "FluxInstance"
    metadata = {
      name      = "flux"
      namespace = kubernetes_namespace_v1.flux_system_cluster_b.metadata[0].name
      annotations = {
        "fluxcd.controlplane.io/reconcileEvery"         = "1h"
        "fluxcd.controlplane.io/reconcileArtifactEvery" = "10m"
        "fluxcd.controlplane.io/reconcileTimeout"       = "5m"
      }
    }
    spec = {
      distribution = {
        version  = "2.x"
        registry = "ghcr.io/fluxcd"
        artifact = "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests"
      }
      components = local.flux_components
      cluster = {
        type          = "gcp"
        size          = "medium"
        multitenant   = false
        networkPolicy = true
        domain        = "cluster.local"
      }
      sync = {
        kind       = "GitRepository"
        url        = local.git_repository_url
        ref        = "refs/heads/${var.git_branch}"
        path       = "gitops/clusters/cluster-b"
        pullSecret = kubernetes_secret_v1.flux_sync_cluster_b.metadata[0].name
      }
      wait = true
    }
  }

  depends_on = [
    helm_release.flux_operator_cluster_b,
    kubernetes_secret_v1.flux_sync_cluster_b
  ]
}
