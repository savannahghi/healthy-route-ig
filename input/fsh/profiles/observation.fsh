// Healthy Route — Measurements
//
// HRObservation    Every measurement in the study.
// HRBloodPressure  Blood pressure, derived from the profile FHIR core ships.
//
// One profile carries every measurement: creatinine, eGFR, HbA1c, the urine
// albumin-to-creatinine ratio, the urine dipstick, height, weight, body mass
// index, and the additional investigations one country collects. They differ in
// code, unit and value type; they do not differ in shape, and a profile for
// each would mean a new StructureDefinition and a new release of this guide
// every time a laboratory adds a test.
//
// The exception is blood pressure, which puts its two readings in component
// rather than in value[x]. FHIR core already profiles that as
// http://hl7.org/fhir/StructureDefinition/bp, with the components sliced, their
// LOINC codes fixed and their units fixed to mmHg. HRBloodPressure derives from
// it and adds only what this guide adds to everything else. FHIR is
// single-inheritance, so the tenant extension is restated there rather than
// inherited from HRObservation; three lines of duplication is a better trade
// than reimplementing a profile HL7 maintains.

Invariant: hr-obs-value
Description: "A measurement must carry a value, or say why it does not."
Expression: "value.exists() or dataAbsentReason.exists() or component.exists() or hasMember.exists()"
Severity: #error

Profile: HRObservation
Parent: Observation
Id: hr-observation
Title: "Healthy Route Measurement"
Description: "Any measurement taken from a participant during the screening visit."
* ^status = #draft
* ^experimental = false
* ^purpose = "Carries every measurement the study collects. What distinguishes one measurement from another is Observation.code, which is what a consumer filters on. Constraining the shape rather than the analyte means a laboratory adding a test does not require a change to this guide."

* obeys hr-obs-value

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS

* category 1..* MS
* category ^requirements = "Separates the laboratory results from the vital signs and the questionnaire responses without a consumer having to recognise every LOINC code in use. A consumer that cannot tell a creatinine from a body weight without a code table cannot build a sensible view of a participant."

* code 1..1 MS
* code ^short = "What was measured"
* code ^comment = "LOINC. The codes this study relies on are 5804-0 for the urine dipstick protein, 2160-0 for serum creatinine, 98979-8 for eGFR by the CKD-EPI 2021 equation, 4548-4 for HbA1c and 9318-7 for the urine albumin-to-creatinine ratio. Note the eGFR code: 62238-1 is the generic CKD-EPI formula and 98979-8 is the 2021 revision with the race coefficient removed, which is the one the protocols specify."

* subject 1..1 MS
* subject only Reference(HRPatient)
* subject ^comment = "Required, where the base resource makes it optional and admits Group, Device, Location, Organization and Procedure. A measurement in this study is always of a participant."

* encounter 1..1 MS
* encounter only Reference(HREncounter)
* encounter ^requirements = "Required, where the base resource makes it optional. A result that cannot be placed at a visit cannot be placed against the consent in force at the time, nor against the clinic the participant was recruited from, and both are needed at analysis."

* effective[x] 1..1 MS
* effective[x] ^comment = "The time of the measurement, not of its entry. Blood pressure readings in one country are timed relative to the retinal photography, so the interval between them carries meaning."

* performer MS
* performer only Reference(HRPractitioner or HROrganization)
* performer ^comment = "A practitioner for measurements taken at the site, an organisation for results returned by a laboratory."

* value[x] MS

* dataAbsentReason MS
* dataAbsentReason ^requirements = "A sample that haemolysed and a measurement nobody took are both absent values, and the difference matters to an analysis that has to decide whether to impute. The hr-obs-value invariant requires one or the other."

* specimen MS
* specimen ^comment = "References the base Specimen resource. This guide does not yet profile it."

* device MS
* device ^short = "Instrument used"
* device ^requirements = "One country specifies particular blood pressure monitors and selects between them by participant size. Which instrument produced a reading is the first question asked when one site's values sit apart from the others."

* method MS
* method ^short = "How it was measured"
* method ^requirements = "An eGFR is a number produced by an equation, and the equation is not recoverable from the number. Recording it here is what allows a value calculated by CKD-EPI 2021 to be distinguished from one calculated by an earlier formula."

* derivedFrom MS
* derivedFrom ^short = "Inputs this result was calculated from"
* derivedFrom ^requirements = "An eGFR derives from a creatinine; a mean blood pressure derives from the individual readings. Recording the inputs makes the calculation checkable rather than asserted."

* hasMember MS
* hasMember ^short = "Members of a panel"

* interpretation MS
* note MS


Profile: HRBloodPressure
Parent: http://hl7.org/fhir/StructureDefinition/bp
Id: hr-blood-pressure
Title: "Healthy Route Blood Pressure"
Description: "One blood pressure reading, or the mean of several."
* ^status = #draft
* ^experimental = false
* ^purpose = "Adds the tenancy and encounter requirements this guide places on every measurement to the blood pressure profile FHIR core already defines. The component slicing, the LOINC codes for systolic and diastolic and the mmHg units are inherited and are not restated here."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* subject only Reference(HRPatient)

* encounter 1..1 MS
* encounter only Reference(HREncounter)

* derivedFrom MS
* derivedFrom only Reference(HRBloodPressure)
* derivedFrom ^short = "The readings this mean was calculated from"
* derivedFrom ^requirements = "Both protocols take three readings and record a single derived value, and they derive it differently: one takes the mean of all three, the other the mean of the last two after a rest period. The rule belongs to the study rather than to the resource, so what is recorded here is which readings the derived value actually used. A consumer can then check the calculation instead of trusting it."
* derivedFrom ^comment = "Present on the derived value and absent on the individual readings. Three readings and their mean are four resources of this profile, not one resource with four values."

* device MS
* method MS
