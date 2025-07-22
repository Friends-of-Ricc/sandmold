#!/bin/bash
#
# Attempts to provision a specific SaaS Unit.
#

set -euo pipefail

if [ -z "$1" ]; then
    echo "Usage: $0 <unit-name>"
    echo "  <unit-name>: The name of the SaaS Unit to provision."
    exit 1
fi

UNIT_NAME=$1

echo "Direct provisioning of a specific Unit via CLI is not directly supported by gcloud beta saas-runtime commands."
echo "Provisioning is triggered by creating a Rollout (see bin/07-create-rollout.sh)."
echo "Please ensure a Rollout has been created to provision Unit: ${UNIT_NAME}"
