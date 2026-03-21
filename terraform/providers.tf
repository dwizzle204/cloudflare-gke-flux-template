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
  host                   = "https://${module.cluster_a.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster_a.ca_certificate)
}

provider "kubernetes" {
  alias                  = "cluster_b"
  host                   = "https://${module.cluster_b.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster_b.ca_certificate)
}

provider "helm" {
  alias = "cluster_a"

  kubernetes {
    host                   = "https://${module.cluster_a.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.cluster_a.ca_certificate)
  }
}

provider "helm" {
  alias = "cluster_b"

  kubernetes {
    host                   = "https://${module.cluster_b.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.cluster_b.ca_certificate)
  }
}
