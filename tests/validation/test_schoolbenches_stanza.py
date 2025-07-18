# tests/validation/test_schoolbenches_stanza.py
"""
Validates the 'spec.schoolbenches' block of the classroom YAML.
"""

from .common import GCP_PROJECT_ID_REGEX

def validate_schoolbenches(benches_spec, legal_apps):
    """
    Validates the schoolbenches stanza.

    Args:
        benches_spec (list): The 'schoolbenches' list from the spec.

    Returns:
        list: A list of error messages.
    """
    errors = []
    if not isinstance(benches_spec, list) or not benches_spec:
        errors.append("'spec.schoolbenches' must be a non-empty list.")
        return errors

    seen_projects = set()
    for i, bench in enumerate(benches_spec):
        if not isinstance(bench, dict):
            errors.append(f"Item {i} in 'spec.schoolbenches' must be a dictionary.")
            continue

        # --- Check for mandatory fields ---
        if 'project' not in bench:
            errors.append(f"Bench {i}: 'project' is a required field.")
        else:
            project_id = bench.get('project')
            if project_id in seen_projects:
                errors.append(f"Bench {i}: Duplicate project name '{project_id}' found. Project names must be unique.")
            seen_projects.add(project_id)

        if 'seats' not in bench:
            errors.append(f"Bench {i}: 'seats' is a required field.")

        # --- Validate data types and formats ---
        project_id = bench.get('project')
        if project_id and not isinstance(project_id, str):
            errors.append(f"Bench {i}: 'project' must be a string.")
        elif project_id and not GCP_PROJECT_ID_REGEX.match(project_id):
            errors.append(f"Bench {i}: Invalid 'project' ID '{project_id}'. It must be 6-30 chars, lowercase letters, numbers, or hyphens. It must start with a letter and cannot end with a hyphen.")

        seats = bench.get('seats')
        if seats and (not isinstance(seats, list) or not seats):
            errors.append(f"Bench {i}: 'seats' must be a non-empty list.")
        elif seats and not all(isinstance(email, str) for email in seats):
            errors.append(f"Bench {i}: All items in 'seats' must be strings (emails).")

        desk_type = bench.get('desk-type')
        if desk_type and desk_type not in ['student', 'teacher']:
            errors.append(f"Bench {i}: 'desk-type' must be either 'student' or 'teacher'.")

        if 'apps' in bench and not isinstance(bench['apps'], list):
            errors.append(f"Bench {i}: 'apps' must be a list of strings.")

        if 'app' in bench and not isinstance(bench['app'], str):
            errors.append(f"Bench {i}: 'app' must be a string.")
        
        # --- Validate that all apps are legal ---
        all_apps_to_check = []
        if 'apps' in bench:
            all_apps_to_check.extend(bench['apps'])
        if 'app' in bench:
            all_apps_to_check.append(bench['app'])

        for app_item in all_apps_to_check:
            app_name = None
            if isinstance(app_item, str):
                app_name = app_item
            elif isinstance(app_item, dict) and 'name' in app_item:
                app_name = app_item['name']
            else:
                errors.append(f"Bench {i}: Invalid item in 'apps' list. Must be a string or a dictionary with a 'name' key.")
                continue

            if app_name and app_name not in legal_apps:
                errors.append(f"Bench {i}: Application '{app_name}' is not a valid application. It must correspond to a directory in the 'applications/' folder.")

    return errors
