# tests/validation/synopsis.py
"""
Generates a one-line summary of the classroom configuration.
"""
from .common import Colors

def generate_synopsis(config):
    """
    Calculates stats and formats them into a colorful one-line synopsis.

    Args:
        config (dict): The loaded classroom YAML configuration.

    Returns:
        str: The formatted summary string.
    """
    try:
        spec = config.get('spec', {})
        metadata = config.get('metadata', {})

        # --- Calculate stats ---
        class_name = metadata.get('name', 'N/A')
        
        num_teachers = len(spec.get('folder', {}).get('teachers', []))
        
        benches = spec.get('schoolbenches', [])
        num_benches = len(benches)
        
        all_students = set()
        all_apps = set()
        
        for bench in benches:
            for student in bench.get('seats', []):
                all_students.add(student)
            
            if 'app' in bench:
                all_apps.add(bench['app'])
            if 'apps' in bench:
                for app in bench.get('apps', []):
                    all_apps.add(app)

        num_students = len(all_students)
        num_apps = len(all_apps)

        # --- Format the string ---
        synopsis = (
            f"{Colors.CYAN}📊 "
            f"Class '{Colors.BOLD}{class_name}{Colors.ENDC}{Colors.CYAN}' "
            f"({num_teachers} teachers, {num_students} students, "
            f"{num_benches} benches, {num_apps} unique apps)"
            f"{Colors.ENDC}"
        )
        return synopsis
    except Exception:
        # If the YAML is malformed, we can't generate a synopsis.
        return None
