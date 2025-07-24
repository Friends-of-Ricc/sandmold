#!/bin/bash
#
# Common setup script to be sourced by other scripts.
# It loads environment variables and defines derived constants.

# Source the core project constants
source "$(dirname "$0")/../.env"

# Source the default SaaS values
if [ -f "$(dirname "$0")/../.env.saas_defaults" ]; then
    source "$(dirname "$0")/../.env.saas_defaults"
fi

# Define and export derived variables
export TF_ACTUATOR_SA_EMAIL="sandmold-tf-actuator@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
export TF_BLUEPRINT_BUCKET="sandmold-tf-blueprints-${GOOGLE_CLOUD_PROJECT}"
export SAAS_SERVICE_ACCOUNT="service-${PROJECT_NUMBER}@gcp-sa-saasservicemgmt.iam.gserviceaccount.com"
