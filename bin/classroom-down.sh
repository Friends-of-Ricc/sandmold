#!/usr/bin/env bash
set -e
set -o pipefail

# cd to the root of the git repository
cd "$(git rev-parse --show-toplevel)"

CLASSROOM_YAML="$1"
# Use command-line arg for billing account, fallback to ENV, then error out.
BILLING_ACCOUNT_ID="${2:-$BILLING_ACCOUNT_ID}"
GCLOUD_USER=$(gcloud config get-value account --quiet)
CLASSROOM_TF_DIR="iac/terraform/sandmold/1a_classroom_setup"

if [ -z "$BILLING_ACCOUNT_ID" ]; then
    echo "Error: Billing account ID not provided."
    echo "Usage: $0 <classroom_yaml> [billing_account_id]"
    echo "Alternatively, set the BILLING_ACCOUNT_ID environment variable."
    exit 1
fi

echo "--- Starting Classroom Teardown for ${CLASSROOM_YAML} in ${CLASSROOM_TF_DIR} ---"

# Get the workspace name from the new schema
WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq -r .metadata.name)

# Define paths relative to the classroom's terraform directory
CLASSROOM_WORKSPACE_DIR="${CLASSROOM_TF_DIR}/workspaces/${WORKSPACE_NAME}"
mkdir -p "${CLASSROOM_WORKSPACE_DIR}"

TF_VARS_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/terraform.tfvars.json"
REPORT_FILE="${CLASSROOM_WORKSPACE_DIR}/REPORT.md"

# Prepare terraform variables to ensure the tfvars file exists
echo "--> Preparing Terraform variables..."
uv run python ./bin/prepare_tf_vars.py \
    --classroom-yaml "${CLASSROOM_YAML}" \
    --project-config-yaml etc/project_config.yaml \
    --output-file "${TF_VARS_FILE}" \
    --project-root "$(pwd)" \
    --gcloud-user "${GCLOUD_USER}" \
    --billing-account-id "${BILLING_ACCOUNT_ID}"

RELATIVE_TF_VARS_FILE="workspaces/${WORKSPACE_NAME}/terraform.tfvars.json"

(cd "${CLASSROOM_TF_DIR}" && terraform init && terraform workspace select -or-create "${WORKSPACE_NAME}" && terraform destroy -auto-approve -var-file="${RELATIVE_TF_VARS_FILE}")

# Re-create the workspace directory so we can write the report
mkdir -p "${CLASSROOM_WORKSPACE_DIR}"

echo "--> Generating teardown report..."
uv run ./bin/generate-teardown-report.py \
    --classroom-yaml "${CLASSROOM_YAML}" \
    --report-path "${REPORT_FILE}"

echo "--- Classroom Teardown Complete ---"
echo "See ${REPORT_FILE} for details."