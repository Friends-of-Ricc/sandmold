#!/usr/bin/env python3

import argparse
import yaml
from datetime import datetime

def main(classroom_yaml_path, report_path):
    """
    Generates a teardown report for a classroom.
    """
    with open(classroom_yaml_path, 'r') as f:
        classroom_config = yaml.safe_load(f)

    metadata = classroom_config.get('metadata', {})
    spec = classroom_config.get('spec', {})
    folder_spec = spec.get('folder', {})

    with open(report_path, 'w') as f:
        f.write("# 🌪️ Classroom Destroyed 🌪️\n\n")
        f.write(f"**Timestamp:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        f.write("## Class Details\n\n")
        f.write(f"- **Workspace Name:** `{metadata.get('name')}`\n")
        f.write(f"- **Original Folder Name:** {folder_spec.get('displayName')}\n")
        f.write(f"- **Original Folder ID:** {folder_spec.get('parent_folder_id')}\n")
        f.write(f"- **Description:** {folder_spec.get('description', '').strip()}\n\n")

        f.write("## ⚡ Handy Commands\n\n")
        f.write("```bash\n")
        f.write(f"# To re-provision this specific classroom:\n")
        f.write(f"just classroom-up {classroom_yaml_path}\n")
        f.write("```\n\n")

        f.write("## 🧑‍🎓 Student & Project Assignments\n\n")
        f.write("All projects and resources for this classroom have been destroyed.\n")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate a teardown report for a classroom.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--report-path', required=True, help='Path to the output REPORT.md file.')
    args = parser.parse_args()

    main(args.classroom_yaml, args.report_path)
