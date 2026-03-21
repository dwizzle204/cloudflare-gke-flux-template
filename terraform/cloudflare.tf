resource "cloudflare_dns_record" "gateway" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_hostname
  type    = "A"
  content = google_compute_global_address.gateway_ip.address
  proxied = true
  ttl     = 1
}
