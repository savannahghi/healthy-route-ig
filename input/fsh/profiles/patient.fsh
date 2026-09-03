// Healthy Route — Patient
//
// Two profiles constrain Patient, corresponding to the two sides of the
// de-identification boundary:
//
//   HRPatient        Held within a site tenant. Carries identifiers.
//   HRExportPatient  Transferred to the sponsor. Identifying elements prohibited.
//
// The separation is deliberate. Expressing the export constraint as cardinality
// rather than as a documented transformation means that a de-identification
// failure is detected by validation rather than by inspection.

Profile: HRPatient
Parent: Patient
Id: hr-patient
Title: "Healthy Route Patient"
Description: "A study participant as held within a site tenant."
* ^status = #draft
* ^experimental = false
* ^purpose = "Supports operation of the study at a site: participant lookup at registration, prevention of duplicate enrolment, and linkage of clinical observations to the correct individual. This is not the form in which participant data is transferred to the sponsor; see HRExportPatient."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* identifier 1..* MS
* identifier ^slicing.discriminator[0].type = #value
* identifier ^slicing.discriminator[0].path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Sliced by identifier system to require the programme participant identifier while permitting site-local identifiers alongside it."
* identifier contains participantId 1..1 MS

* identifier[participantId] ^short = "OptimalHealth participant identifier"
* identifier[participantId] ^definition = "The identifier issued to the participant at registration. It serves three roles: participant identifier within the tenant, study identifier on the case report form, and the value entered on the retinal camera at image capture."
* identifier[participantId] ^requirements = "A single identifier across all three roles allows images captured on the device to be matched to the participant record at the sponsor without any additional key being shared between the parties."
* identifier[participantId] ^comment = "Opaque: the value encodes nothing about the person or the site. Retained unchanged across rescreening, so a participant who is rescreened is not issued a second identifier. Held in Patient.identifier and not in Resource.id, because resource identifiers appear in request URLs, server logs and cache keys, none of which are covered by de-identification of resource content."
* identifier[participantId].system 1..1 MS
* identifier[participantId].system = "https://fhir.savannahghi.org/sid/optimalhealth-participant"
* identifier[participantId].value 1..1 MS

* name 1..1 MS
* name ^short = "Participant name"
* name ^requirements = "Registration begins with a search of the site's existing records by name, date of birth and contact number. The name is also the means by which the electronic record is matched to the signed consent form retained in the site file."
* name.family 1..1 MS
* name.family ^comment = "Where a participant is mononymous, the single name is recorded as the family name."

* birthDate 1..1 MS
* birthDate ^requirements = "Used with name and contact number to search the site's existing records at registration, and to derive age. Age selects the coefficients used by the CKD-EPI 2021 equation and is an input to the algorithm under validation."
* birthDate ^comment = "Where only a year, or a year and month, are known, a partial date is recorded and age is derived to the precision available."

* telecom MS
* telecom ^short = "Contact number"
* telecom ^requirements = "Contributes to the site's confidential log of coded identifiers, which is held to prevent duplicate enrolment and is not transmitted outside the site."
* telecom ^comment = "Not required. Enrolment must not depend on the participant having a telephone."

* gender 1..1 MS
* gender ^short = "Administrative gender"
* gender ^requirements = "Required rather than optional. Sex selects the coefficients used by the CKD-EPI 2021 equation, and is a direct input to the algorithm under validation. A record without it cannot be analysed."


Profile: HRExportPatient
Parent: Patient
Id: hr-export-patient
Title: "Healthy Route Patient (Export)"
Description: "A study participant as transferred to the sponsor."
* ^status = #draft
* ^experimental = false
* ^purpose = "Defines the Patient content permitted to leave a tenant. Direct identifiers are constrained to a cardinality of 0..0 so that a resource containing them fails validation against this profile."

* identifier 1..1 MS
* identifier ^short = "OptimalHealth participant identifier"
* identifier ^comment = "The only identifier permitted. It is pseudonymous rather than anonymous: re-identification remains possible to the site holding the corresponding registration record, and to no other party."
* identifier.system 1..1 MS
* identifier.system = "https://fhir.savannahghi.org/sid/optimalhealth-participant"
* identifier.value 1..1 MS

* gender 1..1 MS
* gender ^requirements = "Required as an input to both the CKD-EPI 2021 equation and the algorithm under validation, and as a stratum for subgroup analysis."

* extension contains HRAgeYears named ageYears 1..1 MS
* extension[ageYears] ^short = "Age in completed years"
* extension[ageYears] ^requirements = "Substitutes for birthDate. Analysis requires age; it does not require a date of birth."

* birthDate 0..0
* birthDate ^comment = "A date of birth combined with a site and an encounter date approaches a unique identifier in a cohort of this size. Age in completed years is carried instead."

* address 0..0
* address ^comment = "Excluded for its contribution to re-identification in combination with other quasi-identifiers, rather than because it identifies the participant on its own."

* generalPractitioner 0..0
* generalPractitioner ^comment = "Identifies the participant's usual physician, who is a named individual outside the study and has not consented to the transfer."

* link 0..0
* link ^comment = "A link to another Patient resource would carry a reference across the tenant partition."

* name 0..0
* telecom 0..0
* photo 0..0
* contact 0..0
* deceased[x] 0..0
