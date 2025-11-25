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

# This script deletes a list of Google Cloud projects.

# Example:  │   bin/force-project-deletion.sh boa01-rrww boa02-ruva boa03-dutz                                       │
set -e

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <project_id_1> <project_id_2> ..."
    exit 1
fi

for project_id in "$@"; do
    echo "Deleting project: ${project_id}"
    gcloud projects delete "${project_id}" --quiet
done

echo "All specified projects have been deleted."
