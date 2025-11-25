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


# This script demonstrates how to read logs with a jsonPayload from a specific
# Google Cloud project.

# Usage:
# ./tools/read_project_logs.sh YOUR_PROJECT_ID
#
# Example:
# ./tools/read_project_logs.sh testing-std-p3-a1b2c3d4

if [ -z "$1" ]; then
    echo "Usage: $0 YOUR_PROJECT_ID"
    exit 1
fi

PROJECT_ID=$1

echo "Fetching logs with jsonPayload for project: $PROJECT_ID"
echo "---"

gcloud logging read "jsonPayload.*" --project="$PROJECT_ID"
