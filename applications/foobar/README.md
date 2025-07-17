# Foobar Application

## Purpose

The `foobar` application is a template application for the `sandmold` project. It provides a basic structure and a set of common functionalities that can be used as a starting point for creating new applications.

This application does nothing on its own, but it demonstrates the following key concepts:

*   **Application Scaffolding**: The basic directory structure for a sandmold application.
*   **Blueprint Configuration**: How to use `blueprint.yaml` to define application metadata and required environment variables.
*   **Shared Scripting Logic**: How to use a `_common.sh` script to share code between the `start`, `stop`, and `status` scripts.
*   **Environment Validation**: How to ensure that all required environment variables are set before running any application logic.
*   **Structured Logging**: How to write structured JSON logs to Google Cloud Logging.

## Files

*   `blueprint.yaml`: Defines the application's name and the environment variables it requires.
*   `_common.sh`: A shared library of shell functions for common tasks like environment validation and logging.
*   `start.sh`: A script that "starts" the application (in this case, it just logs to GCP).
*   `stop.sh`: A script that "stops" the application (logs to GCP).
*   `status.sh`: A script that checks the "status" of the application (logs to GCP).
*   `README.md`: This file.

## Usage

To use the scripts, you must first set the environment variables defined in `blueprint.yaml`:

```bash
export GOOGLE_CLOUD_PROJECT="your-gcp-project"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/credentials.json"
export GOOGLE_CLOUD_REGION="your-gcp-region"
```

Then, you can run the scripts:

```bash
./applications/foobar/start.sh
./applications/foobar/status.sh
./applications/foobar/stop.sh
```

## Creating a New Application from this Template

1.  Copy the entire `applications/foobar` directory to a new directory (e.g., `applications/my-new-app`).
2.  In the new directory, modify `blueprint.yaml` to set the `metadata.name` to your new application's name and update the `spec.variables` as needed.
3.  Modify the `start.sh`, `stop.sh`, and `status.sh` scripts to perform the actual actions required by your application, while still leveraging the `_common.sh` script for validation and logging.
