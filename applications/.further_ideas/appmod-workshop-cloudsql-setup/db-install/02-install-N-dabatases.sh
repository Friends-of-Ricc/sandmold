# From: https://gist.github.com/mauripsale/d772de9634fd28d5d5268d8a12d68261

# Loop from 2 to 101 (to create image_catalog_02 to image_catalog_101)
for i in $(seq 2 101); do
  database_name="image_catalog_$(printf %02d $i)"  # Format with leading zero if needed

  gcloud sql databases create "$database_name" \
    --instance=appmod-phpapp \
    --charset=utf8  # Changed to utf8

  # Check the exit status of the gcloud command
  if [[ $? -eq 0 ]]; then
    echo "Successfully created database: $database_name"
  else
    echo "Error creating database: $database_name"
    # You might want to add more error handling here, like exiting the script
    # or logging the error.  For example:
    # exit 1  # Uncomment to exit the script on the first error
  fi

done

echo "Finished creating databases."
