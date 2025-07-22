#!/bin/bash

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

        # Ignore private directories
        if [[ "$app_name" == .* ]]; then
            continue
        fi

        # Skip the script's own directory and special directories
        if [[ "$app_name" == "t" ]] || [[ "$app_name" == "templates" ]] || [[ "$app_name" == "generate_readme.sh" ]]; then
            continue
        fi

        # Extract description and emoji from blueprint.yaml
        description=""
        emoji="📦"
        blueprint_path="$app_dir/blueprint.yaml"

        if [ -f "$blueprint_path" ]; then
            # Get description
            if grep -q "description: *|" "$blueprint_path"; then
                # Multi-line description
                description=$(awk '/description: *\|/ {getline; print; exit}' "$blueprint_path" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
            else
                # Single-line description
                description=$(grep -m 1 "description:" "$blueprint_path" | cut -d: -f2- | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/^"//' -e 's/"$//')
            fi

            # Get emoji
            emoji_line=$(grep "emoji:" "$blueprint_path" || true)
            if [ -n "$emoji_line" ]; then
                emoji_val=$(echo "$emoji_line" | cut -d: -f2- | tr -d " \'\"")
                if [ -n "$emoji_val" ]; then
                    emoji=$emoji_val
                fi
            fi
        fi

        # Check for scripts
        start_script="-"
        stop_script="-"
        status_script="-"
        errors=""

        if [ -f "$app_dir/start.sh" ]; then
            start_script="✅"
        else
            errors+=" start.sh"
        fi

        if [ -f "$app_dir/stop.sh" ]; then
            stop_script="✅"
        else
            errors+=" stop.sh"
        fi

        if [ -f "$app_dir/status.sh" ]; then
            status_script="✅"
        else
            errors+=" status.sh"
        fi

        # App Name and link
        app_line="* $emoji **$app_name**"
        if [ -f "$blueprint_path" ]; then
            app_line+=" ([blueprint]($app_name/blueprint.yaml))"
        fi

        # Description
        if [ -n "$description" ]; then
            app_line+=": $description"
        fi

        # Scripts
        app_line+=" | Create: $start_script, Destroy: $stop_script, Status: $status_script"

        # Errors
        if [ -n "$errors" ]; then
            app_line+=" | Errors: missing$errors"
        fi

        echo "$app_line" >> "$README"
    fi
done

# Append the footer
cat "$AFTER" >> "$README"
