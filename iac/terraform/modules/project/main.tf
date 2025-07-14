# iac/terraform/modules/project/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

# This local block determines the final project details based on
# whether we are creating a new project or sourcing an existing one.
locals {
  # Generate a random suffix for new projects to ensure uniqueness.
  random_suffix = random_string.suffix.result

  # Use a data source to get information about an existing project.
  existing_project_data = var.create_project ? null : data.google_project.existing[0]

  # Determine the final project ID.
  final_project_id = var.create_project ? "${var.project_id}-${local.random_suffix}" : var.project_id

  # Determine the final project object.
  project = var.create_project ? google_project.new[0] : local.existing_project_data
}

# Resource to generate a random 4-character hex string.
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Data source to get an existing project by its ID.
# This is only triggered when var.create_project is false.
data "google_project" "existing" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id
}

# Resource to create a new Google Cloud project.
# This is only triggered when var.create_project is true.
resource "google_project" "new" {
  count              = var.create_project ? 1 : 0
  project_id         = local.final_project_id
  name               = local.final_project_id
  billing_account    = var.billing_account_id
  parent             = var.parent
}

# Enable the specified APIs on the project.
resource "google_project_service" "apis" {
  for_each                   = toset(var.services_to_enable)
  project                    = local.project.project_id
  service                    = each.key
  disable_dependent_services = true

  # This dependency ensures that services are enabled only after a new
  # project has been fully created and linked to billing.
  depends_on = [google_project.new]
}

# Flatten the IAM permissions map into a list of objects
# that can be used with a for_each loop.
locals {
  iam_bindings = flatten([
    for role, members in var.iam_permissions : [
      for member in members : {
        role   = role
        member = member
      }
    ]
  ])
  iam_bindings_map = { for b in local.iam_bindings : "${b.role}/${b.member}" => b }
}

# Grant the specified IAM roles to the specified members.
resource "google_project_iam_member" "permissions" {
  for_each = local.iam_bindings_map
  project  = local.project.project_id
  role     = each.value.role
  member   = each.value.member

  depends_on = [google_project_service.apis]
}
