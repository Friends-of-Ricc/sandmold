#!/bin/bash
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
