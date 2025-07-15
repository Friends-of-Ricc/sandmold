#!/usr/bin/env python3

import argparse
import yaml
import sys
import os

def validate_project_names(classroom_yaml_path, root_dir):
    """Validates that project names in the classroom YAML do not contain underscores."""
    
    absolute_yaml_path = os.path.join(root_dir, classroom_yaml_path)

    with open(absolute_yaml_path, 'r') as f:
        classroom_config = yaml.safe_load(f)

    for bench in classroom_config.get('schoolbenches', []):
        project_id_prefix = bench.get('project')
        if project_id_prefix and '_' in project_id_prefix:
            print(f"Error: Project name ''{project_id_prefix}'' in {classroom_yaml_path} contains an underscore. Please use hyphens instead.", file=sys.stderr)
            sys.exit(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Validate a classroom YAML file.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--root-dir', required=True, help='The root directory of the project.')
    args = parser.parse_args()

    validate_project_names(args.classroom_yaml, args.root_dir)