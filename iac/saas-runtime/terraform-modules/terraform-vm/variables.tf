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

variable "region" {
  description = "The Google Cloud region"
  type        = string
  #default     = "us-central1"
  default     = "europe-west3"
}

variable "zone" {
  description = "The Google Cloud zone"
  type        = string
  #default     = "us-central1-a"
  default     = "europe-west3-a"
}

variable "instance_name" {
  description = "Name for the Compute Engine instance"
  type        = string
  default = "sandmold-test-vm-instance"
}

variable "machine_type" {
  description = "Machine type for the Compute Engine instance"
  type        = string
  default = "e2-medium"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default = 10
}

variable "actuation_sa" {
  description = "The email of the Actuation Service Account"
  type        = string
}

variable "tenant_project_id" {
  description = "The project ID of the tenant project"
  type        = string
}

variable "tenant_project_number" {
  description = "The project number of the tenant project"
  type        = number
}

variable "tags" {
  description = "A list of network tags to apply to the instance."
  type        = list(string)
  default     = ["allow-ssh", "sandmold"]
}
