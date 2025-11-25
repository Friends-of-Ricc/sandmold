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

# iac/saas-runtime/terraform-classroom-folder/main.tf

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
  display_name = "classroom-folder-for-${var.teacher_email}"
  parent       = var.parent_folder
}

# Grant folder-level permissions to teachers
resource "google_folder_iam_member" "teacher_permissions" {
  folder   = google_folder.classroom.folder_id
  role     = "roles/owner"
  member   = "user:${var.teacher_email}"
}
