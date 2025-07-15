

# This is more meaningful to Riccardo as a Rails dev.
RAILS_ROOT := justfile_directory()

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
# Usage: just setup-classroom etc/class_2teachers_6students.yaml
setup-classroom CLASSROOM_YAML:
    ./bin/setup-classroom.sh {{CLASSROOM_YAML}}

# Setup a classroom environment based on a YAML configuration
# Usage: just setup-classroom etc/class_2teachers_6students.yaml
setup-sample-class:
    just setup-classroom etc/samples/class_2teachers_6students.yaml

# Teardown a classroom environment
teardown-classroom CLASSROOM_YAML:
    ./bin/teardown-classroom.sh {{CLASSROOM_YAML}}

