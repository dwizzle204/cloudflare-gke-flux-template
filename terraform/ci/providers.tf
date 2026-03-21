provider "google" {
  access_token = var.google_access_token
  project      = var.project_id
  region       = var.region_a
}

provider "google-beta" {
  access_token = var.google_access_token
  project      = var.project_id
  region       = var.region_a
}
