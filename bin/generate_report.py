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
    
    # Extract top-level data
    projects_output = tf_data.get('projects', {}).get('value', {})
    folder_id = tf_data.get('folder_id', {}).get('value', 'N/A')
    folder_url = f"https://console.cloud.google.com/cloud-resource-manager?folder={folder_id}"
    
    # Extract data from the classroom YAML
    spec = classroom_data.get('spec', {})
    metadata = classroom_data.get('metadata', {})
    folder_spec = spec.get('folder', {})

    workspace_name = metadata.get('name', 'N/A')
    folder_display_name = folder_spec.get('displayName', workspace_name) # Default to workspace name
    class_description = folder_spec.get('description', 'No description provided.')
    teachers_list = folder_spec.get('teachers', [])
    teachers_str = ", ".join(teachers_list)

    # Calculate student count
    student_emails = set()
    for bench in spec.get('schoolbenches', []):
        if bench.get('desk-type') != 'teacher':
            for email in bench.get('seats', []):
                student_emails.add(email)
    num_students = len(student_emails)

    # --- Main Report Header ---
    report_lines = [
        "# ✅ Classroom Provisioning Successful",
        "",
        "## Class Details",
        "",
        f"- **Workspace Name:** `{workspace_name}`",
        f"- **Folder Name:** [{folder_display_name}]({folder_url})",
        f"- **Folder ID:** `{folder_id}`",
        f"- **Description:** {class_description}",
        f"- **Teachers:** {teachers_str}",
        f"- **Student Count:** {num_students}",
        f"- **Project Count:** {len(projects_output)}",
        "",
    ]

    # --- Handy Commands Section ---
    report_lines.extend([
        "## ⚡ Handy Commands",
        "",
        "```bash",
        f"# To tear down this specific classroom:",
        f"just teardown-classroom etc/samples/{workspace_name}.yaml",
        "",
        f"# To re-provision this specific classroom:",
        f"just setup-classroom etc/samples/{workspace_name}.yaml",
        "```",
        "",
    ])

    # --- User-Centric Table ---
    report_lines.extend([
        "## 🧑‍🎓 Student & Project Assignments",
        "",
        "| Student Email | Project ID | Assigned Apps |",
        "|---------------|------------|---------------|",
    ])

    student_benches = [
        bench for bench in classroom_data.get('spec', {}).get('schoolbenches', [])
        if bench.get('desk-type') != 'teacher'
    ]

    for bench in student_benches:
        project_name = bench.get('project')
        project_info = projects_output.get(project_name, {})
        project_id = project_info.get('project_id', 'N/A')
        project_url = f"https://console.cloud.google.com/home/dashboard?project={project_id}"
        
        apps = bench.get('apps', [])
        if 'app' in bench:
            apps.append(bench['app'])
        apps_str = ", ".join(apps) if apps else "-"

        for user in bench.get('seats', []):
            report_lines.append(f"| {user} | [`{project_id}`]({project_url}) | {apps_str} |")

    # --- Project-Centric Table ---
    report_lines.extend([
        "",
        "## 🛠️ Project Details",
        "",
        "| Project Name | Project ID | Users | Applications (Planned) |",
        "|--------------|------------|-------|------------------------|",
    ])

    # Create a lookup map from the classroom data
    project_details_map = {}
    for bench in classroom_data.get('spec', {}).get('schoolbenches', []):
        project_name = bench.get('project')
        if project_name:
            apps = bench.get('apps', [])
            if 'app' in bench:
                apps.append(bench['app'])
            
            project_details_map[project_name] = {
                'users': ", ".join(bench.get('seats', [])),
                'apps': ", ".join(apps) if apps else "-"
            }

    for name, details in projects_output.items():
        classroom_details = project_details_map.get(name, {})
        users = classroom_details.get('users', 'N/A')
        apps = classroom_details.get('apps', '-')
        project_id = details.get('project_id')
        iam_link = f"https://console.cloud.google.com/iam-admin/iam?project={project_id}"
        report_lines.append(f"| {name} | [`{project_id}`]({iam_link}) | {users} | {apps} |")

    # --- TODO Section ---
    report_lines.extend([
        "",
        "---",
        "",
        "## ✏️ TODO: Next Steps",
        "",
        "The core infrastructure for your classroom is now ready. The next step is to deploy the applications to the student projects.",
        "",
        "1.  **Review the application blueprints** in the `applications/` directory.",
        "2.  **Run the application deployment stage** (currently under development).",
        "",
    ])

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
