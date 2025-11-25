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

# iac/terraform/1b_single_user_setup/variables.tf

variable "create_project" {
  description = "Set to 'false' if you are using an existing GCP project."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "The ID for your project. If creating a new one, a random suffix will be added."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID to link to the project."
  type        = string
  sensitive   = true
}

variable "user_email" {
  description = "Your Google Cloud email address (e.g., 'your-name@gmail.com')."
  type        = string
}
