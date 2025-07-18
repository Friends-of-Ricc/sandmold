# iac/terraform/1b_single_user_setup/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

# Call the project module to do the actual work.
module "project" {
  source = "../modules/project"

  create_project     = var.create_project
  project_id         = var.project_id
  billing_account_id = var.billing_account_id
  parent             = var.parent
  services_to_enable = [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "apphub.googleapis.com"
  ]
  iam_permissions = {
    "roles/editor" = ["user:${var.user_email}"],
    "roles/iam.serviceAccountUser" = ["user:${var.user_email}"],
    "roles/run.admin" = ["user:${var.user_email}"],
    "roles/storage.admin" = ["user:${var.user_email}"],
    "roles/aiplatform.user" = ["user:${var.user_email}"]
  }
}
