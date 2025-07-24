terraform {
  required_version = "1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  # Do NOT add a backend GCS! This gets added by Infra Manager!
}
