output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "Name of the created cluster."
}

output "cluster_nodes" {
  value       = module.cluster.cluster_nodes
  description = "Name, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "vpc_id" {
  value       = module.network.vpc_id
  description = "ID of the VPC in which the cluster has been created."
}
