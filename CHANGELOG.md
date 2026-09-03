# Changelog

This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `HRPatient` and `HRExportPatient` profiles, constraining the tenant-held and
  sponsor-transferred forms of a study participant respectively.
- `HRTenant` and `HRAgeYears` extensions.
- Continuous integration: SUSHI compilation on every pull request, followed by a
  full IG Publisher build gated on the publisher's QA error count.

### Notes

- The canonical URL and package identifier are provisional pending confirmation.
- All artefacts are at `status: draft`.
