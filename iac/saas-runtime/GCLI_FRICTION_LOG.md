## GCLI Friction Log

## Friction

*   **API Immaturity**: The SaaS Runtime APIs are quite new, so expect elements of friction. This includes unexpected behavior, unclear error messages, or undocumented requirements.
*   **Cleanup Complexity**: Deleting resources (Units, Releases, Unit Kinds, SaaS Offerings) requires a precise sequence and often involves timing considerations (e.g., delays for deprovisioning to complete). This can lead to `INVALID_ARGUMENT` errors if dependencies are not fully resolved before deletion attempts.

### Manifest Digest Mismatch Error (2025-07-22 15:33:00 UTC)

**Context:**
Attempting to create a SaaS Runtime Release (`sample-vm-v1-0-2-global`) for a blueprint (`terraform-vm-blueprint`) after rebuilding and pushing the blueprint image with a new tag (`sample-vm-1753198957`). The `04-create-release.sh` script was modified to use the `IMAGE_URI` directly, and then to use the explicit digest of the image.

**Error Message:**
```
ERROR: (gcloud.beta.saas-runtime.releases.create) INVALID_ARGUMENT: invalid argument unable to read annotations from OCI image, error: manifest digest: "sha256:..." does not match requested digest: "sha256:..." for "global-docker.pkg.dev/..."
```

**Analysis:**
This error is highly persistent and suggests a fundamental issue with how the SaaS Runtime service is resolving or caching blueprint image references from Artifact Registry. Despite ensuring the blueprint is pushed with the correct tags and attempting to reference it by direct URI and explicit digest, the service consistently reports a digest mismatch. This is preventing the creation of the `1-0-2` release.

### gsutil Reauthentication Issue (2025-07-23 06:05:00 UTC)

**Context:**
During the execution of `bin/00-setup-env.sh` (which includes `gsutil mb` commands for creating a GCS bucket), the `gsutil` command consistently fails with a reauthentication error. This occurs even after successful `gcloud auth login` and `gcloud auth application-default login` commands are run by the user.

**Error Message:**
```
google_reauth.errors.ReauthUnattendedError: Reauthentication challenge could not be answered because you are not in an interactive session.
```

**Analysis:**
This indicates that `gsutil` is unable to use the existing application default credentials in a non-interactive script environment, or that the credentials are expiring too quickly for the script's duration. The user also noted `gsutil` prompting for a password, which is unusual for `application-default` credentials and suggests a deeper configuration or environment issue with `gsutil`'s credential handling. This is currently blocking the setup of the GCS bucket for the new blueprint workflow.

### Transition to GCS-based Blueprints (2025-07-23 06:05:00 UTC)

**Context:**
Due to persistent "manifest digest mismatch" errors with Artifact Registry-based blueprints, the workflow is being transitioned to use GCS-based ZIP files for Terraform blueprints. This involves modifying `bin/03-build-and-push-blueprint.sh` to create and upload ZIP archives to a dedicated GCS bucket, and `bin/04-create-release.sh` to reference these GCS paths.

**Impact:**
This change is expected to resolve the blueprint resolution issues and allow for successful release creation and unit provisioning.
