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

# iac/terraform/modules/project/variables.tf

variable "create_project" {
  description = "If true, create a new project. If false, use a data source."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "The desired project ID. A random suffix is appended if create_project is true."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account to link to the project."
  type        = string
  sensitive   = true
}

variable "parent" {
  description = "The resource to create the project under (e.g., 'folders/12345')."
  type        = string
  default     = null
}

variable "services_to_enable" {
  description = "A list of APIs to enable on the project."
  type        = list(string)
  default     = []
}

variable "iam_permissions" {
  description = "A map where keys are roles and values are lists of members."
  type        = map(list(string))
  default     = {}
}

variable "labels" {
  description = "A map of labels to apply to the project."
  type        = map(string)
  default     = {}
}

