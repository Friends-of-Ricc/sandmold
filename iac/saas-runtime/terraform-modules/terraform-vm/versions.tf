terraform {
  required_version = "1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  backend "gcs" {
    bucket = "${TF_BLUEPRINT_BUCKET}"
    prefix = "terraform/state/terraform-vm"
  }
}