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
log_to_gcp "stop" "Application stop sequence initiated."

echo "✅ Foobar app 'stopped' (logged to GCP)."
