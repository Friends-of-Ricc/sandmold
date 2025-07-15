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
