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
