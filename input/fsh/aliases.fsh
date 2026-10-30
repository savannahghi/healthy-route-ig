// Aliases for external terminologies referenced by this guide.

Alias: $v3-Confidentiality = http://terminology.hl7.org/CodeSystem/v3-Confidentiality
Alias: $consent-category = http://terminology.hl7.org/CodeSystem/consentcategorycodes
Alias: $consent-policy = http://terminology.hl7.org/CodeSystem/consentpolicycodes
Alias: $consent-scope = http://terminology.hl7.org/CodeSystem/consentscope
Alias: $attestation-mode = http://hl7.org/fhir/composition-attestation-mode
Alias: $doc-relationship = http://hl7.org/fhir/document-relationship-type

// Local. Slicing Consent.category by coding.system requires the system as a
// literal, so it cannot be expressed by referring to the CodeSystem by name.
Alias: $hr-consent-permission = https://fhir.optimalhealth.org/ig/healthy-route/CodeSystem/hr-consent-permission
Alias: $hr-observation-category = https://fhir.optimalhealth.org/ig/healthy-route/CodeSystem/hr-observation-category
Alias: $v3-RoleCode = http://terminology.hl7.org/CodeSystem/v3-RoleCode
Alias: $organization-type = http://terminology.hl7.org/CodeSystem/organization-type
Alias: $party-role = http://terminology.hl7.org/CodeSystem/research-study-party-role
Alias: $subject-state = http://terminology.hl7.org/CodeSystem/research-subject-state
Alias: $prim-purp-type = http://terminology.hl7.org/CodeSystem/research-study-prim-purp-type
Alias: $iso3166 = urn:iso:std:iso:3166
Alias: $loinc = http://loinc.org
Alias: $ucum = http://unitsofmeasure.org
Alias: $sct = http://snomed.info/sct
Alias: $dcm = http://dicom.nema.org/resources/ontology/DCM
Alias: $obs-category = http://terminology.hl7.org/CodeSystem/observation-category
Alias: $v3-ActCode = http://terminology.hl7.org/CodeSystem/v3-ActCode
Alias: $icd11 = http://id.who.int/icd/release/11/mms
Alias: $condition-clinical = http://terminology.hl7.org/CodeSystem/condition-clinical
Alias: $condition-ver-status = http://terminology.hl7.org/CodeSystem/condition-ver-status
Alias: $condition-category = http://terminology.hl7.org/CodeSystem/condition-category
Alias: $v2-0487 = http://terminology.hl7.org/CodeSystem/v2-0487
Alias: $hr-measurement = https://fhir.optimalhealth.org/ig/healthy-route/CodeSystem/hr-measurement
Alias: $hr-medicine = https://fhir.optimalhealth.org/CodeSystem/hr-medicine
// The study service lists a study's forms by this tag, with the study's identifier as the code.
Alias: $optimalhealth-study = https://fhir.optimalhealth.org/sid/optimalhealth-study
