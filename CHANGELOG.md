# Changelog

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