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

def main(classroom_yaml_path, output_file, project_root):
    """
    Parses classroom config and generates app_deployment.json.
    """
    absolute_classroom_yaml_path = os.path.join(project_root, classroom_yaml_path)
    classroom_config = parse_yaml(absolute_classroom_yaml_path)

    spec = classroom_config.get('spec', {})
    schoolbenches = spec.get('schoolbenches', [])
    common_spec = spec.get('common', {}).get('schoolbenches', {})

    deployments = []
    processed_apps = set()

    for bench in schoolbenches:
        project_id_prefix = bench.get('project')
        desk_type = bench.get('desk-type', 'student')
        project_id = f"std-{project_id_prefix}" if desk_type == 'student' else f"tch-{project_id_prefix}"

        apps_to_process = []
        # Add common apps
        if common_spec:
            applies_to = common_spec.get('foreach_project', {}).get('applies_to', 'ALL_STUDENTS')
            apps = common_spec.get('foreach_project', {}).get('apps', [])
            if applies_to == 'ALL_STUDENTS' and desk_type == 'student':
                apps_to_process.extend(apps)

        # Add project-specific apps
        apps_to_process.extend(bench.get('apps', []))

        for app_ref in apps_to_process:
            app_name = app_ref.get('name') if isinstance(app_ref, dict) else app_ref
            app_vars = app_ref.get('variables', {}) if isinstance(app_ref, dict) else {}

            if (project_id, app_name) in processed_apps:
                continue

            deployment = {
                'project_id': project_id,
                'app_name': app_name,
            }

            app_dir = os.path.join(project_root, 'applications', app_name)
            blueprint_path = os.path.join(app_dir, 'blueprint.yaml')

            if not os.path.isdir(app_dir):
                deployment['status'] = f'_APP_MALFORMED_ (directory not found for app "{app_name}")'
            elif not os.path.exists(blueprint_path):
                deployment['status'] = f'_APP_MALFORMED_ (blueprint.yaml not found for app "{app_name}")'
            elif not os.path.exists(os.path.join(app_dir, 'start.sh')):
                deployment['status'] = f'_APP_MALFORMED_ (start.sh not found for app "{app_name}")'
            elif not os.path.exists(os.path.join(app_dir, 'stop.sh')):
                deployment['status'] = f'_APP_MALFORMED_ (stop.sh not found for app "{app_name}")'
            elif not os.path.exists(os.path.join(app_dir, 'status.sh')):
                deployment['status'] = f'_APP_MALFORMED_ (status.sh not found for app "{app_name}")'
            else:
                blueprint_config = parse_yaml(blueprint_path)
                required_vars_full = blueprint_config.get('spec', {}).get('variables', [])
                required_vars = [var['name'] for var in required_vars_full]

                env = {}
                if 'env' in spec.get('folder', {}):
                    for var in spec['folder']['env']:
                        env[var['name']] = var['value']
                if 'env' in bench:
                    for var in bench['env']:
                        env[var['name']] = var['value']
                env.update(app_vars)
                env['GOOGLE_CLOUD_PROJECT'] = project_id
                env['PROJECT_ID'] = project_id
                if 'GOOGLE_CLOUD_REGION' in env:
                    env['REGION'] = env['GOOGLE_CLOUD_REGION']
                env['SANDMOLD_DESK_TYPE'] = desk_type

                missing_vars = [var for var in required_vars if var not in env]
                if missing_vars:
                    deployment['status'] = f'_APP_MALFORMED_ (missing variables: {", ".join(missing_vars)})'
                else:
                    deployment['status'] = 'OK'
                    deployment['environment'] = env

            deployments.append(deployment)
            processed_apps.add((project_id, app_name))

    if output_file:
        with open(output_file, 'w') as f:
            json.dump(deployments, f, indent=2)
        print(f"Successfully generated {output_file}", file=sys.stderr)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate app_deployment.json from YAML config.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--output-file', required=True, help='Path to the output app_deployment.json file.')
    parser.add_argument('--project-root', default=os.getcwd(), help='The absolute path to the project root directory.')
    args = parser.parse_args()

    main(args.classroom_yaml, args.output_file, args.project_root)
