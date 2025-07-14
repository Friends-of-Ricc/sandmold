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

def generate_markdown_report(data):
    """Generates a markdown report from the terraform output data."""
    
    projects = data.get('projects', {}).get('value', {})
    folder_id = data.get('folder_id', {}).get('value', 'N/A')

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
        "| Project Name | Project ID | Project Number |",
        "|--------------|------------|----------------|",
    ]

    for name, details in projects.items():
        report_lines.append(f"| {name} | `{details.get('project_id')}` | `{details.get('project_number')}` |")

    return "\n".join(report_lines)

def main(tf_output_json_path, report_path):
    """
    Parses the terraform output JSON and generates a markdown report.
    """
    try:
        with open(tf_output_json_path, 'r') as f:
            tf_data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error reading or parsing terraform output file: {e}")
        # Create a report indicating the error
        report_content = f"""# Deployment Report

## Error

Failed to generate report. Could not read or parse the Terraform output file.

**Details:** `{e}`
"""
        with open(report_path, 'w') as f:
            f.write(report_content)
        return

    report_content = generate_markdown_report(tf_data)

    with open(report_path, 'w') as f:
        f.write(report_content)

    print(f"Successfully generated report at {report_path}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate a markdown report from terraform output.')
    parser.add_argument('--tf-output-json', required=True, help='Path to the terraform output JSON file.')
    parser.add_argument('--report-path', required=True, help='Path to write the final REPORT.md file.')
    args = parser.parse_args()

    main(args.tf_output_json, args.report_path)
