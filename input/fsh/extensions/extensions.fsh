// Extensions required by the Patient and blood pressure profiles.
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

// The blood pressure profile FHIR core ships closes component.value[x] to
// Quantity, so what a reading carries beside its two pressures cannot be a
// component. The three facts the protocol attaches to a reading are
// extensions instead.

Extension: HRReadingSequence
Id: hr-reading-sequence
Title: "Reading Sequence"
Description: "Which of the three blood pressure readings this is."
* ^status = #draft
* ^experimental = false
* ^purpose = "The protocol times three readings around the retinal capture and derives one value from them. The number says which reading a resource is, without a consumer having to sort them by time and hope none was entered late."
* ^context[0].type = #element
* ^context[0].expression = "Observation"
* value[x] only integer
* valueInteger 1..1 MS

Extension: HRReadingPosition
Id: hr-reading-position
Title: "Reading Position"
Description: "Whether the reading was taken before or after retinal capture."
* ^status = #draft
* ^experimental = false
* ^purpose = "One country allows the second reading either side of the retinal capture. The timing rule that checks the sequence needs to know which side was chosen."
* ^context[0].type = #element
* ^context[0].expression = "Observation"
* value[x] only CodeableConcept
* valueCodeableConcept 1..1 MS
* valueCodeableConcept from HRBloodPressurePositionVS (required)

Extension: HRReadingDevice
Id: hr-reading-device
Title: "Reading Device"
Description: "Which of the study's blood pressure monitors took the reading."
* ^status = #draft
* ^experimental = false
* ^purpose = "The protocol names two monitors and selects between them by participant size. Which one produced a reading is the first question asked when one site's values sit apart from the others. A reference to a Device resource would say the same, at the cost of a Device the sites would have to register; a code from the monitors the protocol names is enough."
* ^context[0].type = #element
* ^context[0].expression = "Observation"
* value[x] only CodeableConcept
* valueCodeableConcept 1..1 MS
* valueCodeableConcept from HRBloodPressureDeviceVS (required)
