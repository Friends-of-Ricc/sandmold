
# list all targets. This should be the first target in the file and DEFAULT
list:
    just -l


init:
    uv pip install -r pyproject.toml

# Run tests (currently a placeholder)
test:
    #echo "No tests defined yet."
    just test-yaml etc/class_2teachers_6students.yaml
    just test-yaml etc/class_2teachers_4realstudents.yaml

# Test a classroom YAML file for common errors
test-yaml CLASSROOM_YAML:
    uv run python ./tests/test_yaml_validation.py --classroom-yaml {{CLASSROOM_YAML}}

# Setup a classroom environment based on a YAML configuration
# Usage: just setup-classroom etc/class_2teachers_6students.yaml
setup-classroom CLASSROOM_YAML:
    ./bin/setup-classroom.sh {{CLASSROOM_YAML}}

# Setup a classroom environment based on a YAML configuration
# Usage: just setup-classroom etc/class_2teachers_6students.yaml
setup-sample-class:
    just setup-classroom etc/class_2teachers_6students.yaml

# Teardown a classroom environment
teardown-classroom CLASSROOM_YAML:
    ./bin/teardown-classroom.sh {{CLASSROOM_YAML}}

