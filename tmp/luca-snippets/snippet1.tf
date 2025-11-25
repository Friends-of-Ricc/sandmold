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

# Terraform
module "projects" {
  for_each = var.my_prefixes
  source   = "../genai-factory/cloud-run-single/0-projects"
  project_config = {
    billing_account_id = "XXXXXXXXX"
    parent             = "folders/my-folder"
    prefix             = each.key
  }
}

module "apps" {
  for_each = var.my_prefixes
  source   = "../genai-factory/cloud-run-single/1-apps"
  lbs_config = {
    external = {
      domain = "${each.key}.ricc.com"
    }
  }
}

variable "my_prefixes" {
  description = "My project prefixes"
  type        = list(string)
  default     = ["one", "two", "three"]
}

