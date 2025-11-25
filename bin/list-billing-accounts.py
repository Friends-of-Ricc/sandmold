#!/usr/bin/env python3
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Lists all accessible billing accounts, categorizing them by usability
and enriching them with organization details.
"""

import json
import subprocess
import sys

# --- ANSI Color and Style Codes ---
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
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
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None

def get_org_domain(org_id):
    """Gets the domain name for a given organization ID."""
    if not org_id:
        return ""
    org_data = run_gcloud_command(["gcloud", "organizations", "describe", org_id, "--format=json"])
    return f"({org_data.get('displayName', 'N/A')})" if org_data else ""

def print_table(accounts):
    """Prints a formatted table of billing accounts."""
    if not accounts:
        print("   No accounts found in this category.")
        return

    # Find max widths for alignment
    widths = {"id": 0, "name": 0, "parent": 0}
    for acc in accounts:
        for key in widths:
            if len(acc.get(key, "")) > widths[key]:
                widths[key] = len(acc.get(key, ""))

    # Print header
    header = (f"{'ACCOUNT_ID':<{widths['id']}}  {'NAME':<{widths['name']}}  {'PARENT':<{widths['parent']}}" )
    print(f"   {Colors.BOLD}{header}{Colors.ENDC}")

    # Print rows
    for acc in accounts:
        parent_str = f"{acc.get('parent', '')} {acc.get('domain', '')}"
        row = (f"{acc.get('id', ''):<{widths['id']}}  "
               f"{acc.get('name', ''):<{widths['name']}}  "
               f"{parent_str:<{widths['parent']}}")
        print(f"   {row}")


def main():
    """Main function to list billing accounts."""
    try:
        user_email_process = subprocess.run(
            ["gcloud", "config", "get-value", "account"],
            capture_output=True, text=True, check=True, encoding='utf-8'
        )
        current_user = user_email_process.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        current_user = "N/A"

    print(f"{Colors.YELLOW}🔎 Billing Accounts accessible by: {Colors.BOLD}{current_user}{Colors.ENDC}\n")

    all_accounts = run_gcloud_command(["gcloud", "billing", "accounts", "list", "--format=json"])
    if not all_accounts:
        print(f"{Colors.RED}Could not retrieve any billing accounts.{Colors.ENDC}")
        sys.exit(1)

    usable_accounts = []
    google_accounts = []

    for acc in all_accounts:
        if not acc.get('open'):
            continue # Skip closed accounts

        parent = acc.get('parent', '')
        org_id = parent.split('/')[-1] if parent else None

        account_details = {
            "id": acc.get('name', '').split('/')[-1],
            "name": acc.get('displayName', 'N/A'),
            "parent": parent,
            "domain": get_org_domain(org_id)
        }

        if parent == 'organizations/433637338589':
            google_accounts.append(account_details)
        else:
            usable_accounts.append(account_details)

    print(f"{Colors.GREEN}✅ Usable Billing Accounts (Not owned by Google Org):{Colors.ENDC}")
    print_table(usable_accounts)

    print(f"\n{Colors.RED}❌ Unusable Billing Accounts (Owned by Google Org):{Colors.ENDC}")
    print_table(google_accounts)


if __name__ == '__main__':
    main()
