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

# iac/terraform/1b_single_user_setup/outputs.tf

output "projects" {
  description = "A map of the created project, with the project ID as the key."
  value = {
    (module.project.project_id) = {
      project_id     = module.project.project_id
      project_number = module.project.project_number
    }
  }
}
