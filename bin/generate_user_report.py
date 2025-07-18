#!/usr/bin/env python3

import argparse
import json
import yaml

def parse_yaml(file_path):
    """Parses a YAML file."""
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def generate_markdown_report(tf_data, user_data, user_yaml_path):
    """Generates a markdown report from the terraform and user data."""
    
    # Extract top-level data
    projects_output = tf_data.get('projects', {}).get('value', {})
    project_id = list(projects_output.keys())[0] if projects_output else 'N/A'
    project_url = f"https://console.cloud.google.com/home/dashboard?project={project_id}"

    # Extract data from the user YAML
    spec = user_data.get('spec', {})
    metadata = user_data.get('metadata', {})

    workspace_name = metadata.get('name', 'N/A')
    user_email = spec.get('user_email', 'N/A')

    # --- Main Report Header ---
    report_lines = [
        "# ✅ User Setup Successful",
        "",
        "## User Details",
        "",
        f"- **Workspace Name:** `{workspace_name}`",
        f"- **User Email:** {user_email}",
        f"- **Project ID:** [{project_id}]({project_url})",
        "",
    ]

    # --- Handy Commands Section ---
    report_lines.extend([
        "## ⚡ Handy Commands",
        "",
        "```bash",
        f"# To tear down this specific user setup:",
        f"# just user-down {user_yaml_path}",
        "",
        f"# To re-provision this specific user setup:",
        f"just user-up {user_yaml_path}",
        "```",
        "",
    ])

    return "\n".join(report_lines)

def main(tf_output_json_path, user_yaml_path, report_path):
    """
    Parses terraform output and user YAML to generate a markdown report.
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
        user_data = parse_yaml(user_yaml_path)
    except FileNotFoundError as e:
        print(f"Error reading user YAML file: {e}")
        report_content = f"# Deployment Report\n\n## Error\n\nFailed to generate report. Could not read the user YAML file.\n\n**Details:** `{e}`"
        with open(report_path, 'w') as f:
            f.write(report_content)
        return

    report_content = generate_markdown_report(tf_data, user_data, user_yaml_path)

    with open(report_path, 'w') as f:
        f.write(report_content)

    print(f"Successfully generated report at {report_path}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate a markdown report from terraform output.')
    parser.add_argument('--tf-output-json', required=True, help='Path to the terraform output JSON file.')
    parser.add_argument('--user-yaml', required=True, help='Path to the user YAML file.')
    parser.add_argument('--report-path', required=True, help='Path to write the final REPORT.md file.')
    args = parser.parse_args()

    main(args.tf_output_json, args.user_yaml, args.report_path)