#!/bin/bash

# This script is the "Nuclear Option". It will destroy all SaaS Runtime entities in a given project.
# Use with extreme caution.
# From https://github.com/Friends-of-Ricc/sandmold/issues/26 in order it should do this:
# 1. Delete Units
# 2. Update UK to clear default release
# 3. delete Releases
# 4. delete UKs
# 5. delete SaaS Runtimes
# 6. Check its actually cleaned up with some gcloud getters.

set -e
set -x # Enable debugging

# --- Configuration ---
PROJECT_ID=""
MATCH=""
CONFIRMATION=""

# --- Functions ---
usage() {
  echo "Usage: $0 --project_id <PROJECT_ID> [--match <MATCH_STRING>] --confirm <CONFIRMATION>"
  echo ""
  echo "This script deletes all SaaS Runtime entities in a project that match a given string."
  echo "If --match is not provided, it will delete ALL entities."
  echo ""
  echo "Arguments:"
  echo "  --project_id      The GCP project ID."
  echo "  --match           A string to match against the names of the entities to delete. Defaults to all entities if not provided."
  echo "  --confirm         To proceed, you must pass the exact string 'Nuclear launch detected'."
  exit 1
}

# --- Main ---
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --project_id)
      PROJECT_ID="$2"
      shift
      shift
      ;;
    --match)
      MATCH="$2"
      shift
      shift
      ;;
    --confirm)
      CONFIRMATION="$2"
      shift
      shift
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$PROJECT_ID" || -z "$CONFIRMATION" ]]; then
  usage
fi

if [[ -z "$MATCH" ]]; then
  echo "No --match string provided. Defaulting to match ALL resources."
  MATCH=".*"
fi

if [[ "$CONFIRMATION" != "Nuclear launch detected" ]]; then
  echo "Incorrect confirmation string. Aborting."
  exit 1
fi

echo "TODO: This script does not yet delete tenants, rollouts, or rollout-kinds."
echo "The following SaaS Runtime entities will be DELETED in project '$PROJECT_ID' for match string '$MATCH':"
echo "---"
echo "SaaS Instances:"
gcloud beta saas-runtime saas list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Units:"
gcloud beta saas-runtime units list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Releases:"
gcloud beta saas-runtime releases list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Unit Kinds:"
gcloud beta saas-runtime unit-kinds list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"




echo "Proceeding with deletion..."

# Deletion Order:
# 1. Delete Units
# 2. Update UK to clear default release
# 3. delete Releases
# 4. delete UKs
# 5. delete SaaS Runtimes

echo "Deleting Units..."
gcloud beta saas-runtime units list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud beta saas-runtime units delete --project "$PROJECT_ID" --quiet

echo "Updating Unit Kinds to clear default release..."
for uk in $(gcloud beta saas-runtime unit-kinds list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"); do
  gcloud beta saas-runtime unit-kinds update $uk --project "$PROJECT_ID" --clear-default-release --quiet
done

echo "Deleting Releases..."
gcloud beta saas-runtime releases list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud beta saas-runtime releases delete --project "$PROJECT_ID" --quiet

echo "Deleting Unit Kinds..."
gcloud beta saas-runtime unit-kinds list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud beta saas-runtime unit-kinds delete --project "$PROJECT_ID" --quiet

echo "Deleting SaaS Instances..."
gcloud beta saas-runtime saas list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud beta saas-runtime saas delete --project "$PROJECT_ID" --quiet

echo "All targeted SaaS Runtime entities matching '$MATCH' in project '$PROJECT_ID' have been deleted."

echo "Verifying cleanup..."
echo "---"
echo "SaaS Instances:"
gcloud beta saas-runtime saas list --project "$PROJECT_ID" --format="value(name)"
echo "---"
echo "Units:"
gcloud beta saas-runtime units list --project "$PROJECT_ID" --format="value(name)"
echo "---"
echo "Releases:"
gcloud beta saas-runtime releases list --project "$PROJECT_ID" --format="value(name)"
echo "---"
echo "Unit Kinds:"
gcloud beta saas-runtime unit-kinds list --project "$PROJECT_ID" --format="value(name)"
echo "---"
echo "Cleanup verification complete."
