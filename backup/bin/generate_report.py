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

def main(tf_output_log, report_path):
    """
    Parses the terraform output log and generates a markdown report.
    """
    print("---")
    print("Simulating report generation...")
    print(f"Reading terraform output from: {tf_output_log}")
    print("---")

    # In the future, this script will:
    # 1. Parse the `tf_output_log` for success and error messages.
    # 2. Parse the terraform output variables (if successful).
    # 3. Construct a user-friendly markdown table.

    report_content = """# Deployment Report

## Summary

| Status | Details                               |
|--------|---------------------------------------|
| 🚧     | **Provisioning has not been run yet.** |

*This is a placeholder report. Run the full setup to generate a complete report.*
"""

    with open(report_path, 'w') as f:
        f.write(report_content)

    print(f"Successfully generated placeholder report at {report_path}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate a markdown report from terraform output.')
    parser.add_argument('--tf-output-log', required=True, help='Path to the terraform output log file.')
    parser.add_argument('--report-path', required=True, help='Path to write the final REPORT.md file.')
    args = parser.parse_args()

    main(args.tf_output_log, args.report_path)
