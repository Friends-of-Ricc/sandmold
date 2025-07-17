#!/usr/bin/env bash
set -e

# Source the common script
source "$(dirname "$0")/_common.sh"

# Ensure required environment variables are set
check_env_vars

# Log the action to Google Cloud Logging
log_to_gcp "start" "Application start sequence initiated."

# Proper install execution. If AUTO_FAIL=='omega13', fail the install.
if [[ "${AUTO_FAIL}" == "omega13" ]]; then
    log_to_gcp "install::fail" "Application start failed due to AUTO_FAIL condition."
    echo "❌ Foobar app 'start' failed due to AUTO_FAIL condition."
    exit 13
else
    # All good instead. Simluating work with sleep
    sleep "${SLEEP_TIME}"
    log_to_gcp "install::success" "Application correctly installed."
    echo "✅ Foobar app 'started' (logged to GCP)."
    exit 0
fi


