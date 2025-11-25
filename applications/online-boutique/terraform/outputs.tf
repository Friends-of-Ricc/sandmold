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

# applications/online-boutique/terraform/outputs.tf

output "cluster_name" {
  description = "The name of the created GKE cluster."
  value       = google_container_cluster.online_boutique.name
}

output "cluster_location" {
  description = "The location (region) of the created GKE cluster."
  value       = google_container_cluster.online_boutique.location
}

output "project_id" {
  description = "The project ID where the cluster was deployed."
  value       = var.project_id
}
