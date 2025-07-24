#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Test Parameters ---
SAAS_NAME="issue30-test"
UNIT_KIND_NAME="issue30-test-uk"
RELEASE_NAME="v0-1-0-$(date +%Y%m%d-%H%M)"
TERRAFORM_MODULE_DIR="terraform-modules/terraform-vm"
INSTANCE_NAME="unit-issue30-test"

echo "
---
STEP 0: Ensuring environment is set up...
---
"
"$(dirname "$0")/00-setup-env.sh"

echo "
---
STEP -1: Cleaning up previous test runs (if any)...
---
"
gcloud beta saas-runtime unit-kinds delete "${UNIT_KIND_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --quiet || true
gcloud beta saas-runtime saas delete "${SAAS_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --quiet || true

echo "🚀 Starting End-to-End SaaS Deployment Test..."

echo "
---
STEP 1: Creating SaaS Offering '${SAAS_NAME}'...
---
"
bin/01-create-saas.sh --saas-name "${SAAS_NAME}"

echo "
---
STEP 2: Creating Unit Kind '${UNIT_KIND_NAME}'...
---
"
bin/02-create-unit-kind.sh --unit-kind-name "${UNIT_KIND_NAME}" --saas-name "${SAAS_NAME}"

echo "
---
STEP 3: Building and Pushing Blueprint from '${TERRAFORM_MODULE_DIR}'...
---
"
bin/03-build-and-push-blueprint.sh --terraform-module-dir "${TERRAFORM_MODULE_DIR}"

echo "
---
STEP 4: Creating Release '${RELEASE_NAME}'...
---
"
bin/04-create-release.sh --release-name "${RELEASE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}" --terraform-module-dir "${TERRAFORM_MODULE_DIR}"

echo "
---
STEP 5: Repositioning Unit Kind Default to '${RELEASE_NAME}'...
---
"
bin/04a-reposition-uk-default.sh --unit-kind-name "${UNIT_KIND_NAME}" --release-name "${RELEASE_NAME}"

echo "
---
STEP 6: Creating Unit '${INSTANCE_NAME}'...
---
"
bin/05-create-unit.sh --instance-name "${INSTANCE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}"

echo "
---
STEP 7: Provisioning Unit '${INSTANCE_NAME}'...
---
"
bin/06-provision-unit.sh --unit-name "unit-${INSTANCE_NAME}" --release-name "${RELEASE_NAME}"

echo "
✅ End-to-End SaaS Deployment Test Complete!"
