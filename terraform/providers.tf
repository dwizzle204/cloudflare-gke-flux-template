provider "google" {
  project = var.project_id
  region  = var.region_a
}

provider "google-beta" {
  project = var.project_id
  region  = var.region_a
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "cluster_a"
  host                   = "https://${google_container_cluster.cluster_a.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.cluster_a.master_auth[0].cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "cluster_b"
  host                   = "https://${google_container_cluster.cluster_b.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.cluster_b.master_auth[0].cluster_ca_certificate)
}

provider "flux" {
  alias = "cluster_a"

  kubernetes = {
    host                   = "https://${google_container_cluster.cluster_a.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.cluster_a.master_auth[0].cluster_ca_certificate)
  }

  git = {
    url = "https://github.com/${var.git_repository_owner}/${var.git_repository_name}.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }
}

provider "flux" {
  alias = "cluster_b"

  kubernetes = {
    host                   = "https://${google_container_cluster.cluster_b.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.cluster_b.master_auth[0].cluster_ca_certificate)
  }

  git = {
    url = "https://github.com/${var.git_repository_owner}/${var.git_repository_name}.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }
}
