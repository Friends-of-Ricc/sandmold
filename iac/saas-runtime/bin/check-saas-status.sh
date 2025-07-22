#!/bin/bash
#
# Checks the status of all SaaS Runtime resources.
#

set -euo pipefail

source .envrc

echo -e "\n\033[0;36m🗂️  Current Project Config:\033[0m"
gcloud config list 2>/dev/null | egrep "account =|project ="

echo -e "\n\033[0;36m🚀 Listing SaaS Offerings (filtered by 'sandmold'):\033[0m"
gcloud beta saas-runtime saas list --filter="name~sandmold" --format="value(name,createTime,updateTime)" --location=global

echo -e "\n\033[0;36m🧩 Listing Unit Kinds (filtered by 'sandmold'):\033[0m"
gcloud beta saas-runtime unit-kinds list --filter="name~sandmold" --format="value(name,saas,defaultRelease)" --location=global

echo -e "\n\033[0;36m🖼️  Listing Blueprints in Artifact Registry (filtered by 'blueprint'):\033[0m"
gcloud artifacts docker images list "${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}" --filter="IMAGE~blueprint" --format="value(IMAGE,DIGEST,CREATE_TIME,SIZE)" |
    grep "sha256"

echo -e "
\033[0;36m📦 Listing Units (filtered by 'sandmold'):\033[0m"
gcloud beta saas-runtime units list --format="value(name,unitKind,state)" --location=global
gcloud beta saas-runtime units list --format="value(name,unitKind,state)" --location="${GOOGLE_CLOUD_REGION}"

echo -e "\n\033[0;36m🏷️  Listing Releases (filtered by 'v'):\033[0m"
gcloud beta saas-runtime releases list --filter="name~v" --format="value(name,unitKind,blueprintPackage)" --location=global

