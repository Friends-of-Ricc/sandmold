# Current Plan and Status

## Overall Goal
Transition from Artifact Registry Docker images for SaaS Runtime blueprints to GCS-based ZIP files processed by Cloud Build. This aims to resolve persistent "manifest digest mismatch" errors and streamline the blueprint deployment process.

## Current Status
Blocked by `gsutil` reauthentication issues during the execution of `bin/00-setup-env.sh`. The `gsutil mb` command fails with `Reauthentication challenge could not be answered because you are not in an interactive session.` This is preventing the creation of the dedicated GCS bucket for Terraform blueprints.

## Detailed Plan

### Phase 1: Setup GCS-based Blueprint Workflow

1.  **Revert `bin/04-create-release.sh`:** (Done)
    *   Reverted to a simplified state, as it will be updated to point to GCS-based blueprints.

2.  **Modify `bin/00-setup-env.sh`:** (In Progress - Blocked by `gsutil` auth)
    *   Create a new GCS bucket for Terraform blueprints (`sandmold-tf-blueprints-<project_id>`).
    *   Grant the `sandmold-tf-actuator` service account `roles/storage.objectAdmin` on this new bucket.

3.  **Modify `bin/03-build-and-push-blueprint.sh`:** (Pending `00-setup-env.sh` completion)
    *   Remove the Docker image build and push logic.
    *   Add logic to create a ZIP archive of the Terraform module.
    *   Upload this ZIP to the `TF_BLUEPRINT_BUCKET`, using a path like `gs://<bucket_name>/<module_name>/<module_name>.zip`.
    *   Generate a `cloudbuild.yaml` dynamically within the build directory. This `cloudbuild.yaml` will trigger the Infra Manager deployment from the GCS ZIP.
    *   The generated `cloudbuild.yaml` will include `echo DEBUG` and `find .` debug commands.

4.  **Modify `bin/04-create-release.sh`:** (Pending `00-setup-env.sh` and `03-build-and-push-blueprint.sh` completion)
    *   Update the `--blueprint-package` argument to point to the GCS path (`gs://${TF_BLUEPRINT_BUCKET}/${TERRAFORM_MODULE_DIR_BASENAME}/${TERRAFORM_MODULE_DIR_BASENAME}.zip`).

5.  **Update `GCLI_FRICTION_LOD.md`:** (Done)
    *   Documented the `gsutil` reauthentication issue.

### Phase 2: Create and Provision Releases (After GCS Setup)

1.  **Create the `sample-vm-v1-0-2-global` release:** (Blocked)
2.  **Update the global Unit Kind's default release:** (Blocked)
3.  **Create the `sample-vm-v1-0-2-regional` release:** (Blocked)
4.  **Update the regional Unit Kind's default release:** (Blocked)
5.  **Verify all releases and unit kind defaults:** (Blocked)
6.  **Attempt provisioning a new unit:** (Blocked)

## Next Steps

User to manually resolve the `gsutil` reauthentication issue. Once resolved, I will re-run `bin/00-setup-env.sh` to complete the GCS bucket setup.
