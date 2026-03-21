output "cluster_a_name" {
  description = "Name of Cluster A, which is the config cluster for the multi-cluster Gateway."
  value       = module.cluster_a.name
}

output "cluster_b_name" {
  description = "Name of Cluster B, which serves as a workload-only cluster."
  value       = module.cluster_b.name
}

output "config_cluster_name" {
  description = "Name of the config cluster used by the multi-cluster Gateway controller."
  value       = module.cluster_a.name
}

output "gateway_static_ip" {
  description = "Reserved global static IP that Cloudflare proxies traffic to."
  value       = google_compute_global_address.gateway_ip.address
}

output "cloudflare_record" {
  description = "Cloudflare DNS record hostname created for the external endpoint."
  value       = cloudflare_dns_record.gateway.name
}
