# FIXME: Terraform Folder Creation Error

This document tracks the error encountered during the `terraform apply` stage of the classroom setup.

## Error Details

The `google_folder` resource creation failed with the following error:

```
Error: Error creating folder 'class_2teachers_6students' in 'folders/791852209422': googleapi: Error 400: Operation disallowed by Organization Policy constraint due to missing or incorrect Tags
Details:
[
  {
    "@type": "type.googleapis.com/google.rpc.PreconditionFailure"
  }
]
, failedPrecondition

  with google_folder.classroom,
  on main.tf line 13, in resource "google_folder" "classroom":
  13: resource "google_folder" "classroom" {
```

## Analysis

This error indicates that the target Google Cloud organization (`sredemo.dev`, ID `791852209422`) has an [Organization Policy](https://cloud.google.com/resource-manager/docs/organization-policy/overview) that requires all new folders to be created with one or more specific [Tags](https://cloud.google.com/resource-manager/docs/tags/tags-overview).

## Action Required

To resolve this, the correct `tagKeys` and `tagValues` must be identified for the `sredemo.dev` organization and added to the `tags` section of the `etc/class_2teachers_6students.yaml` file.

Example:
```yaml
folder:
  # ...
  tags:
    tagKeys/123456789012: "tagValues/987654321098"
  # ...
```
