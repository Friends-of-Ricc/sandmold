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

# tests/validation/common.py
"""
This module contains common constants, regular expressions, and helper functions
for the classroom YAML validation suite.
"""

import re

# --- Regex Patterns for Validation ---

# Allows lowercase letters, numbers, and hyphens.
# Must start with a letter, be between 6 and 30 chars, and not end with a hyphen.
# See: https://cloud.google.com/resource-manager/reference/rest/v1/projects#resource:-project
GCP_PROJECT_ID_REGEX = re.compile(r"^[a-z][a-z0-9-]{4,28}[a-z0-9]$")

# A relaxed regex for folder display names. Allows most characters, 3-30 length.
FOLDER_NAME_REGEX = re.compile(r"^.{3,30}$")

# A relaxed regex for workspace names (metadata.name).
# Allows letters, numbers, hyphens, and underscores.
WORKSPACE_NAME_REGEX = re.compile(r"^[a-zA-Z0-9_-]+$")

# Allows uppercase letters, numbers, and underscores. Must start with a letter or underscore.
ENV_VAR_NAME_REGEX = re.compile(r"^[A-Z_][A-Z0-9_]*$")

# --- ANSI Color and Style Codes ---
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    ENDC = '\033[0m'

# --- Emojis / Symbols ---
SUCCESS_SYMBOL = "✅"
FAILURE_SYMBOL = "❌"
VALIDATING_SYMBOL = "💾"
