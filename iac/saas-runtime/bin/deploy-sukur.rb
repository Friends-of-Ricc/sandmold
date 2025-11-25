#!/usr/bin/env ruby
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


require 'yaml'
require 'json'
require 'optparse'

require 'fileutils'

# --- Configuration ---
# Load environment variables from common-setup.sh's .env files
# This is a simplified approach; a more robust solution might parse the .env files directly.
# For now, we'll assume these are set in the environment where this Ruby script is run.
GOOGLE_CLOUD_PROJECT = ENV['GOOGLE_CLOUD_PROJECT']
GOOGLE_CLOUD_REGION = ENV['GOOGLE_CLOUD_REGION']
TF_ACTUATOR_SA_EMAIL = ENV['TF_ACTUATOR_SA_EMAIL']

# --- Argument Parsing ---
options = {
  output_script_path: "tmp/generated_deployment_script.sh"
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} <SUKUR_YAML_FILE> [--output-script-path <PATH>]"

  opts.on("--output-script-path PATH", "Path to write the generated deployment script") do |path|
    options[:output_script_path] = path
  end
end.parse!

SUKUR_YAML_FILE = ARGV[0]

unless SUKUR_YAML_FILE
  puts "Error: SUKUR_YAML_FILE is required."
  puts OptionParser.new.help
  exit 1
end

# Ensure output directory exists
FileUtils.mkdir_p(File.dirname(options[:output_script_path]))

# --- Extract parameters from SUkUR YAML ---
sukur_config = YAML.load_file(SUKUR_YAML_FILE)

SAAS_NAME = sukur_config['spec']['saas_name']
UNIT_KIND_NAME = sukur_config['spec']['unit_kind_name']
RELEASE_NAME = sukur_config['spec']['release_name']
TERRAFORM_MODULE_DIR = sukur_config['spec']['terraform_module_dir']

# Extract instance_name from input_variables or set a default
instance_name_var = sukur_config['spec']['input_variables'].find { |var| var['name'] == 'instance_name' }
INSTANCE_NAME = instance_name_var ? instance_name_var['value'] : "default-instance-#{SAAS_NAME}"

# Extract input variables as a JSON string
INPUT_VARIABLES_JSON = sukur_config['spec']['input_variables'].to_json

# --- Cleanup Steps (best effort) ---
puts "🧹 Attempting best-effort cleanup for #{SAAS_NAME} (if any)..."

# Attempt to unset default release for Unit Kind
UNIT_KIND_FULL_NAME = "projects/#{GOOGLE_CLOUD_PROJECT}/locations/#{GOOGLE_CLOUD_REGION}/unitKinds/#{UNIT_KIND_NAME}"

# Use `system` to execute gcloud commands and `|| true` for best effort
if system("gcloud beta saas-runtime unit-kinds describe #{UNIT_KIND_NAME} --location=#{GOOGLE_CLOUD_REGION} --project=#{GOOGLE_CLOUD_PROJECT} &> /dev/null")
  puts "Attempting to unset default release for Unit Kind: #{UNIT_KIND_NAME}"
  system("gcloud beta saas-runtime unit-kinds update #{UNIT_KIND_NAME} --location=#{GOOGLE_CLOUD_REGION} --project=#{GOOGLE_CLOUD_PROJECT} --default-release=\"\" --quiet")
end

# --- Deployment Steps ---
puts "🚀 Generating deployment script for SUkUR: #{SAAS_NAME}"

# Write deployment steps to the generated script
generated_script_content = <<EOF
#!/bin/bash

set -euo pipefail

PROJECT_ROOT="#{Dir.pwd}"
source "${PROJECT_ROOT}/bin/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Deployment Steps for #{SAAS_NAME} ---

# STEP 1: Create SaaS Offering
bin/01-create-saas.sh --saas-name "#{SAAS_NAME}"

# STEP 2: Create Unit Kind
bin/02-create-unit-kind.sh --unit-kind-name "#{UNIT_KIND_NAME}" --saas-name "#{SAAS_NAME}"

# STEP 3: Build and Push Blueprint
bin/03-build-and-push-blueprint.sh --terraform-module-dir "#{TERRAFORM_MODULE_DIR}"

# STEP 4: Create Release
FULL_RELEASE_NAME=\$(bin/04-create-release.sh --release-name "#{RELEASE_NAME}" --unit-kind-name "#{UNIT_KIND_NAME}" --terraform-module-dir "#{TERRAFORM_MODULE_DIR}" --input-variables-json '#{INPUT_VARIABLES_JSON}')

# STEP 5: Reposition Unit Kind Default
bin/04a-reposition-uk-default.sh --unit-kind-name "#{UNIT_KIND_NAME}" --release-name "\${FULL_RELEASE_NAME##*/}"

# STEP 6: Create Unit
bin/05-create-unit.sh --instance-name "#{INSTANCE_NAME}" --unit-kind-name "#{UNIT_KIND_NAME}"

# STEP 7: Provision Unit
bin/06-provision-unit.sh --unit-name "#{INSTANCE_NAME}" --release-name "\${FULL_RELEASE_NAME##*/}" --input-variables-json '#{INPUT_VARIABLES_JSON}'

echo "✅ SUkUR deployment for #{SAAS_NAME} complete."
EOF

File.write(options[:output_script_path], generated_script_content)
FileUtils.chmod('+x', options[:output_script_path])

puts "Generated deployment script: #{options[:output_script_path]}"
puts "Please inspect the script and execute it manually to perform the deployment."
