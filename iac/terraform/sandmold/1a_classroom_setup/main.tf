# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# iac/terraform/1a_classroom_setup/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
    
  }
}



# Create the main folder for the classroom
resource "google_folder" "classroom" {
    display_name = var.folder_display_name
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

  source = "../../modules/project"

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
