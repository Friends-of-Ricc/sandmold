#!/usr/bin/env python3

import argparse
import json
import yaml
import os

def parse_yaml(file_path):
    """Parses a YAML file."""
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def main(user_yaml_path, output_file, project_root):
    """
    Parses user YAML config and generates terraform.tfvars.json.
    """
    absolute_user_yaml_path = os.path.join(project_root, user_yaml_path)
    user_config = parse_yaml(absolute_user_yaml_path)

    spec = user_config.get('spec', {})

    create_project = True
    project_id = spec.get('project_id')
    if 'existing_project_id' in spec:
        create_project = False
        project_id = spec.get('existing_project_id')

    tf_vars = {
        'create_project': create_project,
        'project_id': project_id,
        'user_email': spec.get('user_email'),
        'billing_account_id': spec.get('billing_account_id'),
    }

    if output_file:
        with open(output_file, 'w') as f:
            json.dump(tf_vars, f, indent=2)
        print(f"Successfully generated {output_file}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate terraform.tfvars.json from user YAML config.')
    parser.add_argument('--user-yaml', required=True, help='Path to the user YAML file.')
    parser.add_argument('--output-file', required=True, help='Path to the output terraform.tfvars.json file.')
    parser.add_argument('--project-root', required=True, help='The absolute path to the project root directory.')
    args = parser.parse_args()

    main(args.user_yaml, args.output_file, args.project_root)
