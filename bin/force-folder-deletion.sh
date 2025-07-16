#!/usr/bin/env bash
set -e

# for automation, call with NUCLEAR_LAUNCH_DETECTED"="Yes I am sure" but beware of what you do!
# This script deletes a Google Cloud folder and all projects within it and it was implemented as a "nuclear option" for
# Terraform hard-to-follow Change Management.

FOLDER_ID="$1"

if [ -z "$FOLDER_ID" ]; then
    echo "Usage: $0 <folder_id>"
    exit 1
fi

echo "--- Preparing to delete folder ${FOLDER_ID} and all its contents. ---"
echo "--- This is a destructive operation and cannot be undone. ---"

echo ""
echo "The following projects will be PERMANENTLY DELETED:"
PROJECTS=$(gcloud projects list --filter="parent.id=${FOLDER_ID}" --format="value(project_id)")

if [ -z "$PROJECTS" ]; then
    echo "No projects found in folder ${FOLDER_ID}."
else
    echo "$PROJECTS"
fi
echo ""

if [ "$NUCLEAR_LAUNCH_DETECTED" != "Yes I am sure" ]; then
    read -p "To confirm, please type 'yes I am sure': " CONFIRMATION
    if [ "$CONFIRMATION" != "yes I am sure" ]; then
        echo "Confirmation failed. Aborting."
        exit 1
    fi
fi

echo "--- Proceeding with deletion... ---"

if [ -z "$PROJECTS" ]; then
    echo "No projects to delete."
else
    echo "$PROJECTS" | while read -r PROJECT_ID; do
        echo "--- Preparing to delete project ${PROJECT_ID} ---"

        echo "--> Removing any liens on project ${PROJECT_ID}..."
        gcloud alpha resource-manager liens list --project "${PROJECT_ID}" --format="value(name)" | xargs -r -I '{}' gcloud alpha resource-manager liens delete '{}' --project "${PROJECT_ID}"

        echo "--> Deleting project ${PROJECT_ID}..."
        gcloud projects delete "${PROJECT_ID}" --quiet
    done
fi

echo "--- Deleting folder ${FOLDER_ID} ---"
gcloud resource-manager folders delete "${FOLDER_ID}" --quiet

echo "--- ✅ Nuclear option complete. All specified resources have been deleted. ---"

