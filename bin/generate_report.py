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

def parse_yaml(file_path):
    """Parses a YAML file."""
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def generate_markdown_report(tf_data, classroom_data):
    """Generates a markdown report from the terraform and classroom data."""
    
    projects = tf_data.get('projects', {}).get('value', {})
    folder_id = tf_data.get('folder_id', {}).get('value', 'N/A')

    # Create a lookup map from the classroom data
    project_details_map = {}
    for bench in classroom_data.get('schoolbenches', []):
        project_name = bench.get('project')
        if project_name:
            project_details_map[project_name] = {
                'users': ", ".join(bench.get('seats', [])),
                'apps': ", ".join(bench.get('apps', ['-']))
            }

    report_lines = [
        "# Deployment Report",
        "",
        "## Summary",
        "",
        f"- **Folder ID:** `{folder_id}`",
        f"- **Total Projects Created:** {len(projects)}",
        "",
        "## Project Details",
        "",
        "| Project Name | Project ID | Users | Applications (Planned) |",
        "|--------------|------------|-------|------------------------|",
    ]

    for name, details in projects.items():
        classroom_details = project_details_map.get(name, {})
        users = classroom_details.get('users', 'N/A')
        apps = classroom_details.get('apps', '-')
        report_lines.append(f"| {name} | `{details.get('project_id')}` | {users} | {apps} |")

    return "\n".join(report_lines)

def main(tf_output_json_path, classroom_yaml_path, report_path):
    """
    Parses terraform output and classroom YAML to generate a markdown report.
    """
    try:
        with open(tf_output_json_path, 'r') as f:
            tf_data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error reading or parsing terraform output file: {e}")
        report_content = f"# Deployment Report\n\n## Error\n\nFailed to generate report. Could not read or parse the Terraform output file.\n\n**Details:** `{e}`"
        with open(report_path, 'w') as f:
            f.write(report_content)
        return

    try:
        classroom_data = parse_yaml(classroom_yaml_path)
    except FileNotFoundError as e:
        print(f"Error reading classroom YAML file: {e}")
        report_content = f"# Deployment Report\n\n## Error\n\nFailed to generate report. Could not read the classroom YAML file.\n\n**Details:** `{e}`"
        with open(report_path, 'w') as f:
            f.write(report_content)
        return

    report_content = generate_markdown_report(tf_data, classroom_data)

    with open(report_path, 'w') as f:
        f.write(report_content)

    print(f"Successfully generated report at {report_path}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate a markdown report from terraform output.')
    parser.add_argument('--tf-output-json', required=True, help='Path to the terraform output JSON file.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--report-path', required=True, help='Path to write the final REPORT.md file.')
    args = parser.parse_args()

    main(args.tf_output_json, args.classroom_yaml, args.report_path)
