#!/bin/bash

# This script is the "Nuclear Option". It will destroy all SaaS Runtime entities in a given project.
# Use with extreme caution.

set -e

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
  echo "  --confirm         To proceed, you must pass the exact string \"Nuclear launch detected\"."
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
  MATCH="."
fi

if [[ "$CONFIRMATION" != "Nuclear launch detected" ]]; then
  echo "Incorrect confirmation string. Aborting."
  exit 1
fi

echo "The following SaaS Runtime entities will be DELETED in project '$PROJECT_ID' for match string '$MATCH':"
echo "---"
echo "Rollouts:"
gcloud saas-runtime rollouts list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Units:"
gcloud saas-runtime units list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Releases:"
gcloud saas-runtime releases list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Unit Kinds:"
gcloud saas-runtime unit-kinds list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Offerings:"
gcloud saas-runtime offerings list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"
echo "Entitlements:"
gcloud saas-runtime entitlements list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)"
echo "---"

read -p "Are you sure you want to proceed with the deletion? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "Proceeding with deletion..."

# 1. Delete all Rollouts
echo "Deleting Rollouts..."
gcloud saas-runtime rollouts list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud saas-runtime rollouts delete --project "$PROJECT_ID"

# 2. Delete all Units
echo "Deleting Units..."
gcloud saas-runtime units list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud saas-runtime units delete --project "$PROJECT_ID"

# 3. Delete all Releases
echo "Deleting Releases..."
gcloud saas-runtime releases list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud saas-runtime releases delete --project "$PROJECT_ID"

# 4. Delete all Unit Kinds
echo "Deleting Unit Kinds..."
gcloud saas-runtime unit-kinds list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud saas-runtime unit-kinds delete --project "$PROJECT_ID"

# 5. Delete all Offerings
echo "Deleting Offerings..."
gcloud saas-runtime offerings list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud saas-runtime offerings delete --project "$PROJECT_ID"

# 6. Delete all Entitlements
echo "Deleting Entitlements..."
gcloud saas-runtime entitlements list --project "$PROJECT_ID" --filter="name~$MATCH" --format="value(name)" | xargs -r -n 1 gcloud saas-runtime entitlements delete --project "$PROJECT_ID"

echo "All SaaS Runtime entities matching '$MATCH' in project '$PROJECT_ID' have been deleted."
