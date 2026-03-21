data "cloudflare_zones" "selected" {
  name      = var.cloudflare_zone_name
  max_items = 1
}

resource "cloudflare_authenticated_origin_pulls_settings" "zone" {
  zone_id = data.cloudflare_zones.selected.result[0].id
  enabled = true
}

resource "cloudflare_dns_record" "gateway" {
  zone_id = data.cloudflare_zones.selected.result[0].id
  name    = var.cloudflare_hostname
  type    = "A"
  content = google_compute_global_address.gateway_ip.address
  proxied = true
  ttl     = 1
}
