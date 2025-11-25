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

gcloud beta saas-runtime releases create sample-vm-v2-0-0 --unit-kind=sandmold-sample-vm --blueprint-package=europe-west2-docker.pkg.dev/check-docs-in-go-slash-sredemo/sandmold-saas-registry-v2/terraform-vm --location =europe-west2 --input-variable-defaults="variable=instance_name,value=default-instance,type=string" --input-variable-defaults="variable=tenant_project_id,value=check-docs-in-go-slash-sredemo,type=string" --input-variable-defaults="variable=tenant_project_number,value=467916597830,type=int" --project=check-docs-in-go-slash-sredemo
