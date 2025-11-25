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

# tests/validation/test_spec.py
"""
Orchestrates the validation of the 'spec' block of the classroom YAML.
"""

from .test_folder_stanza import validate_folder
from .test_schoolbenches_stanza import validate_schoolbenches
from .test_common_stanza import validate_common

def validate_spec(spec, legal_apps):
    """
    Validates the 'spec' block by calling specialized validators.

    Args:
        spec (dict): The 'spec' dictionary from the loaded YAML.

    Returns:
        list: A list of error messages.
    """
    errors = []

    # --- Validate spec.folder ---
    folder_spec = spec.get('folder')
    if not folder_spec:
        errors.append("'spec.folder' is a required field.")
    else:
        errors.extend(validate_folder(folder_spec))

    # --- Validate spec.schoolbenches ---
    schoolbenches_spec = spec.get('schoolbenches')
    if not schoolbenches_spec:
        errors.append("'spec.schoolbenches' is a required field.")
    else:
        errors.extend(validate_schoolbenches(schoolbenches_spec, legal_apps))

    # --- Validate spec.common (optional) ---
    common_spec = spec.get('common')
    if common_spec:
        errors.extend(validate_common(common_spec))

    return errors
