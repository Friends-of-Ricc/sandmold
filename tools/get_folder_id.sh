#!/bin/bash

# This script finds a GCP folder ID by its display name within the organization
# specified in the .env file. It searches the entire folder hierarchy.
# All output except for the final folder ID is redirected to stderr.

set -euo pipefail

# Load environment variables from the .env file located at the project root.
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="${SCRIPT_DIR}/.."
ENV_FILE="${PROJECT_ROOT}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    echo "Error: .env file not found at ${ENV_FILE}" >&2
    exit 1
fi

# Source the .env file to get the ORGANIZATION_ID
source "${ENV_FILE}"

# Check if a folder name is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <folder_display_name>" >&2
  exit 1
fi

FOLDER_NAME="$1"

# Check if ORGANIZATION_ID is set
if [ -z "${ORGANIZATION_ID}" ]; then
    echo "Error: ORGANIZATION_ID is not set in the .env file." >&2
    exit 1
fi

# Check if GOOGLE_CLOUD_PROJECT is set, as it's required for the asset search
if [ -z "${GOOGLE_CLOUD_PROJECT:-}" ]; then
    echo "Error: GOOGLE_CLOUD_PROJECT is not set in the .env file." >&2
    echo "This is required for 'gcloud asset search-all-resources' to work." >&2
    exit 1
fi

echo "Searching for folder with display name '${FOLDER_NAME}' under organization '${ORGANIZATION_ID}'..." >&2

# Use gcloud to find the folder ID by searching the entire hierarchy
# Redirect gcloud's stderr to our stderr to not pollute our output
FOLDER_ID=$(gcloud resource-manager folders list \
  --organization="${ORGANIZATION_ID}" \
  --filter="displayName=${FOLDER_NAME}" \
  --format="value(name)" 2>/dev/null)

if [ -z "${FOLDER_ID}" ]; then
  echo "Folder not found at the top level. Searching recursively..." >&2
  # If not found at the top level, we might need a more complex search.
  # A more advanced script could use `gcloud asset search-all-resources`.
  # Let's try to search all resources for the folder.
  FOLDER_ID=$(gcloud asset search-all-resources \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --scope="organizations/${ORGANIZATION_ID}" \
    --asset-types="cloudresourcemanager.googleapis.com/Folder" \
    --query="displayName=${FOLDER_NAME}" \
    --format="value(name)" 2>/dev/null | head -n 1)
fi


if [ -z "${FOLDER_ID}" ]; then
  echo "Folder not found." >&2
  exit 1
fi

# The output from asset search is the full resource name, like "//cloudresourcemanager.googleapis.com/folders/12345"
# We need to extract just the "folders/12345" part.
CLEAN_FOLDER_ID=$(echo "${FOLDER_ID}" | sed 's|//cloudresourcemanager.googleapis.com/||')

# The final output is the folder ID to stdout
echo "${CLEAN_FOLDER_ID}"
