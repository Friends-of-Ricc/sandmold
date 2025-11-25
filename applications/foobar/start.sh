#!/usr/bin/env bash
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

set -e

# Source the common script
source "$(dirname "$0")/../_common.sh"

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


