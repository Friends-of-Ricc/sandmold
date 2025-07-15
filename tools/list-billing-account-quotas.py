#!/usr/bin/env python3

import argparse
import sys
from google.api_core.exceptions import GoogleAPIError
from google.cloud import cloudquotas_v1

def list_billing_account_quotas(billing_account_id: str):
    client = cloudquotas_v1.CloudQuotasClient()

    parent = f"billingAccounts/{billing_account_id}/locations/global"

    print(f"Listing quotas for billing account: {billing_account_id}...")

    try:
        for quota_info in client.list_quota_infos(parent=parent):
            print(f"---")
            print(f"Service: {quota_info.service}")
            print(f"Quota ID: {quota_info.quota_id}")
            print(f"Metric: {quota_info.metric}")
            print(f"Dimensions: {quota_info.dimensions}")
            print(f"Is Decreasable: {quota_info.is_decreasable}")
            print(f"Current Value: {quota_info.quota_details.value}")
            print(f"Default Value: {quota_info.quota_details.reset_value}")
            print(f"Unit: {quota_info.quota_details.unit}")
            print(f"---")

    except GoogleAPIError as e:
        print(f"Error listing quotas: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="List Google Cloud quotas for a given billing account ID."
    )
    parser.add_argument(
        "billing_account_id",
        help="The ID of the Google Cloud Billing Account (e.g., '012345-ABCDEF-123456')."
    )

    args = parser.parse_args()

    list_billing_account_quotas(args.billing_account_id)
