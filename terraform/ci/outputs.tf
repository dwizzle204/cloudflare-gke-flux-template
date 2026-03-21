output "cluster_a_name" {
  description = "Name of cluster A in the CI-safe core plan."
  value       = module.core.cluster_a_name
}

output "cluster_b_name" {
  description = "Name of cluster B in the CI-safe core plan."
  value       = module.core.cluster_b_name
}

output "config_cluster_name" {
  description = "Name of the config cluster in the CI-safe core plan."
  value       = module.core.config_cluster_name
}

output "gateway_static_ip" {
  description = "Reserved global address in the CI-safe core plan."
  value       = module.core.gateway_static_ip
}
