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

# tests/validation/test_root.py
"""
Validates the root structure of the classroom YAML, including apiVersion,
kind, metadata, and the presence of a spec.
"""

from .common import WORKSPACE_NAME_REGEX
from .test_spec import validate_spec

def validate_root(config, legal_apps):
    """
    Validates the entire classroom configuration object.

    Args:
        config (dict): The loaded YAML configuration.

    Returns:
        list: A list of error messages.
    """
    errors = []

    if not isinstance(config, dict):
        errors.append("Root of the YAML must be a dictionary.")
        return errors # Stop validation if the root is not a dict

    # Validate apiVersion
    api_version = config.get('apiVersion')
    if not api_version:
        errors.append("'apiVersion' is a required field.")
    elif api_version != 'sandmold.io/v1alpha1':
        errors.append(f"Invalid 'apiVersion': '{api_version}'. Must be 'sandmold.io/v1alpha1'.")

    # Validate kind
    kind = config.get('kind')
    if not kind:
        errors.append("'kind' is a required field.")
    elif kind != 'Classroom':
        errors.append(f"Invalid 'kind': '{kind}'. Must be 'Classroom'.")

    # Validate metadata
    errors.extend(validate_metadata(config.get('metadata')))

    # Validate spec
    spec = config.get('spec')
    if not spec:
        errors.append("'spec' is a required field.")
    elif not isinstance(spec, dict):
        errors.append("'spec' must be a dictionary.")
    else:
        errors.extend(validate_spec(spec, legal_apps))

    return errors

def validate_metadata(metadata):
    """
    Validates the metadata block.
    """
    errors = []
    if not metadata:
        errors.append("'metadata' is a required field.")
        return errors

    if not isinstance(metadata, dict):
        errors.append("'metadata' must be a dictionary.")
        return errors

    # Validate metadata.name
    name = metadata.get('name')
    if not name:
        errors.append("'metadata.name' is a required field.")
    elif not isinstance(name, str) or not name.strip():
        errors.append("'metadata.name' must be a non-empty string.")
    elif not WORKSPACE_NAME_REGEX.match(name):
        errors.append(f"Invalid 'metadata.name': '{name}'. It contains invalid characters or format.")

    # Validate metadata.labels
    labels = metadata.get('labels')
    if labels and not isinstance(labels, dict):
        errors.append("'metadata.labels' must be a dictionary (map of key-value pairs).")
    elif labels:
        for key, value in labels.items():
            if not isinstance(key, str) or not isinstance(value, str):
                errors.append(f"Invalid label '{key}:{value}'. Both key and value must be strings.")
                break

    return errors
