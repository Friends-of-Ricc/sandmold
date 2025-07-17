#!/usr/bin/env bash
set -e

# Source the common script
source "$(dirname "$0")/_common.sh"

# Ensure required environment variables are set
check_env_vars

# Log the action to Google Cloud Logging
log_to_gcp "start" "Application start sequence initiated."

echo "✅ Foobar app 'started' (logged to GCP)."
