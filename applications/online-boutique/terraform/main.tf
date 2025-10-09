# applications/online-boutique/terraform/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_container_cluster" "online_boutique" {
  name     = var.cluster_name
  location = var.location
  project  = var.project_id

  # Autopilot cluster
  enable_autopilot = true

  # Depends on the container API being enabled
  depends_on = [google_project_service.container_api]
}
