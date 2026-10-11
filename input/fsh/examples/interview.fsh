// What the interview records: the answers as answers, and what a Yes asserts.
//
// The history form's answers are kept as Observations under their item codes so
// the form can be read back as it was filled. A Yes to diabetes, hypertension
// or chronic kidney disease is also a Condition, which is where a consumer
// looks for a diagnosis. The participant and the visit are the ones in the
// other example files. Data is invented.

Instance: ExampleHistoryDiabetes
InstanceOf: HRObservation
Usage: #example
Title: "History: diabetes, as reported"
Description: "The answer to the diabetes question on the history form, kept under its item code."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#survey
* code = HRMeasurementCS#history-dm "Diabetes, reported"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* effectiveDateTime = "2026-04-14T09:10:00+03:00"
* performer[0] = Reference(ExampleStudyNurse)
* valueBoolean = true

Instance: ExampleConditionDiabetes
InstanceOf: HRCondition
Usage: #example
Title: "Reported condition: diabetes"
Description: "What the Yes on the history form asserts. The interview does not ask the type, so the code is diabetes of unspecified type. Unconfirmed, because nothing in the study checks it against a record, and traceable to the answer through evidence."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* clinicalStatus = $condition-clinical#active "Active"
* verificationStatus = $condition-ver-status#unconfirmed "Unconfirmed"
* category[0] = $condition-category#problem-list-item "Problem List Item"
* code = $icd11#5A14 "Diabetes mellitus, type unspecified"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* recordedDate = "2026-04-14"
* evidence[0].reference = Reference(ExampleHistoryDiabetes)

Instance: ExampleSmokingStatus
InstanceOf: HRObservation
Usage: #example
Title: "History: tobacco smoking status"
Description: "A coded answer on the study's use-status scale, under the LOINC code whose meaning the question has."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#social-history
* code = $loinc#72166-2 "Tobacco smoking status"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* effectiveDateTime = "2026-04-14T09:10:00+03:00"
* performer[0] = Reference(ExampleStudyNurse)
* valueCodeableConcept = HRUseStatusCS#past "Past"

Instance: ExampleMedicineAmlodipine
InstanceOf: HRMedicationStatement
Usage: #example
Title: "Reported medicine: amlodipine"
Description: "One medicine from the medications form. The catalogue entry identifies the product with its strength and form; how it is taken is on the study's own scales."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #recorded
* medication.concept = $hr-medicine#GE-10210 "Amlodipine 5mg tablet"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* dateAsserted = "2026-04-14"
* dosage[0].route = HRMedicineRouteCS#oral "Oral"
* dosage[0].timing.code = HRMedicineFrequencyCS#once-daily "Once a day"
* reason[0].concept.text = "Blood pressure"
