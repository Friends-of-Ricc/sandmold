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
