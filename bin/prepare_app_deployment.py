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
    Parses classroom and project configs and generates a JSON file for app deployment.
    """
    # Construct absolute path to classroom YAML
    absolute_classroom_yaml_path = os.path.join(project_root, classroom_yaml_path)

    classroom_config = parse_yaml(absolute_classroom_yaml_path)
    project_config = parse_yaml(project_config_yaml_path)

    spec = classroom_config.get('spec', {})
    schoolbenches = spec.get('schoolbenches', [])

    output = {'projects': []}
    for bench in schoolbenches:
        project_id_prefix = bench.get('project')
        apps = bench.get('apps', [])
        desk_type = bench.get('desk-type', 'student')

        if not project_id_prefix or not apps:
            continue

        project_data = {
            'project_id': project_id_prefix,
            'desk_type': desk_type,
            'apps': []
        }

        for app in apps:
            if isinstance(app, str):
                app_name = app
            elif isinstance(app, dict):
                app_name = app.get('name')
            else:
                continue

            if not app_name:
                continue

            app_path = os.path.join(project_root, 'applications', app_name)
            start_script = os.path.join(app_path, 'start.sh')
            stop_script = os.path.join(app_path, 'stop.sh')
            status_script = os.path.join(app_path, 'status.sh')

            app_data = {
                'name': app_name,
                'path': app_path,
                'malformed': not all(os.path.exists(p) for p in [start_script, stop_script, status_script])
            }
            project_data['apps'].append(app_data)

        output['projects'].append(project_data)

    if output_file:
        with open(output_file, 'w') as f:
            json.dump(output, f, indent=2)
    else:
        print(json.dumps(output, indent=2))
        print(f"Successfully generated {output_file}", file=sys.stderr)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate JSON for app deployment from YAML configs.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--project-config-yaml', required=True, help='Path to the project config YAML file.')
    parser.add_argument('--output-file', help='Path to the output JSON file.')
    parser.add_argument('--project-root', required=True, help='The absolute path to the project root directory.')
    args = parser.parse_args()

    main(args.classroom_yaml, args.project_config_yaml, args.output_file, args.project_root)
