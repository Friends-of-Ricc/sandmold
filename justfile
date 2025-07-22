# This is more meaningful to Riccardo as a Rails dev.
RAILS_ROOT := justfile_directory()
SAMPLE_CLASSROOM_YAML := "etc/samples/classroom/with_apps.yaml"
CLASSROOM_TF_DIR := 'iac/terraform/1a_classroom_setup'
SANDMOLD_TF_DIR := 'iac/terraform/sandmold'

# list all targets. This should be the first target in the file and DEFAULT
list:
    @echo "RAILS_ROOT: {{RAILS_ROOT}}"
    @echo 1. uv run python ./tests/test_yaml_validation.py --classroom-yaml CLASSROOM_YAML --root-dir "{{justfile_directory()}}"
    @echo 2. uv run python ./tests/test_yaml_validation.py --classroom-yaml CLASSROOM_YAML --root-dir "{{RAILS_ROOT}}"
    just -l

# Initialize the Python environment
init:
    uv pip install -r pyproject.toml

# Run tests (currently a placeholder)
test:
    @for yaml_file in $(find etc/samples/classroom/ -name '*.yaml'); do \
        echo "--- running test on classroom from $yaml_file ---"; \
        just test-yaml $yaml_file; \
    done
    @echo Unfortunately we dont support tests for Single User yet.

# Test a classroom YAML file for common errors
test-yaml CLASSROOM_YAML:
    uv run python ./tests/test_yaml_validation.py --classroom-yaml {{CLASSROOM_YAML}} --root-dir "{{RAILS_ROOT}}"

# Setup a classroom environment based on a YAML configuration
# Usage: just classroom-up etc/samples/class_2teachers_6students.yaml
classroom-up CLASSROOM_YAML:
    time bin/classroom-up.sh {{CLASSROOM_YAML}} {{CLASSROOM_TF_DIR}}

# Setup a classroom environment based on a YAML configuration
classroom-up-sampleclass:
    just classroom-up {{SAMPLE_CLASSROOM_YAML}}

# Teardown a classroom environment
classroom-down CLASSROOM_YAML:
    time bin/classroom-down.sh {{CLASSROOM_YAML}}

# Setup a single-user environment
user-up USER_YAML='etc/samples/single_user/light.yaml':
    time bin/user-up.sh {{USER_YAML}}

# teardown a classroom from default SAMPLE_CLASSROOM_YAML
classroom-down-sampleclass:
    just classroom-down {{SAMPLE_CLASSROOM_YAML}}

# inspect a classroom from default SAMPLE_CLASSROOM_YAML
classroom-inspect-sampleclass:
    just classroom-inspect {{SAMPLE_CLASSROOM_YAML}}

# Run a preflight check on a specific classroom YAML
classroom-inspect CLASSROOM_YAML:
    @uv run python bin/classroom-inspect.py {{CLASSROOM_YAML}}

# Deploy applications to a classroom
classroom-deploy-apps CLASSROOM_YAML:
    @WORKSPACE_NAME=$(python3 -c "import yaml, sys; print(yaml.safe_load(open('{{CLASSROOM_YAML}}'))['metadata']['name'])") && \
    echo "==> Using workspace: $WORKSPACE_NAME" && \
    echo "==> Preparing app deployment variables..." && \
    bin/prepare_app_deployment.py --classroom-yaml {{CLASSROOM_YAML}} --output-file tmp/app_deployment.json --project-root {{RAILS_ROOT}} && \
    cd {{SANDMOLD_TF_DIR}} && \
    terraform init && \
    terraform workspace select -or-create $WORKSPACE_NAME && \
    echo "==> Applying Terraform configuration to create resources..." && \
    terraform apply \
      -var-file="{{RAILS_ROOT}}/iac/terraform/1a_classroom_setup/workspaces/$WORKSPACE_NAME/terraform.tfvars.json" \
      -var="app_deployments=$(cat {{RAILS_ROOT}}/tmp/app_deployment.json)" \
      -auto-approve && \
    echo "==> Extracting deployment details from Terraform output..." && \
    terraform output -json > {{RAILS_ROOT}}/tmp/terraform_output_apps.json && \
    echo "==> Executing application deployment scripts..." && \
    cd {{RAILS_ROOT}} && \
    python3 bin/execute_app_deployment.py --json-file tmp/terraform_output_apps.json


# Find open, non-Google billing accounts
open-baids:
    @bin/list-billing-accounts.py

# --- Bulk Operations ---

# Setup all classroom environments from etc/samples/
classroom-up-all:
    @for yaml_file in $(find etc/samples/classroom/ -name '*.yaml'); do \
        echo "--- [justfile] Setting up classroom from $yaml_file ---"; \
        just classroom-up $yaml_file; \

    done

# Teardown all classroom environments from etc/samples/
classroom-down-all:
    @for yaml_file in $(find etc/samples/classroom/ -name '*.yaml'); do \
        echo "--- Tearing down classroom from $yaml_file ---"; \
        just classroom-down $yaml_file; \
    done


tfplan CLASSROOM_YAML:
    @WORKSPACE_NAME=`python3 -c "import yaml, sys; print(yaml.safe_load(open('{{CLASSROOM_YAML}}'))['metadata']['name'])`" && \
    echo "Using workspace: $WORKSPACE_NAME" && \
    cd {{CLASSROOM_TF_DIR}} && \
    terraform init && \
    terraform workspace select -or-create $WORKSPACE_NAME && \
    terraform plan -var-file "workspaces/$WORKSPACE_NAME/terraform.tfvars.json"

    @echo "👍 IT WORKS!"
#terraform workspace select -or-create ng2teachers-4realstudents && terraform plan -var-file


test-report-for-apps:
    @echo this is testing just the last part of just classroom-up etc/samples/classroom/with_apps.yaml
    python3 bin/generate_report.py \
        --tf-output-json tmp/terraform_output.json \
        --classroom-yaml etc/samples/classroom/with_apps.yaml \
        --report-path tmp/REPORT.md


auth:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "This script will authenticate with Google Cloud using the GCLOUD_IDENTITY specified in .env or set up by you"
    if [ -f .env ]; then
        source .env
    else
        echo ".env file not found. I hope you set up GCLOUD_IDENTITY manually."
    fi
    echo "Authenticating with Google Cloud as $GCLOUD_IDENTITY"
    gcloud auth login "$GCLOUD_IDENTITY" --force # --no-launch-browser
