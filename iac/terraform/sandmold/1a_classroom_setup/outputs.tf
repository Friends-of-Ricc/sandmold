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

# iac/terraform/1a_classroom_setup/outputs.tf

output "projects" {
  description = "A map of the created projects, with the project ID as the key."
  value = {
    for key, proj in module.project : key => {
      project_id     = proj.project_id
      project_number = proj.project_number
      apps           = local.student_projects_map[key].apps
    }
  }
}

output "folder_id" {
  description = "The ID of the created classroom folder."
  value       = google_folder.classroom.folder_id
}
