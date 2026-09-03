// Aliases for external terminologies referenced by this guide.

Alias: $v3-Confidentiality = http://terminology.hl7.org/CodeSystem/v3-Confidentiality
Alias: $consent-category = http://terminology.hl7.org/CodeSystem/consentcategorycodes
Alias: $consent-policy = http://terminology.hl7.org/CodeSystem/consentpolicycodes
Alias: $consent-scope = http://terminology.hl7.org/CodeSystem/consentscope
Alias: $attestation-mode = http://hl7.org/fhir/composition-attestation-mode
Alias: $doc-relationship = http://hl7.org/fhir/document-relationship-type

// Local. Slicing Consent.category by coding.system requires the system as a
// literal, so it cannot be expressed by referring to the CodeSystem by name.
Alias: $hr-consent-permission = https://fhir.savannahghi.org/ig/healthy-route/CodeSystem/hr-consent-permission
