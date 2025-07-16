# P3: Project Prefix by Type

This document describes the implementation of project prefixing based on the `desk-type` of a `schoolbench`.

## Feature Description

To improve project identification and organization within Google Cloud, all project IDs are now automatically prefixed based on their designated `desk-type` in the classroom YAML file.

The prefixes are as follows:

*   **`tch-`**: Applied to projects where the `desk-type` is `teacher`.
*   **`std-`**: Applied to projects where the `desk-type` is `student` or if the `desk-type` is not specified (it defaults to `student`).

## Implementation Details

The logic for this feature is implemented in the `bin/prepare_tf_vars.py` script. This script reads the `desk-type` for each `schoolbench` and prepends the appropriate prefix to the `project` name before generating the `terraform.tfvars.json` file.

This ensures that the project IDs passed to Terraform already include the correct prefix, requiring no changes to the Terraform code itself.