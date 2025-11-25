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


import argparse
import sys
import os
from google.api_core.exceptions import GoogleAPIError
from google.cloud import cloudquotas_v1

def request_quota_reduction(
    billing_account_id: str,
    new_limit: int,
    service_name: str = "cloudresourcemanager.googleapis.com",
    quota_id: str = "projects_count",
):
    """
    Requests a quota reduction for a specific quota associated with a billing account.

    Args:
        billing_account_id: The ID of the Google Cloud Billing Account.
        new_limit: The new desired quota limit.
        service_name: The name of the service (e.g., "cloudresourcemanager.googleapis.com").
        quota_id: The ID of the quota (e.g., "projects_count").
    """
    client = cloudquotas_v1.CloudQuotasClient()

    # The parent for billing account-scoped quota preferences is:
    # billingAccounts/{billing_account_id}/locations/global
    parent = f"billingAccounts/{billing_account_id}/locations/global"

    # Construct the QuotaConfig object with the preferred_value
    quota_config = cloudquotas_v1.QuotaConfig(
        preferred_value=new_limit
    )

    # Construct the QuotaPreference object
    quota_preference = cloudquotas_v1.QuotaPreference(
        service=service_name,
        quota_id=quota_id,
        quota_config=quota_config,
        justification=f"Requesting quota reduction for {quota_id} on {service_name} for billing account {billing_account_id} to {new_limit}."
    )

    # Construct the request
    request = cloudquotas_v1.CreateQuotaPreferenceRequest(
        parent=parent,
        quota_preference=quota_preference,
        quota_preference_id=f"{service_name.replace(".", "_")}_{quota_id}_reduction", # Unique ID for the preference
    )

    print(f"Attempting to request quota reduction for billing account: {billing_account_id} to {new_limit}...")
    print(f"Request details: {request}")

    try:
        operation = client.create_quota_preference(request=request)
        print("Quota reduction request submitted. Waiting for operation to complete...")
        response = operation.result()  # This will block until the operation is done
        print(f"Quota reduction operation completed successfully: {response}")
    except GoogleAPIError as e:
        print(f"Error requesting quota reduction: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Request a Google Cloud quota reduction for a given billing account ID."
    )
    parser.add_argument(
        "billing_account_id",
        help="The ID of the Google Cloud Billing Account (e.g., '012345-ABCDEF-123456')."
    )
    parser.add_argument(
        "--new-limit",
        type=int,
        default=300,
        help="The new desired quota limit for 'Projects Count'. Default is 300."
    )

    args = parser.parse_args()

    request_quota_reduction(args.billing_account_id, args.new_limit)