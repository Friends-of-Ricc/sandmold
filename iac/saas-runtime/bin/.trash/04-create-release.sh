#!/bin/bash
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


set -euo pipefail

source .env

echo "Creating Release..."

gcloud beta --project="$GOOGLE_CLOUD_PROJECT" saas-runtime releases create v1     --location="$GOOGLE_CLOUD_REGION"     --unit-kind="sandmold-test-vm"     --blueprint-package="gs://$BUCKET_NAME/terraform-files.zip"

