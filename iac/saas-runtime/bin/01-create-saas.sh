#!/bin/bash

set -euo pipefail

echo "Creating SaaS instance..."
#echo "- PROJECT_ID: $PROJECT_ID"
echo "- GOOGLE_CLOUD_PROJECT: $GOOGLE_CLOUD_PROJECT"
echo "- GOOGLE_CLOUD_REGION: $GOOGLE_CLOUD_REGION"

gcloud beta --project="$GOOGLE_CLOUD_PROJECT"  saas-runtime saas create     --location="$GOOGLE_CLOUD_REGION"     --locations="name=$GOOGLE_CLOUD_REGION"     sandmold-saas ||     (gcloud beta --project="$GOOGLE_CLOUD_PROJECT" saas-runtime saas describe sandmold-saas --location="$GOOGLE_CLOUD_REGION" && echo "SaaS instance already exists, skipping creation.")

echo "Creating Artifact Registry..."

gcloud artifacts repositories create "$ARTIFACT_REGISTRY_NAME"     --project="$GOOGLE_CLOUD_PROJECT"     --repository-format=docker     --location="$GOOGLE_CLOUD_REGION"     --description="SaaS Runtime Blueprints" ||     (gcloud artifacts repositories describe "$ARTIFACT_REGISTRY_NAME" --project="$GOOGLE_CLOUD_PROJECT" --location="$GOOGLE_CLOUD_REGION" && echo "Artifact Registry already exists, skipping creation.")

