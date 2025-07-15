#!/usr/bin/env python3
"""
Main entry point for validating a classroom YAML file against the sandmold.io/v1alpha1 schema.
"""

import argparse
import yaml
import sys
import os
from validation.test_root import validate_root
from validation.common import Colors, SUCCESS_SYMBOL, FAILURE_SYMBOL, VALIDATING_SYMBOL
from validation.synopsis import generate_synopsis

def main():
    """
    Parses arguments, loads the YAML file, and initiates the validation process.
    """
    parser = argparse.ArgumentParser(description='Validate a classroom YAML file.')
    parser.add_argument('--classroom-yaml', required=True, help='Path to the classroom YAML file.')
    parser.add_argument('--root-dir', required=True, help='The root directory of the project.')
    args = parser.parse_args()

    absolute_yaml_path = os.path.join(args.root_dir, args.classroom_yaml)

    print(f"{Colors.YELLOW}{VALIDATING_SYMBOL} Validating {args.classroom_yaml}...{Colors.ENDC}")

    try:
        with open(absolute_yaml_path, 'r', encoding='utf-8') as f:
            classroom_config = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: File not found at '{absolute_yaml_path}'", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error: Could not parse YAML file: {e}", file=sys.stderr)
        sys.exit(1)

    # Print the synopsis
    synopsis = generate_synopsis(classroom_config)
    if synopsis:
        print(synopsis)

    # Get the list of legal applications from the applications/ directory
    applications_dir = os.path.join(args.root_dir, 'applications')
    try:
        legal_apps = {d for d in os.listdir(applications_dir) if os.path.isdir(os.path.join(applications_dir, d))}
    except FileNotFoundError:
        print(f"Warning: 'applications' directory not found at '{applications_dir}'. Cannot validate app names.", file=sys.stderr)
        legal_apps = set()

    # Start the validation chain
    errors = validate_root(classroom_config, legal_apps)

    if errors:
        print(f"{Colors.RED}{Colors.BOLD}{FAILURE_SYMBOL} Validation failed with the following errors:{Colors.ENDC}", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"{Colors.GREEN}{Colors.BOLD}{SUCCESS_SYMBOL} Validation successful!{Colors.ENDC}")

if __name__ == '__main__':
    main()
