# Plan for Issue #30: Refactoring and Verification

This document outlines the steps to refactor and verify the SaaS Runtime scripts. The goal is to ensure the scripts are robust, reusable, and fully functional before committing any changes.

## Phase 1: Script Refactoring & Configuration

- [ ] **Configuration Handling:**
    - [ ] Scripts will continue to `source .env` to load project-level constants.
    - [ ] I, the agent, **will not modify** the `.env` file.
    - [ ] All dynamic, offering-specific values (e.g., SaaS Name, Release Name) will be passed exclusively via named command-line arguments.
- [ ] **Create a dedicated E2E test script:**
    - [ ] Create a new script `bin/run-e2e-test.sh`.
    - [ ] This script will contain the full end-to-end workflow logic.
    - [ ] This script **must** start with `set -euo pipefail` to ensure it exits on any error.
    - [ ] The `justfile`'s `deploy-saas-end2end` target will be simplified to call this new script.
- [ ] **Verify all scripts correctly parse named arguments and source `.env` for constants.**

## Phase 2: End-to-End Verification

The following steps will be executed sequentially by the new `run-e2e-test.sh` script to test the entire workflow. Each step must succeed before proceeding to the next.

**Test Parameters:**
*   **SaaS Name:** `issue30-test`
*   **Terraform Module:** `terraform-modules/terraform-vm`
*   **Release Name:** `v0.1.0` (or similar)
*   **Unit Name:** `unit-issue30-test`

**Checklist:**

- [x] **1. Create SaaS Offering:**
    - [x] Command: `bin/01-create-saas.sh --saas-name "issue30-test"`
    - [x] Verification: Check for successful creation in the Google Cloud Console or via `gcloud`.
- [x] **2. Create Unit Kind:**
    - [x] Command: `bin/02-create-unit-kind.sh --unit-kind-name "issue30-test-uk" --saas-name "issue30-test"`
    - [x] Verification: Check for successful creation.
- [x] **3. Build and Push Blueprint:**
    - [x] Command: `bin/03-build-and-push-blueprint.sh --terraform-module-dir "terraform-modules/terraform-vm"`
    - [x] Verification: Check for a successful Cloud Build run and the blueprint image in Artifact Registry.
- [x] **4. Create Release:**
    - [x] Command: `bin/04-create-release.sh --release-name "v0.1.0" --unit-kind-name "issue30-test-uk" --terraform-module-dir "terraform-modules/terraform-vm"`
    - [x] Verification: Check for the new release associated with the unit kind.
- [x] **5. Reposition Unit Kind Default Release:**
    - [x] Command: `bin/04a-reposition-uk-default.sh --unit-kind-name "issue30-test-uk" --release-name "v0.1.0"`
    - [x] Verification: Check that the unit kind's default release is updated.
- [x] **6. Create Unit:**
    - [x] Command: `bin/05-create-unit.sh --instance-name "unit-issue30-test" --unit-kind-name "issue30-test-uk"`
    - [x] Verification: Check that the unit is created in a `NOT_PROVISIONED` state.
- [x] **7. Provision Unit:**
    - [x] Command: `bin/06-provision-unit.sh --unit-name "unit-issue30-test" --release-name "v0.1.0"`
    - [x] Verification: Check that the unit transitions to a `READY` state and the underlying VM is created.

## Phase 3: Finalization

- [ ] **Update `justfile`:** Ensure the `deploy-saas-end2end` target works with the refactored scripts.
- [ ] **Commit Changes:** Once all verification steps pass, commit the working code.
- [ ] **Update GitHub Issue:** Comment on issue #30 with the results of the verification.
