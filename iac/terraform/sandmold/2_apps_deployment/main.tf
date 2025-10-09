# iac/terraform/sandmold/2_apps_deployment/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

# Create a map of deployments, keyed by a unique project_id and app_name combination.
locals {
  app_deployments_map = {
    for dep in var.app_deployments : "${dep.project_id}-${dep.app_name}" => dep
  }
}

# Call the Online Boutique module for each project that requests it.
module "online_boutique" {
  source = "../../../../applications/online-boutique/terraform"

  for_each = {
    for key, dep in local.app_deployments_map : key => dep
    if dep.app_name == "online-boutique" && dep.status == "OK"
  }

  project_id = each.value.project_id
  # You can add more variables to pass to the module here if needed
}
