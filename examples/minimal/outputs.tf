output "cluster_a_name" {
  description = "Example output for cluster A name."
  value       = module.core.cluster_a_name
}

output "cluster_b_name" {
  description = "Example output for cluster B name."
  value       = module.core.cluster_b_name
}

output "config_cluster_name" {
  description = "Example output for the config cluster name."
  value       = module.core.config_cluster_name
}

output "network_name" {
  description = "Example output for the shared network name."
  value       = module.core.network_name
}
