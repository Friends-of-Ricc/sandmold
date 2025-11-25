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
