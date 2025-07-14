# iac/terraform/1b_single_user_setup/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

# Read the shared project configuration YAML file.
locals {
  project_config = yamldecode(file("${path.module}/../../etc/project_config.yaml"))

  # Create the IAM map for this specific user.
  iam_permissions = {
    for role in local.project_config.iam_permissions.user_roles : role => ["user:${var.user_email}"]
  }
}

# Call the project module to do the actual work.
module "project" {
  source = "../modules/project"

  create_project     = var.create_project
  project_id         = var.project_id
  billing_account_id = var.billing_account_id
  parent             = var.parent
  services_to_enable = local.project_config.services_to_enable
  iam_permissions    = local.iam_permissions
}
