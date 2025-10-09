#!/usr/bin/env python3

import argparse
import json
import os
import subprocess
import sys

def execute_app_deployment(json_file_path):
    """
    Reads application deployment details from a JSON file and executes the start scripts.

    Args:
        json_file_path (str): The path to the JSON file containing app deployment details.
    """
    try:
        with open(json_file_path, 'r') as f:
            app_deployments = json.load(f)
    except FileNotFoundError:
        print(f"Error: The file '{json_file_path}' was not found.", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Could not decode JSON from the file '{json_file_path}'.", file=sys.stderr)
        sys.exit(1)

    # Extract the two main outputs from the Terraform JSON
    app_details_map = app_deployments.get("app_deployments_details", {}).get("value", {})
    online_boutique_deployments = app_deployments.get("online_boutique_deployments", {}).get("value", {})

    if not app_details_map:
        print("No applications to deploy based on 'app_deployments_details'.")
        return

    # Create a lookup for cluster details from the online_boutique output
    cluster_details_lookup = {
        deployment["project_id"]: deployment
        for key, deployment in online_boutique_deployments.items()
    }

    for i, details in app_details_map.items():
        app_name = details.get('app_name', 'N/A')
        project_id = details.get('project_id', 'N/A')
        working_dir = details.get('working_dir')
        start_script = details.get('start_script')
        environment = details.get('environment', {})

        print(f"--- Deploying application '{app_name}' to project '{project_id}' ---")

        if not all([working_dir, start_script]):
            print(f"Error: Missing 'working_dir' or 'start_script' for app '{app_name}'. Skipping.", file=sys.stderr)
            continue

        if not os.path.isdir(working_dir):
            print(f"Error: Working directory '{working_dir}' does not exist. Skipping.", file=sys.stderr)
            continue
            
        if not os.path.exists(start_script) or not os.access(start_script, os.X_OK):
            print(f"Error: Start script '{start_script}' does not exist or is not executable. Skipping.", file=sys.stderr)
            # Attempt to make it executable as a fallback
            try:
                os.chmod(start_script, 0o755)
                print(f"Made '{start_script}' executable.")
            except OSError as e:
                print(f"Could not make script executable: {e}. Skipping.", file=sys.stderr)
                continue

        try:
            # Combine current environment with the one from Terraform
            process_env = os.environ.copy()
            process_env.update(environment)

            # If this app is online-boutique and we have cluster details, add them to the environment
            if app_name == "online-boutique" and project_id in cluster_details_lookup:
                cluster_details = cluster_details_lookup[project_id]
                process_env["PROJECT_ID"] = cluster_details.get("project_id")
                process_env["CLUSTER_NAME"] = cluster_details.get("cluster_name")
                process_env["CLUSTER_LOCATION"] = cluster_details.get("cluster_location")

            result = subprocess.run(
                [start_script],
                cwd=working_dir,
                env=process_env,
                capture_output=True,
                text=True,
                check=True  # This will raise a CalledProcessError if the script returns a non-zero exit code
            )
            print(f"Successfully deployed '{app_name}'.")
            if result.stdout:
                print("STDOUT:")
                print(result.stdout)
            if result.stderr:
                print("STDERR:")
                print(result.stderr)

        except subprocess.CalledProcessError as e:
            print(f"Error deploying application '{app_name}' with exit code {e.returncode}.", file=sys.stderr)
            print(f"Working directory: {working_dir}", file=sys.stderr)
            print(f"Command: {e.cmd}", file=sys.stderr)
            if e.stdout:
                print("STDOUT:", file=sys.stderr)
                print(e.stdout, file=sys.stderr)
            if e.stderr:
                print("STDERR:", file=sys.stderr)
                print(e.stderr, file=sys.stderr)
            # Decide if you want to stop all deployments on first failure
            # sys.exit(1) 
        except Exception as e:
            print(f"An unexpected error occurred while deploying '{app_name}': {e}", file=sys.stderr)
            # sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Execute application deployment scripts based on Terraform output.")
    parser.add_argument("--json-file", required=True, help="Path to the JSON file with application deployment details.")
    args = parser.parse_args()

    execute_app_deployment(args.json_file)
