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


set -euo pipefail

# This script builds a blueprint container image and pushes it to Google Artifact Registry.
# It takes the path to the blueprint's source code as an argument.

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-blueprint-source>"
  exit 1
fi

# Convert the relative path to an absolute path
BLUEPRINT_SOURCE_DIR="$(pwd)/$1"

# Extract the blueprint name from the source directory path.
BLUEPRINT_NAME=$(basename "$BLUEPRINT_SOURCE_DIR")

# Get the project ID from the gcloud config.
PROJECT_ID=$(gcloud config get-value project)

# Construct the image name.
IMAGE_NAME="us-central1-docker.pkg.dev/$PROJECT_ID/sandmold-saas-blueprints/$BLUEPRINT_NAME:v1"

# Build and push the image.
echo "Building and pushing blueprint image: $IMAGE_NAME" >&2
docker buildx build -t "$IMAGE_NAME" --platform linux/amd64 --label "dev.cloud.saas.engine.type=terraform" --label "dev.cloud.saas.engine.version=1.5.7" "$BLUEPRINT_SOURCE_DIR" --push

# Return the image name.
echo "$IMAGE_NAME"
