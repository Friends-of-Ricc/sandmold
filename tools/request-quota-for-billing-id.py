#!/usr/bin/env python3

"""Riccardo: here you find a POST that asks for new quota for a billing account.

https://cloud.google.com/docs/quotas/implement-common-use-cases#decrease_a_quota

Note: this script is currently broken.
"""

import argparse
import sys
import os
from google.api_core.exceptions import GoogleAPIError
from google.cloud import service_usage_v1

def request_quota_increase(billing_account_id: str, new_limit: int = 300):
    """
    Requests a quota increase for 'Projects Count' associated with a billing account.

    Args:
        billing_account_id: The ID of the Google Cloud Billing Account (e.g., "012345-ABCDEF-123456").
        new_limit: The new desired quota limit for 'Projects Count'.
    """
    client = service_usage_v1.ServiceUsageClient()

    # The specific quota metric for 'Projects Count' for a billing account.
    # This is typically associated with the Cloud Resource Manager API.
    metric_name = "projects_count"
    service_name = "cloudresourcemanager.googleapis.com"

    # The limit name often corresponds to the metric name.
    limit_name = "projects_count" # Assuming the limit name is the same as the metric name

    # The parent for the override request for a billing account-scoped quota.
    parent = f"billingAccounts/{billing_account_id}/services/{service_name}/consumerQuotaMetrics/{metric_name}/limits/{limit_name}"

    # Define the override. Dimensions are crucial for billing account specific quotas.
    # The 'billing_account' dimension is used here.
    override = service_usage_v1.QuotaOverride(
        metric=f"billingAccounts/{billing_account_id}/services/{service_name}/consumerQuotaMetrics/{metric_name}",
        unit="1/project", # Common unit for project count
        new_limit=new_limit,
        dimensions={"billing_account": billing_account_id},
        justification=f"Requesting increase for project creation quota for billing account {billing_account_id} to support classroom environments."
    )

    request = service_usage_v1.CreateAdminOverrideRequest(
        parent=parent,
        override=override
    )

    print(f"Attempting to request quota increase for billing account: {billing_account_id} to {new_limit}...")
    print(f"Request details: {request}")

    try:
        operation = client.create_admin_override(request=request)
        print("Quota increase request submitted. Waiting for operation to complete...")
        response = operation.result() # This will block until the operation is done
        print(f"Quota increase operation completed successfully: {response}")
    except GoogleAPIError as e:
        print(f"Error requesting quota increase: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Request a Google Cloud quota increase for a given billing account ID."
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

    request_quota_increase(args.billing_account_id, args.new_limit)
