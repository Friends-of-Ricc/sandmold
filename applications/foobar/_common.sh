#!/usr/bin/env bash
# This script is not meant to be executed directly.
# It is a library of common functions sourced by other scripts.

set -e

# Function to check for required environment variables.
# It reads the variable names from the blueprint.yaml file.
check_env_vars() {
    # Get the directory of the calling script to find the blueprint.
    local SCRIPT_DIR
    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

    local BLUEPRINT_FILE="${SCRIPT_DIR}/blueprint.yaml"

    if [ ! -f "$BLUEPRINT_FILE" ]; then
        echo "Error: blueprint.yaml not found in ${SCRIPT_DIR}" >&2
        exit 1
    fi

    # Read variable names from the blueprint using yq
    local REQUIRED_VARS
    REQUIRED_VARS=$(yq -r '.spec.variables[].name' "$BLUEPRINT_FILE")

    echo "--- Checking Environment Variables ---"
    for var in $REQUIRED_VARS; do
        if [ -z "${!var}" ]; then
            echo "❌ Error: Required environment variable '${var}' is not set." >&2
            exit 1
        else
            # Use a simple echo for the default case.
            echo "✅ ${var}=${!var}"
        fi
    done
    echo "------------------------------------"
}

# Function to write a structured JSON log to Google Cloud Logging.
# Arguments:
#   $1: The verb (e.g., "start", "stop", "status").
#   $2: The log message string.
log_to_gcp() {
    local SCRIPT_DIR
    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

    local BLUEPRINT_FILE="${SCRIPT_DIR}/blueprint.yaml"
    local APP_NAME
    APP_NAME=$(yq -r '.metadata.name' "$BLUEPRINT_FILE")
    local LOG_NAME="${APP_NAME}-log"
    local VERB="$1"
    local MESSAGE="$2"
    local CALLER_IDENTITY
    CALLER_IDENTITY=$(gcloud config get-value account)

    # Construct the ENV JSON object
    local ENV_JSON=""
    local REQUIRED_VARS
    REQUIRED_VARS=$(yq -r '.spec.variables[].name' "$BLUEPRINT_FILE")
    for var in $REQUIRED_VARS; do
        ENV_JSON="${ENV_JSON}\"${var}\":\"${!var}\","
    done
    # Remove trailing comma
    ENV_JSON="{${ENV_JSON%,}}"

    # Construct the JSON payload
    JSON_PAYLOAD=$(cat <<EOF
{
  "framework": "sandmold/v1.0",
  "appname": "${APP_NAME}",
  "appverb": "${VERB}",
  "caller_identity": "${CALLER_IDENTITY}",
  "message": "${MESSAGE}",
  "note_for_googlers": "For more info, check go/sandmold or ping ricc@ . Code currently in: https://github.com/Friends-of-Ricc/sandmold",
  "ENV": ${ENV_JSON}
}
EOF
)

    echo "Logging to GCP: ${JSON_PAYLOAD}"
    gcloud logging write "${LOG_NAME}" "${JSON_PAYLOAD}" --payload-type=json --project="${GOOGLE_CLOUD_PROJECT}"
}
