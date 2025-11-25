#!/bin/bash
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


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
