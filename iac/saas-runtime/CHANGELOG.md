# Changelog

## [Unreleased] - 2025-07-24

### Added

- `just deploy-saas-end2end` target for a full end-to-end deployment test.
- Scripts for creating and managing SaaS Runtime resources:
    - `01-create-saas.sh`
    - `02-create-unit-kind.sh`
    - `03-build-and-push-blueprint.sh`
    - `04-create-release.sh`
    - `04a-reposition-uk-default.sh`
    - `05-create-unit.sh`
    - `06-provision-unit.sh`

### Fixed

- Corrected the `gcloud builds submit` command to use GCS for the build source.
- Removed unused `_TF_BLUEPRINT_BUCKET` substitution from the Cloud Build configuration.
