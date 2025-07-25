#!/bin/bash
#
# Common setup script to be sourced by other scripts.
# It loads environment variables and defines derived constants.

# Determine the absolute path of the project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"

# Source the core project constants
source "${PROJECT_ROOT}/.env"

# Source the default SaaS values
if [ -f "${PROJECT_ROOT}/.env.saas_defaults" ]; then
    source "${PROJECT_ROOT}/.env.saas_defaults"
fi

# Define and export derived variables
export TF_ACTUATOR_SA_EMAIL="sandmold-tf-actuator@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
export TF_BLUEPRINT_BUCKET="sandmold-tf-blueprints-${GOOGLE_CLOUD_PROJECT}"
export SAAS_SERVICE_ACCOUNT="service-${PROJECT_NUMBER}@gcp-sa-saasservicemgmt.iam.gserviceaccount.com"
