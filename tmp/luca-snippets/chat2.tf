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

locals {
  projects_configs = parse_yaml

  attendee_iam_emails = {
    for attendee in var.attendee_emails : attendee => "user:${attendee}"
  }
  usernames = {
    for attendee in var.attendee_emails : attendee => split("@", attendee)[0]
  }
}

resource "google_organization_iam_member" "organization_iam_org_viewer" {
  for_each = local.usernames
  org_id   = "26643948309"
  role     = "roles/resourcemanager.organizationViewer"
  member   = local.attendee_iam_emails[each.key]
}

resource "google_organization_iam_member" "organization_iam_os_login_ext" {
  for_each = local.usernames
  org_id   = "26643948309"
  role     = "roles/compute.osLoginExternalUser"
  member   = local.attendee_iam_emails[each.key]
}

module "folder" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/folder"
  parent = "organizations/26643948309"
  name   = "TJS Mini"
}

module "firewall-policy" {
  source    = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-firewall-policy"
  name      = "tjs-fw-policy"
  parent_id = module.folder.id
  attachments = {
    tjs = module.folder.id
  }
  ingress_rules = {
    ssh = {
      priority = 1000
      match = {
        source_ranges  = ["35.235.240.0/20"]
        layer4_configs = [{ protocol = "tcp", ports = ["22"] }]
      }
    }
  }
}

module "project" {
  for_each        = local.usernames
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project"
  billing_account = "017479-47ADAB-670295"
  name            = "${each.value}-0"
  parent          = module.folder.id
  prefix          = "tjs"
  services = [
    "compute.googleapis.com",
    "serviceusage.googleapis.com"
  ]
  iam_by_principals = {
    (local.attendee_iam_emails[each.key]) = [
      "roles/browser",
      "roles/iap.tunnelResourceAccessor",
      "roles/compute.instanceAdmin.v1",
      "roles/compute.networkAdmin",
      "roles/compute.securityAdmin",
      "roles/iam.serviceAccountUser",
      "roles/viewer"
    ]
  }
}
