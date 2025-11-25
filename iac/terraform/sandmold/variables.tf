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

variable "folder_display_name" {
  description = "The display name of the folder to create."
  type        = string
}

variable "parent_folder" {
  description = "The parent folder to create the classroom folder in."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account to associate with the projects."
  type        = string
}

variable "teachers" {
  description = "A list of teachers to grant owner access to the classroom folder."
  type        = list(string)
  default     = []
}

variable "student_projects" {
  description = "A list of student projects to create."
  type        = any
  default     = []
}

variable "services_to_enable" {
  description = "A list of services to enable on the projects."
  type        = list(string)
  default     = []
}

variable "iam_user_roles" {
  description = "A list of IAM roles to grant to the users."
  type        = list(string)
  default     = []
}

variable "folder_tags" {
  description = "A map of tags to apply to the folder."
  type        = map(string)
  default     = {}
}

variable "app_deployments" {
  description = "A list of applications to deploy."
  type        = any
  default     = []
}
