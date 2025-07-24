# ONE_OFFS.md

This file documents manual steps taken during the development of the SaaS Runtime project that need to be scripted or automated in the future.

## 2025-07-24 - Manual Permissions for `sandmold-tf-actuator`

**Action:** Manually granted the `sandmold-tf-actuator@check-docs-in-go-slash-sredemo.iam.gserviceaccount.com` service account access to GCE, GCS, Cloud Build, and Logging.

**Reason:** The `gcloud beta saas-runtime unit-operations create` command was failing with `PERMISSION_DENIED` errors, indicating the service account lacked necessary permissions for resource provisioning.

## 2025-07-24 - Manual Creation of Artifact Registry `sandmold-saas-registry-v2`

**Action:** Manually created the Docker Artifact Registry `sandmold-saas-registry-v2` in `europe-west2`.

**Reason:** The `bin/03-build-and-push-blueprint.sh` script was failing because the target Artifact Registry did not exist.
