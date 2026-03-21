resource "google_certificate_manager_dns_authorization" "gateway" {
  name     = var.gateway_dns_authorization_name
  project  = var.project_id
  location = "global"
  domain   = var.gateway_hostname
}

resource "google_certificate_manager_certificate" "gateway" {
  name     = var.gateway_certificate_name
  project  = var.project_id
  location = "global"

  managed {
    domains            = [var.gateway_hostname]
    dns_authorizations = [google_certificate_manager_dns_authorization.gateway.id]
  }

  depends_on = [cloudflare_dns_record.gateway_certificate_dns_authorization]
}

resource "google_certificate_manager_certificate_map" "gateway" {
  name    = var.gateway_certificate_map_name
  project = var.project_id
}

resource "google_certificate_manager_certificate_map_entry" "gateway" {
  name         = var.gateway_certificate_map_entry_name
  project      = var.project_id
  map          = google_certificate_manager_certificate_map.gateway.id
  hostname     = var.gateway_hostname
  certificates = [google_certificate_manager_certificate.gateway.id]
}
