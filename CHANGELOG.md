# Changelog

This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- The Ghana eligibility checklist, `hr-eligibility-gh`, tagged for the study
  `HR-GH`. It asks Uganda's questions under Uganda's keys, and one more: the
  Ghana protocol (v0.3) ends the screening on a negative dipstick unless the
  participant has an established CKD diagnosis, so `established-ckd` is asked
  when the dipstick is negative. The code joins `hr-measurement`, and the
  eligibility map extracts it when a form asks it, so one map serves both
  countries.

### Changed

- The vitals, diet and activity, and laboratory maps write the values their
  forms calculate as Observations under the same codes, each naming the
  Observations it was calculated from in `derivedFrom`. The mean blood pressure
  is a blood pressure Observation with no reading number, timed at the later
  of the two readings it averages. The derived laboratory values stay out of the
  DiagnosticReport, which lists only what the laboratory returned.

- The Uganda vitals, diet and activity, and laboratory forms calculate the
  values they hold the answers for, as read-only items with an SDC calculated
  expression: body mass index, the waist-to-hip ratio and the mean of readings
  two and three; the weekly minutes of activity, whether they meet the WHO
  recommendation, and whether fruit and vegetables are both eaten five days or
  more; and the CKD-EPI 2021 eGFR with the creatinine, age and sex it used. The
  laboratory form takes age and sex from its launch context. `egfr-age` and
  `egfr-sex` join the `hr-measurement` code system, and `tests/run-calculations.js`
  checks every formula.

- `HRConsent` may record the whole signed form as one decision. The permission
  code becomes optional, so a study that takes consent as one signature carries
  HL7's generic patient consent category (LOINC 59284-0) instead, and
  per-permission consents remain possible.

### Fixed

- `HRConsentEvidence.securityLabel` slices on the coding system, and the
  confidentiality slice now fixes that system. Assigning only the code left the
  discriminator without a value, so a validator could not match any label to the
  slice and rejected every signed page.
- `HRResearchStudy.recruitment` and its `targetNumber` are optional. The study
  service does not record a target yet, and a required element would fail every
  study it writes.

### Added

- The visit forms' terminology: the `hr-measurement` code system for the
  questions LOINC does not cover and the values the study derives; answer scales
  for use status, the frequency scale, physical activity at work, reactive or
  non-reactive, the blood pressure reading position and monitor, and the eye;
  the medicine route, dose form and frequency scales; the laboratory units.
- `HRCondition`, `HRMedicationStatement` and `HRSpecimen`.
- `HREncounter.type` from an encounter type code system whose one code is the
  study visit. The visit is one encounter; the samples and the imaging keep
  their own dates on the resources they become.
- `HREncounter` names its study through HL7's `workflow-researchStudy`
  extension, since an R5 Encounter has no element for it.
- The blood pressure reading's sequence, position and monitor as extensions on
  `HRBloodPressure`, because the core profile closes components to quantities.
- Examples for the interview, a reported condition, a reported medicine and the
  samples.

- The seven Uganda visit forms as Questionnaires, with item keys equal to the
  codes their answers become.
- One StructureMap per form, under `input/maps`, turning a response into the
  resources this guide profiles with ids derived from the response.
- An example response per form, and a replay test that runs every example
  through its map with the R5 engine and compares the Bundle with the one
  committed under `tests/expected`.
- `tests/run-on-hapi.py`, which runs every example on a real HAPI R5 server with
  the SIL `$extract` provider, commits the Bundle, saves it again to prove the ids
  are reused, and validates every resource against the profile it declares.
- A narrative page on the forms, their keys and what each becomes.
- A job that loads the guide's Questionnaires, StructureMaps, CodeSystems,
  ValueSets and StructureDefinitions from the built package into the study
  service's FHIR store on every push to `main`, one GitHub environment per
  store (`testing` for now). The loading lives in
  `scripts/load-package.py`, which `tests/run-on-hapi.py` now uses too. Runs on
  `main` queue instead of cancelling each other, so a load or a site sync is
  never stopped part way.

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
