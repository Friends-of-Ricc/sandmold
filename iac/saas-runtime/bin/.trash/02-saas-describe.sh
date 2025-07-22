#!/bin/bash

set -euo pipefail

source .env

echo "Checking SaaS instance..."

gcloud beta --project="$GOOGLE_CLOUD_PROJECT" saas-runtime saas describe \
    --location="$GOOGLE_CLOUD_REGION" \
    sandmold-saas

