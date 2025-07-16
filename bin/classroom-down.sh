#!/usr/bin/env bash
set -e

CLASSROOM_YAML="$1"
CLASSROOM_TF_DIR="$2"

if [ -z "$CLASSROOM_TF_DIR" ]; then
    echo "Error: Terraform directory not provided. Usage: $0 <classroom_yaml> <terraform_dir>"
    exit 1
fi

echo "--- Starting Classroom Teardown for ${CLASSROOM_YAML} in ${CLASSROOM_TF_DIR} ---"

# Get the workspace name from the new schema
WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq -r .metadata.name)

# Define paths relative to the classroom's terraform directory
CLASSROOM_WORKSPACE_DIR="${CLASSROOM_TF_DIR}/workspaces/${WORKSPACE_NAME}"
TF_VARS_FILE="${CLASSROOM_WORKSPACE_DIR}/terraform.tfvars.json"
REPORT_FILE="${CLASSROOM_WORKSPACE_DIR}/REPORT.md"

(cd "${CLASSROOM_TF_DIR}" && terraform workspace select "${WORKSPACE_NAME}" && terraform destroy -auto-approve -var-file="${TF_VARS_FILE}")

# Re-create the workspace directory so we can write the report
mkdir -p "${CLASSROOM_WORKSPACE_DIR}"

echo "--> Generating teardown report..."
./bin/generate-teardown-report.py \
    --classroom-yaml "${CLASSROOM_YAML}" \
    --report-path "${REPORT_FILE}"

echo "--- Classroom Teardown Complete ---"
echo "See ${REPORT_FILE} for details."



