// Extensions required by the Patient profiles.
//
// Extensions are added only where no core element carries the information.
// Each one is a element the sponsor's ingestion must be told about, so the set
// is kept as small as the requirements allow.

Extension: HRTenant
Id: hr-tenant
Title: "Tenant"
Description: "Identifies the site tenant that owns the resource."
* ^status = #draft
* ^experimental = false
* ^purpose = "Records are partitioned by tenant. Every resource carries its tenant identifier so that partition membership is a property of the record rather than of the storage location."
* ^context[0].type = #element
* ^context[0].expression = "Resource"
* value[x] only Identifier
* valueIdentifier 1..1 MS
* valueIdentifier ^short = "Site tenant identifier"

Extension: HRAgeYears
Id: hr-age-years
Title: "Age in Years"
Description: "Participant age in completed years at the time of enrolment."
* ^status = #draft
* ^experimental = false
* ^purpose = "Carried on the exported Patient in place of birthDate. Age is required for the CKD-EPI 2021 calculation and as a model input, whereas a full date of birth is not. In a cohort of this size, a date of birth combined with a site and an encounter date approaches a unique identifier."
* ^context[0].type = #element
* ^context[0].expression = "Patient"
* value[x] only integer
* valueInteger 1..1 MS
* valueInteger ^short = "Completed years"
