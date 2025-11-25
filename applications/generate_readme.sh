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


set -e

README="README.md"
BEFORE="_README.before.md"
AFTER="_README.after.md"

# Start with the header
cat "$BEFORE" > "$README"

# Add the Applications section
echo -e "
## Applications
" >> "$README"

# Iterate through each application directory
for app_dir in */; do
    if [ -d "$app_dir" ]; then
        app_name=$(basename "$app_dir")

        # Ignore private directories and files
        if [[ "$app_name" == .* ]] || [[ ! -d "$app_dir" ]]; then
            continue
        fi

        # Skip special directories
        if [[ "$app_name" == "t" ]] || [[ "$app_name" == "templates" ]] || [[ "$app_name" == "generate_readme.sh" ]] || [[ "$app_name" == "_README.before.md" ]] || [[ "$app_name" == "_README.after.md" ]]; then
            continue
        fi

        blueprint_path="$app_dir/blueprint.yaml"
        errors_list=()
        script_emojis=()
        description=""
        emoji="📦"

        # First, check for all potential errors
        if ! [ -f "$blueprint_path" ]; then
            errors_list+=("blueprint.yaml")
        fi
        if ! [ -f "$app_dir/start.sh" ]; then
            errors_list+=("start.sh")
        fi
        if ! [ -f "$app_dir/stop.sh" ]; then
            errors_list+=("stop.sh")
        fi
        if ! [ -f "$app_dir/status.sh" ]; then
            errors_list+=("status.sh")
        fi

        # Now, get details if files exist
        if [ -f "$blueprint_path" ]; then
            if grep -q "description: *|" "$blueprint_path"; then
                description=$(awk '/description: *\|/ {f=1; next} f==1 && NF {print; exit}' "$blueprint_path" | sed -e 's/^[ 	]*//' -e 's/[ 	]*$//')
            else
                description=$(grep -m 1 "description:" "$blueprint_path" | cut -d: -f2- | sed -e 's/^[ 	]*//' -e 's/[ 	]*$//' -e 's/^"//' -e 's/"$//')
            fi

            emoji_line=$(grep "emoji:" "$blueprint_path" | grep -v '^ *#' || true)
            if [ -n "$emoji_line" ]; then
                emoji_val=$(echo "$emoji_line" | cut -d: -f2- | sed -e 's/^[ 	]*//' -e 's/[ 	]*$//' -e 's/^"//' -e 's/"$//' -e "s/'//g")
                if [ -n "$emoji_val" ]; then
                    emoji=$emoji_val
                fi
            fi
        fi

        if [ -f "$app_dir/start.sh" ]; then
            script_emojis+=("🚀")
        fi
        if [ -f "$app_dir/stop.sh" ]; then
            script_emojis+=("💥")
        fi
        if [ -f "$app_dir/status.sh" ]; then
            script_emojis+=("ℹ️")
        fi

        # Build the line
        app_line="* $emoji **$app_name**"
        if [ -f "$blueprint_path" ]; then
            app_line+=" ([blueprint]($app_name/blueprint.yaml))"
        fi

        if [ -n "$description" ]; then
            app_line+=": \"*$description*\""
        fi

        if [ ${#script_emojis[@]} -gt 0 ]; then
            emojis_str=$(IFS=' '; echo "${script_emojis[*]}")
            app_line+=" | $emojis_str"
        fi

        if [ ${#errors_list[@]} -gt 0 ]; then
            errors_str=$(IFS=' '; echo "${errors_list[*]}")
            app_line+=" | Errors: missing $errors_str"
        fi

        echo "$app_line" >> "$README"
    fi
done

# Append the footer
cat "$AFTER" >> "$README"
