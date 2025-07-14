#!/bin/bash

# This script grants permissions to a user for a specific folder hierarchy.

# --- Configuration ---
ORGANIZATION_ID="791852209422"
PARENT_FOLDER_ID="1000371719973"
USER_EMAIL="leoy@google.com"
SUBFOLDER_NAME_PATTERN="test-sandmold-leoy-"

# --- Step 1: Grant Viewer and Browser roles on the organization ---
echo "Granting Viewer and Browser roles on organization $ORGANIZATION_ID to $USER_EMAIL..."
gcloud organizations add-iam-policy-binding "$ORGANIZATION_ID" --member="user:$USER_EMAIL" --role="roles/viewer" > /dev/null
gcloud organizations add-iam-policy-binding "$ORGANIZATION_ID" --member="user:$USER_EMAIL" --role="roles/browser" > /dev/null
echo "Done."
echo

# --- Step 2: Grant Viewer and Browser roles on the parent folder ---
echo "Granting Viewer and Browser roles on parent folder $PARENT_FOLDER_ID to $USER_EMAIL..."
gcloud resource-manager folders add-iam-policy-binding "$PARENT_FOLDER_ID" --member="user:$USER_EMAIL" --role="roles/viewer" > /dev/null
gcloud resource-manager folders add-iam-policy-binding "$PARENT_FOLDER_ID" --member="user:$USER_EMAIL" --role="roles/browser" > /dev/null
echo "Done."
echo

# --- Step 3: Grant Folder Admin role on specific subfolders ---
echo "Finding subfolders matching '$SUBFOLDER_NAME_PATTERN'..."
SUBFOLDER_IDS=$(gcloud resource-manager folders list --folder="$PARENT_FOLDER_ID" --filter="displayName~$SUBFOLDER_NAME_PATTERN" --format="value(ID)")

if [ -z "$SUBFOLDER_IDS" ]; then
  echo "No subfolders found matching the pattern '$SUBFOLDER_NAME_PATTERN'."
  exit 1
fi

echo "Found subfolders. Granting Folder Admin role to $USER_EMAIL..."
for FOLDER_ID in $SUBFOLDER_IDS; do
  FOLDER_NAME=$(gcloud resource-manager folders describe "$FOLDER_ID" --format="value(displayName)")
  echo "  - Granting admin on folder $FOLDER_ID ($FOLDER_NAME)..."
  gcloud resource-manager folders add-iam-policy-binding "$FOLDER_ID" --member="user:$USER_EMAIL" --role="roles/resourcemanager.folderAdmin" > /dev/null
done

echo
echo "All permissions have been granted successfully."
