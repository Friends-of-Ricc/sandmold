# Changelog

## 0.5.6

- **Feat(check-setup): Add project creation and deletion test.**
  - The `check-setup.sh` script can now optionally create and delete a temporary project to verify permissions.
  - This feature is enabled by setting `CREATE_AND_DELETE_TEST_PROJECT=true` in the `.env` file.
- **Fix(auth): Correctly configure Application Default Credentials.**
  - The `just auth` command now includes `gcloud auth application-default login` to ensure Terraform can authenticate correctly.
- **Fix(billing): Remove hardcoded billing account ID.**
  - The `prepare_tf_vars.py` script now reads the `BILLING_ACCOUNT_ID` from the `.env` file instead of a hardcoded value in the sample YAML files.
- **Docs(readme): Improve "Getting started" instructions.**
  - The `README.md` now has a clearer and more logical set of instructions for new users.

## 0.5.5

- **Fix(gcloud): Ensure `get_folder_id.sh` uses project for asset search.**
  - The `tools/get_folder_id.sh` script was failing on the `gcloud asset search-all-resources` command because it requires a project to be specified for billing and API enablement.
  - The script now reads the `GCP_PROJECT_ID` from the `.env` file and uses it with the `--project` flag.
  - Added a check to ensure `GCP_PROJECT_ID` is set in the `.env` file, with a clear error message if it is not.

## 0.5.4

- **Fix(yaml): Corrected invalid project ID and removed non-existent application.**
  - In `etc/samples/class_with_apps.yaml`, the project ID `p3` was renamed to `project-three` to meet the 6-30 character length requirement.
  - The non-existent application `non_existent_app` was removed from the same file.
  - These changes resolve the validation errors that were causing the `just test` command to fail.

## 0.5.3

- **Fix(terraform): Decouple app deployment from `terraform apply`.**
  - The `just classroom-deploy-apps` command was failing due to a race condition where `gcloud` commands would execute before a new project was fully ready for API calls.
  - Removed the `local-exec` provisioner from the `2_apps_deployment` Terraform module.
  - Created a new Python script `bin/execute_app_deployment.py` to handle the application deployment logic.
  - The `justfile` recipe for `classroom-deploy-apps` is now a two-step process:
    1. `terraform apply` creates the resources and outputs deployment information.
    2. The new Python script reads the output and executes the application `start.sh` scripts.
  - This change makes the deployment process more robust by ensuring infrastructure is fully provisioned before attempting to deploy applications.

## 0.5.2

- **Fix(terraform): Remove random suffix from folder names.**
  - The 4-character random suffix is no longer appended to folder display names in `iac/terraform/1a_classroom_setup/main.tf`.
  - This ensures folder names are predictable and match the `displayName` specified in the classroom configuration.
  - Removed the now-unused `random_string` resource and `random` provider.

## 0.5.1

- **Feat(gh): Remove feature request document.**
  - Removed `doc/schemas/future_extensions.md` as the feature is now tracked in issue #12.

## 0.5.0

- **Chore: Move all FRs and bugs to GitHub issues.**
  - All feature requests and bug reports from `doc/feature-requests` and `doc/bugs` have been moved to GitHub issues.
  - This centralizes all work items and improves tracking.

## 0.4.9

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P3-project-prefix-by-type.md` as it is now tracked in issue #6.

## 0.4.8

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P3-app-enablement.md` as the feature is now tracked in issue #5.

## 0.4.7

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P2-preflights-check.md` as the feature is now tracked in issue #4.

## 0.4.6

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/p4_cute_labels.md` as the feature is now tracked in issue #3.

## 0.4.5

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P1-app-creation.md` as the feature is now tracked in issue #2.

## 0.4.4

- **Fix: Correct `foobar` environment variable handling.**
  - Fixed a bug in `_common.sh` that was causing an error when checking for required environment variables.
  - The script now correctly parses the `blueprint.yaml` file and validates the environment.

## 0.4.3

- **Feat: Enhance `foobar` logging.**
  - The `_common.sh` script now includes an `ENV` object in the JSON payload, containing all required environment variables for better debugging.
  - The `gcloud logging write` command now uses the explicit `--project` flag for more robust logging.

## 0.4.2

- **Chore: Refine `foobar` application.**
  - The `_common.sh` script now prints the values of the required environment variables for easier debugging.
  - Removed the unnecessary `GOOGLE_APPLICATION_CREDENTIALS` from the `foobar` blueprint, relying on Application Default Credentials instead.

## 0.4.1

- **Chore: Update `foobar` blueprint.**
  - The `blueprint.yaml` for the `foobar` application has been updated to a richer, more descriptive version.

## 0.4.0

- **Feat: Add `foobar` template application.**
  - Created a new `foobar` application in `applications/foobar` to serve as a template for future applications.
  - The application includes a `blueprint.yaml` for defining metadata and required environment variables.
  - A shared `_common.sh` script provides functions for environment variable validation and structured logging to Google Cloud Logging.
  - `start.sh`, `stop.sh`, and `status.sh` scripts demonstrate how to use the common script.
  - A comprehensive `README.md` explains the purpose and usage of the template.

## 0.3.12

- **Feat: Add teardown report generation.**
  - The `classroom-down.sh` script now generates a `REPORT.md` file indicating that the classroom has been destroyed, including a timestamp.
- **Fix: Ensure workspace directory exists for teardown report.**
  - The `classroom-down.sh` script now re-creates the workspace directory after destroying the resources, ensuring a location exists to write the teardown report.

## 0.3.11

- **Fix: Correct variable name in `prepare_tf_vars.py`.**
  - Fixed a `NameError` by correcting a typo in a variable name.
- **Chore: Update sample YAML to prevent folder name collisions.**
  - The `displayName` in `class_2teachers_4realstudents.yaml` is now unique.

## 0.3.10

- **Fix: Correctly use `labels` in `project_config.yaml`.**
  - Changed the `projects.tags` stanza back to `projects.labels` to correctly reflect the terminology used by the Google Cloud provider for project metadata.
  - The `prepare_tf_vars.py` script was updated to read from the corrected `projects.labels` section.

## 0.3.9

- **Feat: Standardize project tags from `project_config.yaml`.**
  - The `prepare_tf_vars.py` script now reads the `projects.tags` section from `etc/project_config.yaml` and applies them as labels to the projects.
- **Chore: Refactor labeling/tagging implementation.**
  - Corrected the implementation to use the term `tags` in the `project_config.yaml` as requested, while applying them as `labels` in the Terraform code, which is the correct argument for the `google_project` resource.
  - Removed the non-functional folder tagging logic.

## 0.3.8

- **Feat: Standardize project labels from `project_config.yaml`.**
  - The `prepare_tf_vars.py` script now merges labels defined in the `projects.tags` section of `etc/project_config.yaml` with the `desk-type` label.
  - This allows for standardized, centrally-managed labels to be applied to all projects.
- **Chore: Corrected folder tagging implementation.**
  - Removed the non-functional folder tagging logic, as the Terraform provider does not support it in the desired way.

## 0.3.7

- **Feat: Standardize labels from `project_config.yaml`.**
  - The `prepare_tf_vars.py` script now merges labels defined in `etc/project_config.yaml` for both folders and projects.
  - This allows for standardized, centrally-managed labels to be applied to all resources.

## 0.3.6

- **Chore: Update feature documentation.**
  - Added a detailed "Implementation" section to the `p4_cute_labels.md` feature request document.

## 0.3.5

- **Feat: Add labels to folders and projects.**
  - Folders are now tagged with a `sandmold: true` label.
  - Projects are now tagged with a `desk-type: teacher` or `desk-type: student` label.
  - This logic is implemented in `bin/prepare_tf_vars.py` and the Terraform configurations.

## 0.3.4

- **Feat: Add project prefixes based on user type.**
  - Project IDs are now automatically prefixed with `tch-` for `teacher` type and `std-` for `student` type.
  - This logic is implemented in `bin/prepare_tf_vars.py`.
  - Added documentation for this feature in `doc/feature-requests/P3-project-prefix-by-type.md`.

## 0.3.3

- **Feat: Add bulk classroom operations to `justfile`.**
  - Introduced `classroom-up-all` to set up all classrooms defined in `etc/samples/`.
  - Introduced `classroom-down-all` to tear down all classrooms defined in `etc/samples/`.

## 0.3.2

- **Chore: Harmonize documentation with `justfile` commands.**
  - Updated all user-facing documentation (`README.md`, `CHANGELOG.md`, `REPORT.md`, etc.) to reflect the new `just classroom-ACTION` command naming convention.
  - `setup-classroom` is now `classroom-up`.
  - `teardown-classroom` is now `classroom-down`.
  - `preflight-check` is now `classroom-inspect`.
  - `setup-sample-class` is now `classroom-up-sampleclass`.
- **Fix: Corrected `classroom-up` script to handle Terraform variable paths correctly.**
  - The `-var-file` argument now uses a relative path, resolving the `terraform apply` failure.
- **Fix: Updated sample classroom YAML to prevent folder name collisions.**
  - The `displayName` in `class_2teachers_6students.yaml` is now unique, preventing "display name uniqueness" errors on subsequent runs.

## 0.3.1

- **Feat: Enhance `REPORT.md` with actionable details.**
  - The generated report is now a complete, user-centric document.
  - It includes both student-centric and project-centric tables for a comprehensive overview.
  - Adds a "Handy Commands" section with direct `just` commands for teardown, setup, and preflight checks for the specific classroom.
  - The "Class Details" section is enriched with the folder name, description, teacher list, and student/project counts.
- **Fix:** Corrected a persistent bug in `setup-classroom.sh` to ensure all classroom artifacts (`tfvars`, `tfoutput`, `log`, `REPORT.md`) are correctly placed in their isolated, multi-tenant workspace directories.

## 0.3.0

- **Success: Successfully provisioned a multi-project classroom.**
  - After extensive debugging of IAM permissions and billing account constraints, the `just setup-sample-class` command now runs to completion.
  - The root cause was a combination of project quotas, billing account organization policies, and fine-grained IAM permissions (`billing.resourceAssociations.create`).
- **Chore: Cleaned up project artifacts.**
  - Removed the obsolete `backup/` directory.
  - Deleted stray `REPORT.md` files, ensuring reports are only generated within their isolated workspace directories.

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
- Supports two distinct workflows: a multi-project classroom setup (CUJ001) and a single-user setup (CUJ002).
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


## 0.5.5

- **Fix(gcloud): Ensure `get_folder_id.sh` uses project for asset search.**
  - The `tools/get_folder_id.sh` script was failing on the `gcloud asset search-all-resources` command because it requires a project to be specified for billing and API enablement.
  - The script now reads the `GCP_PROJECT_ID` from the `.env` file and uses it with the `--project` flag.
  - Added a check to ensure `GCP_PROJECT_ID` is set in the `.env` file, with a clear error message if it is not.

## 0.5.4

- **Fix(yaml): Corrected invalid project ID and removed non-existent application.**
  - In `etc/samples/class_with_apps.yaml`, the project ID `p3` was renamed to `project-three` to meet the 6-30 character length requirement.
  - The non-existent application `non_existent_app` was removed from the same file.
  - These changes resolve the validation errors that were causing the `just test` command to fail.

## 0.5.3

- **Fix(terraform): Decouple app deployment from `terraform apply`.**
  - The `just classroom-deploy-apps` command was failing due to a race condition where `gcloud` commands would execute before a new project was fully ready for API calls.
  - Removed the `local-exec` provisioner from the `2_apps_deployment` Terraform module.
  - Created a new Python script `bin/execute_app_deployment.py` to handle the application deployment logic.
  - The `justfile` recipe for `classroom-deploy-apps` is now a two-step process:
    1. `terraform apply` creates the resources and outputs deployment information.
    2. The new Python script reads the output and executes the application `start.sh` scripts.
  - This change makes the deployment process more robust by ensuring infrastructure is fully provisioned before attempting to deploy applications.

## 0.5.2

- **Fix(terraform): Remove random suffix from folder names.**
  - The 4-character random suffix is no longer appended to folder display names in `iac/terraform/1a_classroom_setup/main.tf`.
  - This ensures folder names are predictable and match the `displayName` specified in the classroom configuration.
  - Removed the now-unused `random_string` resource and `random` provider.

## 0.5.1

- **Feat(gh): Remove feature request document.**
  - Removed `doc/schemas/future_extensions.md` as the feature is now tracked in issue #12.

## 0.5.0

- **Chore: Move all FRs and bugs to GitHub issues.**
  - All feature requests and bug reports from `doc/feature-requests` and `doc/bugs` have been moved to GitHub issues.
  - This centralizes all work items and improves tracking.

## 0.4.9

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P3-project-prefix-by-type.md` as it is now tracked in issue #6.

## 0.4.8

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P3-app-enablement.md` as the feature is now tracked in issue #5.

## 0.4.7

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P2-preflights-check.md` as the feature is now tracked in issue #4.

## 0.4.6

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/p4_cute_labels.md` as the feature is now tracked in issue #3.

## 0.4.5

- **Feat(gh): Remove feature request document.**
  - Removed `doc/feature-requests/P1-app-creation.md` as the feature is now tracked in issue #2.

## 0.4.4

- **Fix: Correct `foobar` environment variable handling.**
  - Fixed a bug in `_common.sh` that was causing an error when checking for required environment variables.
  - The script now correctly parses the `blueprint.yaml` file and validates the environment.

## 0.4.3

- **Feat: Enhance `foobar` logging.**
  - The `_common.sh` script now includes an `ENV` object in the JSON payload, containing all required environment variables for better debugging.
  - The `gcloud logging write` command now uses the explicit `--project` flag for more robust logging.

## 0.4.2

- **Chore: Refine `foobar` application.**
  - The `_common.sh` script now prints the values of the required environment variables for easier debugging.
  - Removed the unnecessary `GOOGLE_APPLICATION_CREDENTIALS` from the `foobar` blueprint, relying on Application Default Credentials instead.

## 0.4.1

- **Chore: Update `foobar` blueprint.**
  - The `blueprint.yaml` for the `foobar` application has been updated to a richer, more descriptive version.

## 0.4.0

- **Feat: Add `foobar` template application.**
  - Created a new `foobar` application in `applications/foobar` to serve as a template for future applications.
  - The application includes a `blueprint.yaml` for defining metadata and required environment variables.
  - A shared `_common.sh` script provides functions for environment variable validation and structured logging to Google Cloud Logging.
  - `start.sh`, `stop.sh`, and `status.sh` scripts demonstrate how to use the common script.
  - A comprehensive `README.md` explains the purpose and usage of the template.

## 0.3.12

- **Feat: Add teardown report generation.**
  - The `classroom-down.sh` script now generates a `REPORT.md` file indicating that the classroom has been destroyed, including a timestamp.
- **Fix: Ensure workspace directory exists for teardown report.**
  - The `classroom-down.sh` script now re-creates the workspace directory after destroying the resources, ensuring a location exists to write the teardown report.

## 0.3.11

- **Fix: Correct variable name in `prepare_tf_vars.py`.**
  - Fixed a `NameError` by correcting a typo in a variable name.
- **Chore: Update sample YAML to prevent folder name collisions.**
  - The `displayName` in `class_2teachers_4realstudents.yaml` is now unique.

## 0.3.10

- **Fix: Correctly use `labels` in `project_config.yaml`.**
  - Changed the `projects.tags` stanza back to `projects.labels` to correctly reflect the terminology used by the Google Cloud provider for project metadata.
  - The `prepare_tf_vars.py` script was updated to read from the corrected `projects.labels` section.

## 0.3.9

- **Feat: Standardize project tags from `project_config.yaml`.**
  - The `prepare_tf_vars.py` script now reads the `projects.tags` section from `etc/project_config.yaml` and applies them as labels to the projects.
- **Chore: Refactor labeling/tagging implementation.**
  - Corrected the implementation to use the term `tags` in the `project_config.yaml` as requested, while applying them as `labels` in the Terraform code, which is the correct argument for the `google_project` resource.
  - Removed the non-functional folder tagging logic.

## 0.3.8

- **Feat: Standardize project labels from `project_config.yaml`.**
  - The `prepare_tf_vars.py` script now merges labels defined in the `projects.tags` section of `etc/project_config.yaml` with the `desk-type` label.
  - This allows for standardized, centrally-managed labels to be applied to all projects.
- **Chore: Corrected folder tagging implementation.**
  - Removed the non-functional folder tagging logic, as the Terraform provider does not support it in the desired way.

## 0.3.7

- **Feat: Standardize labels from `project_config.yaml`.**
  - The `prepare_tf_vars.py` script now merges labels defined in `etc/project_config.yaml` for both folders and projects.
  - This allows for standardized, centrally-managed labels to be applied to all resources.

## 0.3.6

- **Chore: Update feature documentation.**
  - Added a detailed "Implementation" section to the `p4_cute_labels.md` feature request document.

## 0.3.5

- **Feat: Add labels to folders and projects.**
  - Folders are now tagged with a `sandmold: true` label.
  - Projects are now tagged with a `desk-type: teacher` or `desk-type: student` label.
  - This logic is implemented in `bin/prepare_tf_vars.py` and the Terraform configurations.

## 0.3.4

- **Feat: Add project prefixes based on user type.**
  - Project IDs are now automatically prefixed with `tch-` for `teacher` type and `std-` for `student` type.
  - This logic is implemented in `bin/prepare_tf_vars.py`.
  - Added documentation for this feature in `doc/feature-requests/P3-project-prefix-by-type.md`.

## 0.3.3

- **Feat: Add bulk classroom operations to `justfile`.**
  - Introduced `classroom-up-all` to set up all classrooms defined in `etc/samples/`.
  - Introduced `classroom-down-all` to tear down all classrooms defined in `etc/samples/`.

## 0.3.2

- **Chore: Harmonize documentation with `justfile` commands.**
  - Updated all user-facing documentation (`README.md`, `CHANGELOG.md`, `REPORT.md`, etc.) to reflect the new `just classroom-ACTION` command naming convention.
  - `setup-classroom` is now `classroom-up`.
  - `teardown-classroom` is now `classroom-down`.
  - `preflight-check` is now `classroom-inspect`.
  - `setup-sample-class` is now `classroom-up-sampleclass`.
- **Fix: Corrected `classroom-up` script to handle Terraform variable paths correctly.**
  - The `-var-file` argument now uses a relative path, resolving the `terraform apply` failure.
- **Fix: Updated sample classroom YAML to prevent folder name collisions.**
  - The `displayName` in `class_2teachers_6students.yaml` is now unique, preventing "display name uniqueness" errors on subsequent runs.

## 0.3.1

- **Feat: Enhance `REPORT.md` with actionable details.**
  - The generated report is now a complete, user-centric document.
  - It includes both student-centric and project-centric tables for a comprehensive overview.
  - Adds a "Handy Commands" section with direct `just` commands for teardown, setup, and preflight checks for the specific classroom.
  - The "Class Details" section is enriched with the folder name, description, teacher list, and student/project counts.
- **Fix:** Corrected a persistent bug in `setup-classroom.sh` to ensure all classroom artifacts (`tfvars`, `tfoutput`, `log`, `REPORT.md`) are correctly placed in their isolated, multi-tenant workspace directories.

## 0.3.0

- **Success: Successfully provisioned a multi-project classroom.**
  - After extensive debugging of IAM permissions and billing account constraints, the `just setup-sample-class` command now runs to completion.
  - The root cause was a combination of project quotas, billing account organization policies, and fine-grained IAM permissions (`billing.resourceAssociations.create`).
- **Chore: Cleaned up project artifacts.**
  - Removed the obsolete `backup/` directory.
  - Deleted stray `REPORT.md` files, ensuring reports are only generated within their isolated workspace directories.

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
- Supports two distinct workflows: a multi-project classroom setup (CUJ001) and a single-user setup (CUJ002).
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