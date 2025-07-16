#!/usr/bin/env python3

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import json
import yaml
import os

import sys

def parse_yaml(file_path):
    """Parses a YAML file."""
    print(f"DEBUG: Attempting to open file: {file_path}", file=sys.stderr)
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def main(classroom_yaml_path, project_config_yaml_path, output_file, project_root):
    """
    Parses classroom and project configs and generates terraform.tfvars.json.
    """
    # Construct absolute path to classroom YAML
    absolute_classroom_yaml_path = os.path.join(project_root, classroom_yaml_path)

    classroom_config = parse_yaml(absolute_classroom_yaml_path)
    project_config = parse_yaml(project_config_yaml_path)

    spec = classroom_config.get('spec', {})
    metadata = classroom_config.get('metadata', {})
    folder_spec = spec.get('folder', {})

    # Prepare the student_projects variable
    student_projects = []
    project_labels = project_config.get('projects', {}).get('labels', {})
    for bench in spec.get('schoolbenches', []):
        project_id_prefix = bench.get('project')
        users = bench.get('seats', [])
        desk_type = bench.get('desk-type', 'student') # Default to student

        if desk_type == 'teacher':
            project_id_prefix = f"tch-{project_id_prefix}"
        else: # For 'student' or any other type
            project_id_prefix = f"std-{project_id_prefix}"

        # Merge project-specific labels with the common labels
        labels = project_labels.copy()
        labels['desk-type'] = desk_type

        if project_id_prefix and users:
            student_projects.append({
                'project_id_prefix': project_id_prefix,
                'users': [f"user:{user}" for user in users],
                'labels': labels
            })

    # Prepare the iam_permissions map
    iam_permissions = {}
    user_roles = project_config.get('iam_permissions', {}).get('user_roles', [])
    for role in user_roles:
        # The actual users will be substituted by Terraform for each project
        iam_permissions[role] = [] # Placeholder, will be populated in TF

    # Default folder display name to metadata name if not provided
    folder_display_name = folder_spec.get('displayName', metadata.get('name'))

    # Merge folder labels from classroom and project configs
    folder_tags = metadata.get('labels', {})
    folder_tags.update(project_config.get('folders', {}).get('labels', {}))


    tf_vars = {
        'folder_display_name': folder_display_name,
        'parent_folder': f"folders/{folder_spec.get('parent_folder_id')}",
        'billing_account_id': folder_spec.get('billing_account_id'),
        'teachers': [f"user:{teacher}" for teacher in folder_spec.get('teachers', [])],
        'student_projects': student_projects,
        'services_to_enable': project_config.get('services_to_enable', []),
        'iam_user_roles': user_roles,
        'folder_tags': folder_tags
    }

    if output_file:
        with open(output_file, 'w') as f:
            json.dump(tf_vars, f, indent=2)
        print(f"Successfully generated {output_file}", file=sys.stderr)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate terraform.tfvars.json from YAML configs.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--project-config-yaml', required=True, help='Path to the project config YAML file.')
    parser.add_argument('--output-file', required=True, help='Path to the output terraform.tfvars.json file.')
    parser.add_argument('--project-root', required=True, help='The absolute path to the project root directory.')
    args = parser.parse_args()

    main(args.classroom_yaml, args.project_config_yaml, args.output_file, args.project_root)
