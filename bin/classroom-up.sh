#!/usr/bin/env bash
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

set -e
set -o pipefail

# cd to the root of the git repository
cd "$(git rev-parse --show-toplevel)"

CLASSROOM_YAML="$1"
CLASSROOM_TF_DIR="$2"
# Use command-line arg for billing account, fallback to ENV, then error out.
BILLING_ACCOUNT_ID="${3:-$BILLING_ACCOUNT_ID}"

if [ -z "$BILLING_ACCOUNT_ID" ]; then
    echo "Error: Billing account ID not provided."
    echo "Usage: $0 <classroom_yaml> <terraform_dir> [billing_account_id]"
    echo "Alternatively, set the BILLING_ACCOUNT_ID environment variable."
    exit 1
fi

echo "--- Starting Classroom Setup for ${CLASSROOM_YAML} in ${CLASSROOM_TF_DIR} ---"

# --- Step 1: Define all paths based on workspace ---
GCLOUD_USER=$(gcloud config get-value account --quiet)
SANITIZED_GCLOUD_USER=$(echo -n "${GCLOUD_USER}" | tr '@.' '-')
BASE_WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq -r .metadata.name)
WORKSPACE_NAME="${SANITIZED_GCLOUD_USER}--${BASE_WORKSPACE_NAME}"
echo "Workspace name: ${WORKSPACE_NAME}"

CLASSROOM_WORKSPACE_DIR="${CLASSROOM_TF_DIR}/workspaces/${WORKSPACE_NAME}"
mkdir -p "${CLASSROOM_WORKSPACE_DIR}"

# Define absolute paths for all artifacts
TF_VARS_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/terraform.tfvars.json"
TF_OUTPUT_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/terraform_output.json"
REPORT_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/REPORT.md"
# New timestamped log file
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
APPLY_LOG_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/${TIMESTAMP}_apply.log"

echo "DEBUG: All artifacts will be stored in: ${CLASSROOM_WORKSPACE_DIR}"
echo "DEBUG: Terraform logs will be saved to: ${APPLY_LOG_FILE}"

# --- Step 2: Prepare Terraform variables ---
echo "--> Preparing Terraform variables..."
uv run python ./bin/prepare_tf_vars.py \
    --classroom-yaml "${CLASSROOM_YAML}" \
    --project-config-yaml etc/project_config.yaml \
    --output-file "${TF_VARS_FILE}" \
    --project-root "$(pwd)"

# --- Step 3: Run Terraform, teeing output to a log file ---
echo "--> Initializing and applying Terraform in workspace: ${WORKSPACE_NAME}"

# Calculate the relative path for the tfvars file from the terraform directory
RELATIVE_TF_VARS_FILE="workspaces/${WORKSPACE_NAME}/terraform.tfvars.json"

# The -var-file path is now relative to the CLASSROOM_TF_DIR
(cd "${CLASSROOM_TF_DIR}" && 
    terraform init && 
    terraform workspace select -or-create "${WORKSPACE_NAME}" && 
    terraform apply -auto-approve -var-file="${RELATIVE_TF_VARS_FILE}") 2>&1 | tee "${APPLY_LOG_FILE}"

# --- Step 4: Get Terraform output as JSON ---
echo "--> Getting Terraform output..."
(cd "${CLASSROOM_TF_DIR}" && terraform output -json > "${TF_OUTPUT_FILE}")

# --- Step 5: Generate the final report ---
echo "--> Generating final report..."
uv run ./bin/generate_report.py \
    --tf-output-json "${TF_OUTPUT_FILE}" \
    --classroom-yaml "${CLASSROOM_YAML}" \
    --report-path "${REPORT_FILE}"

echo "--- Classroom Setup Complete ---"
echo "See ${REPORT_FILE} for details."
