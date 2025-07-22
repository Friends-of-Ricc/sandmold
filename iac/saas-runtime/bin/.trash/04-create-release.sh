#!/bin/bash

set -euo pipefail

source .env

echo "Creating Release..."

gcloud beta --project="$GOOGLE_CLOUD_PROJECT" saas-runtime releases create v1     --location="$GOOGLE_CLOUD_REGION"     --unit-kind="sandmold-test-vm"     --blueprint-package="gs://$BUCKET_NAME/terraform-files.zip"

