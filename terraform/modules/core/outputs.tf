output "cluster_a_name" {
  description = "Name of cluster A."
  value       = google_container_cluster.cluster_a.name
}

output "cluster_b_name" {
  description = "Name of cluster B."
  value       = google_container_cluster.cluster_b.name
}

output "config_cluster_name" {
  description = "Name of the config cluster used for multicluster ingress."
  value       = google_container_cluster.cluster_a.name
}

output "gateway_static_ip" {
  description = "Reserved global IP address for the gateway."
  value       = google_compute_global_address.gateway_ip.address
}

output "network_name" {
  description = "Name of the shared VPC network."
  value       = google_compute_network.this.name
}

output "subnet_names" {
  description = "Names of the cluster subnets."
  value = [
    google_compute_subnetwork.cluster_a.name,
    google_compute_subnetwork.cluster_b.name
  ]
}
