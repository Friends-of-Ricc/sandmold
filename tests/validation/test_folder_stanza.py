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

# tests/validation/test_folder_stanza.py
"""
Validates the 'spec.folder' block of the classroom YAML.
"""

from .common import FOLDER_NAME_REGEX, ENV_VAR_NAME_REGEX

def validate_folder(folder_spec):
    """
    Validates the folder stanza.

    Args:
        folder_spec (dict): The 'folder' dictionary from the spec.

    Returns:
        list: A list of error messages.
    """
    errors = []
    if not isinstance(folder_spec, dict):
        errors.append("'spec.folder' must be a dictionary.")
        return errors

    # --- Check for mandatory fields ---
    mandatory_fields = [
        'org_id', 'domain', 'parent_folder_id', 'billing_account_id',
        'description', 'teachers'
    ]
    for field in mandatory_fields:
        if field not in folder_spec:
            errors.append(f"'spec.folder.{field}' is a required field.")

    # --- Validate data types and formats ---
    if 'displayName' in folder_spec and not FOLDER_NAME_REGEX.match(str(folder_spec['displayName'])):
        errors.append(f"Invalid 'spec.folder.displayName': '{folder_spec['displayName']}'. It contains invalid characters or does not meet length requirements.")

    if 'org_id' in folder_spec and not isinstance(folder_spec['org_id'], int):
         # Accomodating for potential quotes in YAML
        if isinstance(folder_spec['org_id'], str) and not folder_spec['org_id'].isdigit():
            errors.append("'spec.folder.org_id' must be a numeric value.")

    if 'teachers' in folder_spec:
        if not isinstance(folder_spec['teachers'], list) or not folder_spec['teachers']:
            errors.append("'spec.folder.teachers' must be a non-empty list.")
        elif not all(isinstance(email, str) for email in folder_spec['teachers']):
            errors.append("All items in 'spec.folder.teachers' must be strings (emails).")

    # Basic string field validation
    for field in ['domain', 'parent_folder_id', 'billing_account_id', 'description']:
        if field in folder_spec and (not isinstance(folder_spec[field], str) or not folder_spec[field].strip()):
            errors.append(f"'spec.folder.{field}' must be a non-empty string.")

    # --- Validate env list ---
    if 'env' in folder_spec:
        if not isinstance(folder_spec['env'], list):
            errors.append("'spec.folder.env' must be a list.")
        else:
            for i, item in enumerate(folder_spec['env']):
                if not isinstance(item, dict):
                    errors.append(f"Item {i} in 'spec.folder.env' must be a dictionary.")
                    continue
                if 'name' not in item or 'value' not in item:
                    errors.append(f"Item {i} in 'spec.folder.env' must have 'name' and 'value' keys.")
                elif not ENV_VAR_NAME_REGEX.match(str(item.get('name'))):
                    errors.append(f"Item {i} in 'spec.folder.env' has an invalid 'name': '{item.get('name')}'. It must contain only uppercase letters, numbers, and underscores, and start with a letter or underscore.")

    # --- Validate labels list ---
    if 'labels' in folder_spec:
        if not isinstance(folder_spec['labels'], list):
            errors.append("'spec.folder.labels' must be a list.")
        else:
            for i, item in enumerate(folder_spec['labels']):
                if not isinstance(item, dict):
                    errors.append(f"Item {i} in 'spec.folder.labels' must be a dictionary.")
                    continue
                if 'key' not in item or 'value' not in item:
                    errors.append(f"Item {i} in 'spec.folder.labels' must have 'key' and 'value' keys.")

    return errors
