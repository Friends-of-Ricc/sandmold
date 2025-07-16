# This is more meaningful to Riccardo as a Rails dev.
RAILS_ROOT := justfile_directory()
SAMPLE_CLASSROOM_YAML := "etc/samples/class_2teachers_6students.yaml"
CLASSROOM_TF_DIR := 'iac/terraform/1a_classroom_setup'

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
    #echo "No tests defined yet."
    just test-yaml etc/samples/class_2teachers_6students.yaml
    just test-yaml etc/samples/class_2teachers_4realstudents.yaml

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
    time bin/classroom-down.sh {{CLASSROOM_YAML}} {{CLASSROOM_TF_DIR}}

# teardown a classroom from default SAMPLE_CLASSROOM_YAML
classroom-down-sampleclass:
    just classroom-down {{SAMPLE_CLASSROOM_YAML}}

# inspect a classroom from default SAMPLE_CLASSROOM_YAML
classroom-inspect-sampleclass:
    just classroom-inspect {{SAMPLE_CLASSROOM_YAML}}

# Run a preflight check on a specific classroom YAML
classroom-inspect CLASSROOM_YAML:
    @bin/classroom-inspect.py {{CLASSROOM_YAML}}

# Find open, non-Google billing accounts
open-baids:
    @bin/list-billing-accounts.py

# --- Bulk Operations ---

# Setup all classroom environments from etc/samples/
classroom-up-all:
    @for yaml_file in $(find etc/samples -name '*.yaml'); do \
        echo "--- [justfile] Setting up classroom from $yaml_file ---"; \
        just classroom-up $yaml_file; \
    done

# Teardown all classroom environments from etc/samples/
classroom-down-all:
    @for yaml_file in $(find etc/samples -name '*.yaml'); do \
        echo "--- Tearing down classroom from $yaml_file ---"; \
        just classroom-down $yaml_file; \
    done

tfplan WORKSPACE_NAME="ng2teachers-4realstudents":
    echo "Using workspace: {{WORKSPACE_NAME}}"
    cd {{CLASSROOM_TF_DIR}} && \
    terraform init && \
    terraform workspace select -or-create {{WORKSPACE_NAME}} && \
    terraform plan -var-file "workspaces/{{WORKSPACE_NAME}}/terraform.tfvars.json"

    @echo "👍 IT WORKS!"
#terraform workspace select -or-create ng2teachers-4realstudents && terraform plan -var-file
