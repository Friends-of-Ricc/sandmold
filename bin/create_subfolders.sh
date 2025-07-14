#!/bin/bash

# Set the parent folder ID
PARENT_FOLDER="1000371719973"

# Get the display name of the parent folder
PARENT_FOLDER_NAME=$(gcloud resource-manager folders describe "$PARENT_FOLDER" --format="value(displayName)")

echo "Parent folder name is: $PARENT_FOLDER_NAME"
echo "Creating 5 subfolders under parent folder $PARENT_FOLDER ($PARENT_FOLDER_NAME)..."

for i in {1..5}
do
  gcloud resource-manager folders create \
    --display-name="test-sandmold-$i" \
    --folder="$PARENT_FOLDER"
done

echo "Script finished."
