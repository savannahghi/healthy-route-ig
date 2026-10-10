// Healthy Route — Reported conditions
//
// The history form asks whether the participant has diabetes, hypertension,
// chronic kidney disease, HIV or heart disease. Each answer is kept as an
// Observation under its item code, so the form can be read back exactly as it
// was filled. A Yes is also a Condition, because that is where a consumer looks
// for a diagnosis, and the sponsor's export lists Condition among the resources
// it receives. The two are not alternatives: the Observation is the answer, the
// Condition is what the answer asserts.

Profile: HRCondition
Parent: Condition
Id: hr-condition
Title: "Healthy Route Reported Condition"
Description: "A diagnosis the participant reports at interview."
* ^status = #draft
* ^experimental = false
* ^purpose = "Carries the diagnoses the protocols stratify on, as the participant reports them. Nothing is confirmed against a record, which is why the verification status is part of the resource rather than assumed."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* clinicalStatus 1..1 MS

* verificationStatus 1..1 MS
* verificationStatus ^comment = "Unconfirmed for a condition reported at interview, which is every condition this study records. Required so that a consumer cannot read a reported diagnosis as an established one."

* category 1..* MS

* code 1..1 MS
* code ^short = "The condition reported"
* code ^comment = "WHO ICD-11: 5A14 for diabetes mellitus of unspecified type, because the interview does not ask the type; BA00 for essential hypertension; GB61 for chronic kidney disease. HIV and heart disease are reported as yes or no answers only and are not asserted as conditions until the protocols name the code they want."

* subject 1..1 MS
* subject only Reference(HRPatient)

* encounter 1..1 MS
* encounter only Reference(HREncounter)
* encounter ^comment = "The visit the history was taken at."

* recordedDate 1..1 MS
* recordedDate ^comment = "The date of the interview, which is the visit date."

* evidence MS
* evidence only CodeableReference(HRObservation)
* evidence ^short = "The answer this condition was asserted from"
* evidence ^comment = "The Observation holding the yes or no answer under its item code, so the assertion can be traced to the form."

* note MS
