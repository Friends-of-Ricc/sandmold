# Run tests (currently a placeholder)
test:
    echo "No tests defined yet."

# Setup a classroom environment based on a YAML configuration
# Usage: just setup-classroom etc/class_2teachers_6students.yaml
setup-classroom CLASSROOM_YAML:
    #!/usr/bin/env bash
    set -e
    echo "--- Starting Classroom Setup ---"

    # Define paths
    CLASSROOM_TF_DIR="iac/terraform/1a_classroom_setup"
    TF_VARS_FILE="${CLASSROOM_TF_DIR}/terraform.tfvars.json"
    TF_LOG_FILE="terraform_apply.log"
    REPORT_FILE="REPORT.md"

    # Step 1: Prepare Terraform variables from YAML
    echo "--> Preparing Terraform variables..."
    ./bin/prepare_tf_vars.py \
        --classroom-yaml {{CLASSROOM_YAML}} \
        --project-config-yaml etc/project_config.yaml \
        --output-dir ${CLASSROOM_TF_DIR}

    # Step 2: Run Terraform
    echo "--> Initializing and applying Terraform..."
    (cd ${CLASSROOM_TF_DIR} && terraform init && terraform apply -auto-approve) | tee ${TF_LOG_FILE}

    # Step 3: Generate the final report
    echo "--> Generating final report..."
    ./bin/generate_report.py \
        --tf-output-log ${TF_LOG_FILE} \
        --report-path ${REPORT_FILE}

    echo "--- Classroom Setup Complete ---"
    echo "See ${REPORT_FILE} for details."
