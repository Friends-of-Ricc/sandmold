# applications/online-boutique/terraform/variables.tf

variable "project_id" {
  description = "The ID of the project where the GKE cluster will be created."
  type        = string
}

variable "cluster_name" {
  description = "The name for the GKE cluster."
  type        = string
  default     = "online-boutique-cluster"
}

variable "location" {
  description = "The GCP region where the GKE cluster will be created."
  type        = string
  default     = "us-central1"
}
