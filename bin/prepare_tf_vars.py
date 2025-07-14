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
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def main(classroom_yaml_path, project_config_yaml_path, output_file):
    """
    Parses classroom and project configs and generates terraform.tfvars.json.
    """
    classroom_config = parse_yaml(classroom_yaml_path)
    project_config = parse_yaml(project_config_yaml_path)

    # Prepare the student_projects variable
    student_projects = []
    for bench in classroom_config.get('schoolbenches', []):
        project_id_prefix = bench.get('project')
        users = bench.get('seats', [])
        if project_id_prefix and users:
            student_projects.append({
                'project_id_prefix': project_id_prefix,
                'users': [f"user:{user}" for user in users]
            })

    # Prepare the iam_permissions map
    iam_permissions = {}
    user_roles = project_config.get('iam_permissions', {}).get('user_roles', [])
    for role in user_roles:
        # The actual users will be substituted by Terraform for each project
        iam_permissions[role] = [] # Placeholder, will be populated in TF

    tf_vars = {
        'folder_name': classroom_config.get('folder', {}).get('name'),
        'parent_folder': f"folders/{classroom_config.get('folder', {}).get('parent_folder_id')}",
        'billing_account_id': classroom_config.get('folder', {}).get('billing_account_id'),
        'teachers': [f"user:{teacher}" for teacher in classroom_config.get('folder', {}).get('teachers', [])],
        'student_projects': student_projects,
        'services_to_enable': project_config.get('services_to_enable', []),
        'iam_user_roles': user_roles,
        'folder_tags': classroom_config.get('folder', {}).get('tags', {})
    }

    if output_file:
        with open(output_file, 'w') as f:
            json.dump(tf_vars, f, indent=2)

    # Print the folder name to stdout so it can be captured by the calling script
    print(classroom_config.get('folder', {}).get('name'))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate terraform.tfvars.json from YAML configs.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--project-config-yaml', required=True, help='Path to the project config YAML file.')
    parser.add_argument('--output-file', required=True, help='Path to the output terraform.tfvars.json file.')
    args = parser.parse_args()

    main(args.classroom_yaml, args.project_config_yaml, args.output_file)
