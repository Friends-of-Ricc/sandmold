# applications/online-boutique/terraform/outputs.tf

output "cluster_name" {
  description = "The name of the created GKE cluster."
  value       = google_container_cluster.online_boutique.name
}

output "cluster_location" {
  description = "The location (region) of the created GKE cluster."
  value       = google_container_cluster.online_boutique.location
}

output "project_id" {
  description = "The project ID where the cluster was deployed."
  value       = var.project_id
}
