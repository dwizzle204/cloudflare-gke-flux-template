data "cloudflare_zones" "selected" {
  name      = var.cloudflare_zone_name
  max_items = 1
}

resource "cloudflare_dns_record" "gateway_certificate_dns_authorization" {
  zone_id = data.cloudflare_zones.selected.result[0].id
  name    = trimsuffix(google_certificate_manager_dns_authorization.gateway.dns_resource_record[0].name, ".")
  type    = google_certificate_manager_dns_authorization.gateway.dns_resource_record[0].type
  content = trimsuffix(google_certificate_manager_dns_authorization.gateway.dns_resource_record[0].data, ".")
  proxied = false
  ttl     = 1
}

resource "cloudflare_authenticated_origin_pulls_settings" "zone" {
  zone_id = data.cloudflare_zones.selected.result[0].id
  enabled = true
}

resource "cloudflare_zone_setting" "ssl_mode" {
  zone_id    = data.cloudflare_zones.selected.result[0].id
  setting_id = "ssl"
  value      = "strict"
}

resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = data.cloudflare_zones.selected.result[0].id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_dns_record" "gateway" {
  zone_id = data.cloudflare_zones.selected.result[0].id
  name    = var.cloudflare_hostname
  type    = "A"
  content = google_compute_global_address.gateway_ip.address
  proxied = true
  ttl     = 1
}

resource "cloudflare_mtls_certificate" "client_ca" {
  account_id   = var.cloudflare_account_id
  ca           = true
  certificates = var.cloudflare_client_ca_certificate
  name         = var.cloudflare_client_ca_name
}
