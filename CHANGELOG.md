# Changelog

This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- The visit forms' terminology: the `hr-measurement` code system for the
  questions LOINC does not cover and the values the study derives; answer scales
  for use status, the frequency scale, physical activity at work, reactive or
  non-reactive, the blood pressure reading position and monitor, and the eye;
  the medicine route, dose form and frequency scales; the laboratory units.
- `HRCondition`, `HRMedicationStatement` and `HRSpecimen`.
- `HREncounter.type` from a visit part code system, and `partOf`, so the samples
  and the imaging can carry their own dates inside one visit.
- The blood pressure reading's sequence, position and monitor as extensions on
  `HRBloodPressure`, because the core profile closes components to quantities.
- Examples for the interview, a reported condition, a reported medicine, the
  samples and the visit parts.

### Changed

- The urine dipstick is coded 20454-5, the ordinal presence, instead of the
  quantitative 5804-0.
- Imaging laterality is bound to the guide's own eye code system instead of
  SNOMED CT, which the programme does not license.
- `specimen` on `HRObservation`, `HRServiceRequest` and `HRDiagnosticReport`
  references `HRSpecimen`.

- `HRPatient` and `HRExportPatient` profiles, constraining the tenant-held and
  sponsor-transferred forms of a study participant respectively.
- `HRTenant` and `HRAgeYears` extensions.
- Continuous integration: SUSHI compilation on every pull request, followed by a
  full IG Publisher build gated on the publisher's QA error count.

### Notes

- The canonical URL and package identifier are provisional pending confirmation.
- All artefacts are at `status: draft`.
