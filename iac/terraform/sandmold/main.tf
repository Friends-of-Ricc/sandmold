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

module "classroom_setup" {
  source = "./1a_classroom_setup"

  folder_display_name = var.folder_display_name
  parent_folder       = var.parent_folder
  billing_account_id  = var.billing_account_id
  teachers            = var.teachers
  student_projects    = var.student_projects
  services_to_enable  = var.services_to_enable
  iam_user_roles      = var.iam_user_roles
  folder_tags         = var.folder_tags
}

module "apps_deployment" {
  source = "./2_apps_deployment"

  app_deployments = var.app_deployments
  projects = module.classroom_setup.projects
  depends_on = [module.classroom_setup]
}
