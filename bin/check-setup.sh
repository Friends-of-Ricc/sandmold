#!/bin/bash
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


set -euo pipefail

# --- Helper functions for logging ---
# Thank you https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
if test -t 1; then
    # see if it supports colors...
    ncolors=$(tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

log_info() {
    echo "${green:-}✔${normal:-} ${1}"
}
log_warning() {
    echo "${yellow:-}🤔 ${1}${normal:-}"
}
log_error() {
    echo "${red:-}🛑 ${1}${normal:-}"
}
log_action() {
    echo "${blue:-}🚀 ${1}${normal:-}"
}
log_fatal() {
    log_error "$1"
    exit 1
}


cd "$(git rev-parse --show-toplevel)"

if [ ! -f ".env" ]; then
  log_fatal ".env file not found. Please create it from .env.dist."
fi

. .env

# Check gcloud identity
echo "🔎 Checking gcloud identity..."
gcloud_user=$(gcloud config get-value account --quiet)
if [ "$gcloud_user" != "$GCLOUD_IDENTITY" ]; then
  log_fatal "gcloud is not authenticated as $GCLOUD_IDENTITY (currently $gcloud_user). Please run 'just auth' to authenticate."
fi
log_info "gcloud user is correct ($GCLOUD_IDENTITY)"
echo

# Check billing account
echo "🔎 Checking billing account..."
if [ -z "${BILLING_ACCOUNT_ID:-}" ]; then
    log_error "BILLING_ACCOUNT_ID is not set in your .env file."
    echo "Here is a list of your available billing accounts:"
    bin/list-billing-accounts.py
    log_fatal "Please add the correct BILLING_ACCOUNT_ID to your .env file and run this script again."
fi

is_open=$(gcloud billing accounts describe "$BILLING_ACCOUNT_ID" --format="value(open)" --quiet 2>/dev/null)
if [ "$is_open" != "True" ]; then
  log_fatal "Billing account '$BILLING_ACCOUNT_ID' is not open or you don't have permissions. Please check BILLING_ACCOUNT_ID in your .env file."
fi
display_name=$(gcloud billing accounts describe "$BILLING_ACCOUNT_ID" --format="value(displayName)" --quiet 2>/dev/null)
log_info "Billing account '$BILLING_ACCOUNT_ID' ($display_name) is open."
echo

# Check organization
echo "🔎 Checking organization..."
if [ -z "${ORGANIZATION_ID:-}" ]; then
    log_error "ORGANIZATION_ID is not set in your .env file."
    echo "Here is a list of your available organizations:"
    gcloud organizations list
    log_fatal "Please add the correct ORGANIZATION_ID to your .env file and run this script again."
fi

org_name=$(gcloud organizations describe "$ORGANIZATION_ID" --format="value(displayName)" --quiet 2>/dev/null)
if [ -z "$org_name" ]; then
    log_fatal "Organization '$ORGANIZATION_ID' not found or you don't have permission to access it. Please check ORGANIZATION_ID in your .env file."
fi
log_info "Organization '$ORGANIZATION_ID' found: $org_name"
echo

# Check parent folder
echo "🔎 Checking parent folder..."
if [ -z "${PARENT_FOLDER_ID:-}" ]; then
    log_error "PARENT_FOLDER_ID is not set in your .env file."
    echo "Here is a list of your available folders:"
    gcloud resource-manager folders list --organization="$ORGANIZATION_ID"
    echo
    log_warning "If you don't have a folder, you can create one with the following command:"
    echo "gcloud resource-manager folders create --display-name=\"sandmold-tests\" --organization=\""$ORGANIZATION_ID"\""
    log_fatal "Please add the correct PARENT_FOLDER_ID to your .env file and run this script again."
fi

error_output=$(mktemp)
if ! folder_name=$(gcloud resource-manager folders describe "$PARENT_FOLDER_ID" --format="value(displayName)" --quiet 2> "$error_output"); then
    log_fatal "Folder '$PARENT_FOLDER_ID' not found or you don't have permission to access it. Please check PARENT_FOLDER_ID in your .env file. Error: $(cat "$error_output")"
    rm -f "$error_output"
fi
rm -f "$error_output"
log_info "Parent folder '$PARENT_FOLDER_ID' found: $folder_name"
echo


# Check project creation and deletion
if [ "${CREATE_AND_DELETE_TEST_PROJECT:-false}" = "true" ] || [ "${CREATE_AND_DELETE_TEST_PROJECT:-false}" = "TRUE" ]; then
    echo "🔎 Performing project creation and deletion test..."
    random_id=$(date +%s)
    project_id="tmp-deleteme-$random_id"

    # Create the project
    if ! gcloud projects create "$project_id" --folder="$PARENT_FOLDER_ID" --quiet; then
        log_fatal "Failed to create temporary project '$project_id'. Please check your permissions."
    fi
    log_info "Successfully created temporary project '$project_id'."

    # Verify the project exists
    if ! gcloud projects list --filter="project_id=$project_id" --format="value(project_id)" --quiet | grep -q "$project_id"; then
        log_warning "Could not verify the existence of temporary project '$project_id' immediately after creation. This might be due to propagation delays."
    else
        log_info "Successfully verified the existence of temporary project '$project_id'."
    fi

    # Delete the project
    if ! gcloud projects delete "$project_id" --quiet; then
        log_fatal "Failed to delete temporary project '$project_id'. Please delete it manually."
    fi
    log_info "Successfully deleted temporary project '$project_id'."
    echo
else
    log_warning "Skipping project creation test. To enable it, set CREATE_AND_DELETE_TEST_PROJECT=true in your .env file."
    echo
fi

# Check for GOOGLE_CLOUD_PROJECT
echo "🔎 Checking for GOOGLE_CLOUD_PROJECT..."
if [ -z "${GOOGLE_CLOUD_PROJECT:-}" ]; then
    log_warning "GOOGLE_CLOUD_PROJECT is not set in your .env file."
    log_action "I will now generate the commands to create a new project for you."

    random_suffix="$(date +%s | tail -c 5)"
    new_project_id="sandmold-base-project-$random_suffix"

    echo
    log_action "Please run the following commands manually:"
    echo
    echo "gcloud projects create \"$new_project_id\" --organization=\"$ORGANIZATION_ID\""
    echo "gcloud billing projects link \"$new_project_id\" --billing-account=\"$BILLING_ACCOUNT_ID\""
    echo "gcloud config set project \"$new_project_id\""
    echo
    log_action "Then, add the following line to your .env file:"
    echo
    echo "GOOGLE_CLOUD_PROJECT=$new_project_id"
    echo
    log_fatal "Once you have updated the .env file, please run 'just check-setup' again."
else
    if gcloud projects describe "${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
        log_info "GOOGLE_CLOUD_PROJECT '${GOOGLE_CLOUD_PROJECT}' exists and is accessible."
    else
        log_fatal "GOOGLE_CLOUD_PROJECT '${GOOGLE_CLOUD_PROJECT}' not found or you don't have permission to access it."
    fi
fi


echo

echo "🎉 All checks passed! Your setup seems correct."
