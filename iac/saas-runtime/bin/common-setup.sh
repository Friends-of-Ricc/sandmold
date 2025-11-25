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

#
# Common setup script to be sourced by other scripts.
# It loads environment variables and defines derived constants.

# Determine the absolute path of the project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"

# Source the core project constants
source "${PROJECT_ROOT}/.env"

# Source the default SaaS values
if [ -f "${PROJECT_ROOT}/.env.saas_defaults" ]; then
    source "${PROJECT_ROOT}/.env.saas_defaults"
fi

# Define and export derived variables
export TF_ACTUATOR_SA_EMAIL="sandmold-tf-actuator@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
export TF_BLUEPRINT_BUCKET="sandmold-tf-blueprints-${GOOGLE_CLOUD_PROJECT}"
export SAAS_SERVICE_ACCOUNT="service-${PROJECT_NUMBER}@gcp-sa-saasservicemgmt.iam.gserviceaccount.com"
