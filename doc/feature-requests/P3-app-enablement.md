## Folder App-Enablement

I've enabled App-enablement preview in my `test-sandmold` test folder in sredemo.dev.

Docs: https://cloud.google.com/resource-manager/docs/manage-applications

Feature request: create some sort of application, maybe called "sandmold-test" which spans across the folder and multiple projects.
I don't know how it works, so I first ask Gemini to:

1. Read documentation
2. Make a proposal under `doc/feature-requests/FOLDER_APP_PLAN.md` which owner can then review.

## Cut and paste of UI docs

App-enablement preview
Applications APIs

An application is a functional grouping of services and workloads across multiple projects in a folder. Folder settings is the first step in a multi-step process to use application-centric capabilities on Google Cloud. Learn more

APIs enabled

Linked management project
Application enablement provisions a management project in the Google Cloud folder. This project is where metadata for applications is stored and referenced by Google Cloud services. The management project ID can be used in command lines and infrastructure as code. Learn more

* Name: `test-sandmold-mp` -> https://console.cloud.google.com/iam-admin/settings?project=google-mpf-1000371719973&inv=1&invt=Ab25rA
* ID: `google-mpf-1000371719973`

1. Link a billing account to the management project
A billing account must be assigned to the linked management project before applications can be created. This billing account will be used for costs associated with storing metadata. Learn more  or manage billing

2. Assign IAM roles and permissions
User IAM roles and permissions must be assigned for all enabled APIs before applications can be created. Learn more  or manage IAM

3. Create applications
After the previous three steps have been completed, applications can be created in this folder using App Hub or App Design Center.
