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
# Checks if the environment is set up correctly.
#

# Source the environment variables
if [ -f .env ]; then
    source .env
else
    echo "🛑 .env file not found. Please run 'just setup-env' first."
    exit 1
fi

if [ -f .env.post ]; then
    source .env.post
fi

echo "🧐 Checking environment setup..."

# --- Check GCS Bucket ---
TF_BLUEPRINT_BUCKET="sandmold-tf-blueprints-${GOOGLE_CLOUD_PROJECT}"
echo -n "Verifying GCS bucket (gs://${TF_BLUEPRINT_BUCKET})... "
if gsutil ls "gs://${TF_BLUEPRINT_BUCKET}" &> /dev/null; then
    echo "✅ Bucket exists!"
    echo "📁 Listing bucket contents:"
    gsutil ls "gs://${TF_BLUEPRINT_BUCKET}"
else
    echo "❌ Bucket does not exist. Please run 'just setup-env'."
fi

# --- Check gcloud config ---
echo -n "Verifying gcloud project setting... "
CURRENT_PROJECT=$(gcloud config get-value project)
if [ "${CURRENT_PROJECT}" == "${GOOGLE_CLOUD_PROJECT}" ]; then
    echo "✅ gcloud project is set to '${GOOGLE_CLOUD_PROJECT}'."
else
    echo "❌ gcloud project is set to '${CURRENT_PROJECT}' but should be '${GOOGLE_CLOUD_PROJECT}'. Please run 'gcloud config set project ${GOOGLE_CLOUD_PROJECT}'."
fi

echo -n "Verifying gcloud identity... "
CURRENT_ACCOUNT=$(gcloud config get-value account)
if [ "${CURRENT_ACCOUNT}" == "${GOOGLE_IDENTITY}" ]; then
    echo "✅ gcloud account is set to '${GOOGLE_IDENTITY}'."
else
    echo "❌ gcloud account is set to '${CURRENT_ACCOUNT}' but should be '${GOOGLE_IDENTITY}'. Please run 'gcloud config set account ${GOOGLE_IDENTITY}'."
fi

# --- Check Application Default Login ---
echo -n "Verifying Application Default Login project... "
ADC_FILE_PATH=$(gcloud info --format="value(config.paths.application_default_credentials)")
if [ -f "${ADC_FILE_PATH}" ]; then
    if grep -q '"quota_project_id"' "${ADC_FILE_PATH}"; then
        ADC_PROJECT=$(grep '"quota_project_id"' "${ADC_FILE_PATH}" | cut -d '"' -f 4)
        if [ "${ADC_PROJECT}" == "${GOOGLE_CLOUD_PROJECT}" ]; then
            echo "✅ Application Default Login is configured for project '${GOOGLE_CLOUD_PROJECT}'."
        else
            echo "⚠️  Application Default Login is configured for project '${ADC_PROJECT}', but this script expects '${GOOGLE_CLOUD_PROJECT}'."
            echo "   If you experience issues, please run 'gcloud auth application-default login'."
        fi
    else
        echo "❌ 'quota_project_id' not found in ADC file: ${ADC_FILE_PATH}."
        echo "   The file might be misconfigured. Please run 'gcloud auth application-default login'."
    fi
else
    echo "❌ Application Default Credentials file not found at '${ADC_FILE_PATH}'."
    echo "   Please run 'gcloud auth application-default login' to create it."
fi

echo "🎉 Setup check complete!"