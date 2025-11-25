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

# tests/validation/test_common_stanza.py
"""
Validates the 'spec.common' block of the classroom YAML.
"""

def validate_common(common_spec):
    """
    Validates the common stanza.

    Args:
        common_spec (dict): The 'common' dictionary from the spec.

    Returns:
        list: A list of error messages.
    """
    errors = []
    if not isinstance(common_spec, dict):
        errors.append("'spec.common' must be a dictionary.")
        return errors

    benches_common = common_spec.get('schoolbenches')
    if benches_common and not isinstance(benches_common, dict):
        errors.append("'spec.common.schoolbenches' must be a dictionary.")
        return errors

    if benches_common:
        foreach = benches_common.get('foreach_project')
        if not foreach:
            errors.append("'spec.common.schoolbenches' must contain 'foreach_project'.")
        elif not isinstance(foreach, dict):
            errors.append("'spec.common.schoolbenches.foreach_project' must be a dictionary.")
        else:
            # Validate 'applies_to'
            applies_to = foreach.get('applies_to')
            if not applies_to:
                errors.append("'applies_to' is required in 'foreach_project'.")
            elif applies_to not in ['ALL_STUDENTS', 'ALL']:
                errors.append(f"Invalid 'applies_to' value: '{applies_to}'. Must be 'ALL_STUDENTS' or 'ALL'.")

            # Validate 'apps' and 'seats' if they exist
            if 'apps' in foreach and not isinstance(foreach['apps'], list):
                errors.append("'apps' in 'foreach_project' must be a list.")
            if 'seats' in foreach and not isinstance(foreach['seats'], list):
                errors.append("'seats' in 'foreach_project' must be a list.")

    return errors
