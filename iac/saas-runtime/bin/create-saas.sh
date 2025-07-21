#!/bin/bash

set -euo pipefail

echo "Creating SaaS instance..."
echo "- PROJECT_ID: $PROJECT_ID"
echo "- GOOGLE_CLOUD_PROJECT: $GOOGLE_CLOUD_PROJECT"
echo "- GOOGLE_CLOUD_REGION: $GOOGLE_CLOUD_REGION"

gcloud beta --project="$PROJECT_ID"  saas-runtime saas create \
    --location="$GOOGLE_CLOUD_REGION" \
    sandmold-saas

