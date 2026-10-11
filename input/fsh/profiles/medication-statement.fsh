// Healthy Route — Medicines the participant takes
//
// Recorded at the clinician's discretion from what the participant reports.
// The medicine is a code from the study's medicine catalogue on the terminology
// server; the catalogue entry carries the strength and the dose form, so the
// record does not restate them. How often and by what route it is taken are the
// study's own short scales.

Profile: HRMedicationStatement
Parent: MedicationStatement
Id: hr-medication-statement
Title: "Healthy Route Reported Medicine"
Description: "One medicine the participant reports taking at the time of the visit."
* ^status = #draft
* ^experimental = false
* ^purpose = "The hypertension flag reads the medication list for current antihypertensive treatment, so the medicine must be coded against a catalogue whose entries carry a therapeutic class. Free text would leave the flag unanswerable."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS
* status ^comment = "Recorded. The statement records what the participant said, and nothing in this study verifies it."

* medication 1..1 MS
* medication.concept 1..1 MS
* medication.concept ^short = "The catalogue entry"
* medication.concept ^comment = "A coding from the study's medicine catalogue, with the catalogue's display text. A medicine the catalogue does not list is carried as text alone, for a monitor to resolve."

* subject 1..1 MS
* subject only Reference(HRPatient)

* encounter 1..1 MS
* encounter only Reference(HREncounter)

* dateAsserted 1..1 MS
* dateAsserted ^comment = "The date of the interview."

* dosage MS
* dosage.route MS
* dosage.route from HRMedicineRouteVS (extensible)
* dosage.timing MS
* dosage.timing.code MS
* dosage.timing.code from HRMedicineFrequencyVS (extensible)
* dosage.timing.code ^short = "How often"

* reason MS
* reason only CodeableReference(HRCondition or HRObservation or HRBloodPressure or HRDiagnosticReport)
* reason ^short = "What the participant takes it for, in their words"
* reason ^comment = "Text, as the participant gives it. A reference is permitted for a consumer that resolves the reason to a condition already on the record, but nothing in the study asserts one."

* note MS
