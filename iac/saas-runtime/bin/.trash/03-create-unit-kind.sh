#!/bin/bash

set -euo pipefail

# This script creates a new unit kind in the SaaS Runtime.
# It takes the unit kind name and the path to the terraform code as arguments.

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <unit-kind-name> <path-to-terraform-directory>"
  exit 1
fi

UNIT_KIND_NAME=$1
TERRAFORM_DIR=$2
RELEASE_NAME="v1"

# Build and push the blueprint image.
BLUEPRINT_IMAGE=$(bin/05-build-and-push-blueprint.sh "$TERRAFORM_DIR")

# Create the release.
echo "Creating release: $RELEASE_NAME for unit kind: $UNIT_KIND_NAME"
gcloud alpha saas-runtime releases create "$RELEASE_NAME" \
  --unit-kind="$UNIT_KIND_NAME" \
  --blueprint-package="$BLUEPRINT_IMAGE" \
  --location=us-central1

# Create the unit kind.
echo "Creating unit kind: $UNIT_KIND_NAME"
gcloud alpha saas-runtime unit-kinds create "$UNIT_KIND_NAME" \
  --default-release="$RELEASE_NAME" \
  --location=us-central1

# Grant the current user owner permissions on the new unit kind.
echo "Granting owner permissions to $(gcloud config get-value account)"
gcloud alpha saas-runtime unit-kinds add-iam-policy-binding "$UNIT_KIND_NAME" \
  --role="roles/owner" \
  --member="user:$(gcloud config get-value account)" \
  --location=us-central1