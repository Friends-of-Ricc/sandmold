# iac/terraform/1a_classroom_setup/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

resource "random_string" "folder_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Create the main folder for the classroom
resource "google_folder" "classroom" {
    display_name = "${var.folder_display_name}-${random_string.folder_suffix.result}"
  parent       = var.parent_folder
  deletion_protection = false
}

# Grant folder-level permissions to teachers
resource "google_folder_iam_member" "teacher_permissions" {
  for_each = toset(var.teachers)
  folder   = google_folder.classroom.folder_id
  role     = "roles/owner"
  member   = each.key
}

# A map to hold the project module outputs
locals {
  student_projects_map = { for p in var.student_projects : p.project_id_prefix => p }
}

# Call the project module for each student project
module "project" {
  for_each = local.student_projects_map

  source = "../modules/project"

  project_id         = each.value.project_id_prefix
  billing_account_id = var.billing_account_id
  parent             = google_folder.classroom.name
  services_to_enable = var.services_to_enable
  labels             = each.value.labels

  # Create the IAM map for this specific project
  iam_permissions = {
    for role in var.iam_user_roles : role => each.value.users
  }

  depends_on = [google_folder.classroom]
}
