output "cluster_a_name" {
  value = module.cluster_a.name
}

output "cluster_b_name" {
  value = module.cluster_b.name
}

output "config_cluster_name" {
  value = module.cluster_a.name
}

output "gateway_static_ip" {
  value = google_compute_global_address.gateway_ip.address
}

output "cloudflare_record" {
  value = cloudflare_dns_record.gateway.name
}
