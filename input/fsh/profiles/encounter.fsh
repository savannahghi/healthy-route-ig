// Healthy Route — The screening visit
//
// One participant, one visit, everything measured during it. The protocols
// describe a single cross-sectional contact: an interview, blood pressure,
// a urine dipstick, blood and urine samples, and retinal photography of both
// eyes. There is no follow-up visit and no admission. The samples and the
// photography may each fall up to 28 days after consent, so the visit is one
// parent encounter and a dated child encounter for each part, typed from the
// visit part code system and pointing at the parent through partOf.
//
// The encounter is the spine the measurements hang from. Every Observation,
// ServiceRequest, DiagnosticReport and ImagingStudy in this guide requires one,
// because a result that cannot be placed at a visit cannot be placed against
// the consent that was in force, or against the clinic the participant was
// recruited from.

Profile: HREncounter
Parent: Encounter
Id: hr-encounter
Title: "Healthy Route Screening Visit"
Description: "The single visit at which a participant is screened, measured and photographed, or one dated part of it."
* ^status = #draft
* ^experimental = false
* ^purpose = "Groups everything collected from one participant on one occasion, and records where it happened. The clinic a participant was seen in is a source of spectrum variation that has to survive to analysis, and it is a property of the visit rather than of the participant."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS

* type 1..* MS
* type from HREncounterTypeVS (required)
* type ^short = "The visit, or which part of it"
* type ^comment = "One of the visit part codes. The parent carries visit; a child carries the part whose date it holds."

* partOf MS
* partOf only Reference(HREncounter)
* partOf ^short = "The visit this part belongs to"
* partOf ^comment = "Present on a child encounter and absent on the visit itself. The 28-day window is a query over the child encounters' dates."

* class 1..* MS
* class ^comment = "R5 changed this from a single Coding to a repeating CodeableConcept. Ambulatory for every visit in this study; there is no admission and no follow-up contact."

* subject 1..1 MS
* subject only Reference(HRPatient)

* actualPeriod 1..1 MS
* actualPeriod ^short = "When the visit happened"
* actualPeriod ^comment = "Named period in R4. Required here because it is what a consent date is compared against: a visit preceding the date on the signed form is a protocol deviation, and the comparison needs both dates recorded rather than one inferred."

* serviceProvider 1..1 MS
* serviceProvider only Reference(HROrganization)

* location MS
* location.location only Reference(HRLocation)
* location.location ^requirements = "Both protocols recruit from the general out-patient, hypertension, diabetes and renal clinics of their sites. Disease prevalence differs between those clinics, and predictive values move with prevalence, so which one a participant was seen in is an analysis variable rather than an operational detail."

* participant MS
* participant.actor only Reference(HRPractitioner or HRPatient)
* participant ^short = "Study team members present"

* identifier MS

* subjectStatus MS
* subjectStatus ^comment = "There is no link from Encounter to ResearchSubject in R5. A visit is tied to the study through its subject, which resolves to the participant and from there to their enrolment."
