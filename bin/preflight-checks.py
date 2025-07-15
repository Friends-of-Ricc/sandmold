#!/usr/bin/env python3
"""
Performs preflight checks on a classroom YAML configuration to provide a clear
picture of the target Google Cloud environment.
"""

import argparse
import json
import os
import subprocess
import sys
import yaml

# --- ANSI Color and Style Codes ---
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    ENDC = '\033[0m'

def run_gcloud_command(command):
    """Runs a gcloud command and returns the JSON output."""
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True,
            encoding='utf-8'
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"{Colors.RED}❌ Error running gcloud command: {' '.join(command)}{Colors.ENDC}", file=sys.stderr)
        print(e.stderr, file=sys.stderr)
        return None
    except json.JSONDecodeError:
        print(f"{Colors.RED}❌ Error decoding JSON from gcloud command.{Colors.ENDC}", file=sys.stderr)
        return None


def check_billing_account(billing_id):
    """Checks and displays information about the billing account."""
    print(f"\n{Colors.YELLOW}💰 Checking Billing Account: {billing_id}{Colors.ENDC}")
    command = ["gcloud", "billing", "accounts", "describe", billing_id, "--format=json"]
    data = run_gcloud_command(command)
    if data:
        name = data.get('displayName', 'N/A')
        is_open = "Open" if data.get('open', False) else "Closed"
        billing_url = f"https://console.cloud.google.com/billing/{billing_id}"
        print(f"   - {Colors.BOLD}Name:{Colors.ENDC} {name}")
        print(f"   - {Colors.BOLD}Status:{Colors.ENDC} {is_open}")
        print(f"   - {Colors.BOLD}Link:{Colors.ENDC} {Colors.BLUE}{billing_url}{Colors.ENDC}")
    else:
        print(f"   {Colors.RED}Could not retrieve details for this billing account.{Colors.ENDC}")


def display_folder_tree(folder_id, prefix=""):
    """Recursively displays folders and projects in a tree-like structure."""
    # Display subfolders
    folders_command = ["gcloud", "resource-manager", "folders", "list", f"--folder={folder_id}", "--format=json"]
    folders = run_gcloud_command(folders_command)
    if folders is not None:
        for i, folder in enumerate(folders):
            folder_name = folder.get('name', '') # e.g., "folders/12345"
            folder_numeric_id = folder_name.split('/')[-1]
            is_last = i == len(folders) - 1
            connector = "└── " if is_last else "├── "
            print(f"{prefix}{connector}{Colors.BLUE}📁 {folder.get('displayName')} ({folder_numeric_id}){Colors.ENDC}")
            new_prefix = prefix + ("    " if is_last else "│   ")
            display_folder_tree(folder_numeric_id, new_prefix)

    # Display projects in the current folder
    projects_command = ["gcloud", "projects", "list", f"--filter=parent.id={folder_id} AND parent.type=folder", "--format=json"]
    projects = run_gcloud_command(projects_command)
    if projects is not None:
        for i, project in enumerate(projects):
            is_last = i == len(projects) - 1 and not (folders and i < len(folders) -1)
            connector = "└── " if is_last else "├── "
            print(f"{prefix}{connector}{Colors.CYAN}🧩 {project.get('name')} ({project.get('projectId')}){Colors.ENDC}")


def main():
    """Main function to run the preflight checks."""
    parser = argparse.ArgumentParser(description='Run preflight checks for a classroom YAML file.')
    parser.add_argument('classroom_yaml', help='Path to the classroom YAML file.')
    args = parser.parse_args()

    if not os.path.exists(args.classroom_yaml):
        print(f"{Colors.RED}❌ File not found: {args.classroom_yaml}{Colors.ENDC}", file=sys.stderr)
        sys.exit(1)

    with open(args.classroom_yaml, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)

    spec = config.get('spec', {})
    folder_spec = spec.get('folder', {})

    billing_id = folder_spec.get('billing_account_id')
    parent_folder_id = folder_spec.get('parent_folder_id')
    org_id = folder_spec.get('org_id')

    if not all([billing_id, parent_folder_id, org_id]):
        print(f"{Colors.RED}❌ YAML must contain 'spec.folder.billing_account_id', 'spec.folder.parent_folder_id', and 'spec.folder.org_id'.{Colors.ENDC}", file=sys.stderr)
        sys.exit(1)

    check_billing_account(billing_id)

    # Construct a more useful URL that opens the resource manager scoped to the organization
    resource_manager_url = f"https://console.cloud.google.com/cloud-resource-manager?organization={org_id}"
    print(f"\n{Colors.YELLOW}🌳 Exploring parent folder ({parent_folder_id}) contents:{Colors.ENDC}")
    print(f"   - {Colors.BOLD}Link to Org Resource Manager:{Colors.ENDC} {Colors.BLUE}{resource_manager_url}{Colors.ENDC}")
    display_folder_tree(parent_folder_id)


if __name__ == '__main__':
    main()
