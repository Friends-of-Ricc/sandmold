# Changelog

## 0.2.0

- **Feat: Implement comprehensive YAML validation suite.**
  - Created a modular and extensible validation framework in `tests/validation/`.
  - Added robust checks for schema correctness, data types, and mandatory fields.
  - Implemented regex-based validation for constrained fields like GCP Project IDs and environment variable names.
  - Added checks for business logic, such as uniqueness of project names and ensuring specified applications exist in the `applications/` directory.
  - Greatly improved user experience with colorful, emoji-rich output, including a validation synopsis.

## 0.1.0

- **Feat: Adopt Kubernetes-style schema for Classroom YAML.**
  - The classroom YAML structure has been refactored to follow a Kubernetes-style object model (`apiVersion`, `kind`, `metadata`, `spec`). This improves versioning, clarity, and future automation capabilities.
  - The Terraform workspace name is now derived from `metadata.name`, while a new optional `spec.folder.displayName` field controls the user-facing Google Cloud Folder name.
  - Renamed `type` to `desk-type` in the schoolbench definition for better clarity.
  - All documentation and sample files have been updated to the new, more robust schema.

## 0.0.9

- Refactor: `setup-classroom.sh` now accepts a Terraform directory argument, making it more flexible.
- Feat: All script outputs (`REPORT.md`, `terraform_output.json`, etc.) are now stored within the specified Terraform directory, improving organization.
- Fix: Removed the creation of a nested `workspaces` directory, simplifying the file structure.

## 0.0.8

- Fix: Correctly extract workspace name in `setup-classroom.sh` by using `yq -r`.
- Fix: Resolve argument parsing error in `test_yaml_validation.py`.
- Chore: Update `justfile` to provide the project root directory to tests.

## 0.0.7

- Implemented Terraform workspaces to isolate state for each classroom, preventing conflicts.
- Updated `justfile` to manage workspaces automatically based on the classroom YAML.
- Migrated existing Terraform state to a dedicated workspace.

## 0.0.5

- Implemented a modular and robust Terraform infrastructure for provisioning Google Cloud resources.
- Supports two distinct workflows: multi-project classroom setup (CUJ001) and single-project user setup (CUJ002).
- Created a reusable `project` module as the single source of truth for project configuration.
- Added a `just setup-classroom` command to orchestrate the entire classroom provisioning workflow.

## 0.0.4

- Added sample blueprint for Online Boutique to `etc/samples`.

## 0.0.3

- Added app dependency relationship to E/R diagram in README.md

## 0.0.2

- Updated architecture diagram to E/R diagram in README.md

## 0.0.1

- Added initial Mermaid graph for architecture to README.md