#!/bin/bash
#
# Checks the status of all SaaS Runtime resources.
#

set -euo pipefail

source .env

echo -e "\n\033[0;36m🚀 Listing SaaS Offerings:\033[0m"
gcloud beta saas-runtime saas list --format="value(name,createTime,updateTime)" --location=$GOOGLE_CLOUD_REGION

echo -e "\n\033[0;36m🧩 Listing Unit Kinds:\033[0m"
gcloud beta saas-runtime unit-kinds list --format="value(name,saas,defaultRelease)" --location="${GOOGLE_CLOUD_REGION}"

echo -e "\n\033[0;36m🖼️  Listing Blueprints in Artifact Registry (filtered by 'blueprint'):\033[0m"
if gcloud artifacts repositories describe "${ARTIFACT_REGISTRY_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    gcloud artifacts docker images list "${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}" --filter="IMAGE~blueprint" --format="value(IMAGE,DIGEST,CREATE_TIME,SIZE)" 2>/dev/null
else
    echo "Artifact Registry '${ARTIFACT_REGISTRY_NAME}' not found."
fi

echo -e "\n\033[0;36m📦 Listing Units:\033[0m"
gcloud beta saas-runtime units list \
    --location="${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --format="value(name,unitKind,state)" || true

echo -e "\n\033[0;36m🏷️  Listing Releases:\033[0m"
gcloud beta saas-runtime releases list --format="value(name,unitKind,blueprintPackage)" --location="${GOOGLE_CLOUD_REGION}"

echo -e "\n\033[0;36m🖥️  Listing Compute Engine VMs (no filter applied):\033[0m"
gcloud compute instances list --format="value(name,zone,status,networkInterfaces[0].accessConfigs[0].natIP)" --project="${GOOGLE_CLOUD_PROJECT}"