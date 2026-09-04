// A minimal participant and one consent, referenced by the participation
// examples. Invented data.

Instance: ExampleParticipant
InstanceOf: HRPatient
Usage: #example
Title: "Example participant"
Description: "A participant as held within a site tenant, carrying the identifiers the site needs to recognise them on return."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* identifier[participantId].system = "https://fhir.savannahghi.org/sid/optimalhealth-participant"
* identifier[participantId].value = "HR-000123"
* name[0].family = "Otieno"
* name[0].given[0] = "Adhiambo"
* gender = #female
* birthDate = "1971-06-02"

Instance: ExampleConsentParticipation
InstanceOf: HRConsent
Usage: #example
Title: "Example consent to study participation"
Description: "One permission, recorded as its own resource so that it can be withdrawn without touching the permissions the participant kept."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #active
* category[permission] = HRConsentPermissionCS#study-participation
* subject = Reference(ExampleParticipant)
* date = "2026-04-14"
* grantor = Reference(ExampleParticipant)
* grantee[0] = Reference(ExampleStudySite)
* decision = #permit
* policyBasis.url = "https://example.org/icf/country-a/v1.0/en"
* verification[0].verified = true
* verification[0].verifiedBy = Reference(ExampleStudyNurse)
* verification[0].verificationDate = "2026-04-14"
