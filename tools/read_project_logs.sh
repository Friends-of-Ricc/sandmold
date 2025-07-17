#!/bin/bash

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
