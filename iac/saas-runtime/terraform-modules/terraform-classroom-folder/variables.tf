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

# iac/saas-runtime/terraform-classroom-folder/variables.tf

variable "parent_folder" {
  description = "The parent resource for the folder, e.g., 'folders/12345' or 'organizations/67890'."
  type        = string
}

variable "teacher_email" {
  description = "The email of the teacher to grant owner access to the folder."
  type        = string
  default = "ricc@google.com"
}
