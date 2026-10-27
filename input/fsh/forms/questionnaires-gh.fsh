// Healthy Route — the Ghana visit forms
//
// Built as the Uganda forms are (questionnaires-ug.fsh) and tagged for the
// study HR-GH. A question both protocols ask keeps the Uganda key, so one map
// extracts both countries' answers.


// --- Eligibility ------------------------------------------------------------

Instance: HREligibilityGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Eligibility checklist, Ghana"
Description: "The inclusion and exclusion criteria of the Ghana protocol (v0.3) as the site records them. A negative dipstick ends the screening unless the participant has an established CKD diagnosis, which is only asked when the dipstick is negative. The outcome is not an item: the rules in force compute it from the answers."
* insert HRForm(hr-eligibility-gh, HREligibilityGH, Eligibility checklist\, Ghana, HRExtractEligibility, HR-GH, Healthy Route Ghana)

* item[+].linkId = "inclusions"
* item[=].text = "Inclusions"
* item[=].type = #group
* item[=].required = true
* item[=].item[+].linkId = "capable-of-consent"
* item[=].item[=].code = HRMeasurementCS#capable-of-consent
* item[=].item[=].text = "Able to give signed informed consent"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "documented-egfr"
* item[=].item[=].code = HRMeasurementCS#documented-egfr
* item[=].item[=].text = "Previously documented eGFR, at least 3 months old"
* item[=].item[=].type = #decimal
* item[=].item[=].required = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mL/min/{1.73_m2} "mL/min/{1.73_m2}"
* item[=].item[+].linkId = "documented-egfr.date"
* item[=].item[=].text = "Date of the documented eGFR"
* item[=].item[=].type = #date
* item[=].item[=].required = true
* item[=].item[+].linkId = "20454-5"
* item[=].item[=].code = $loinc#20454-5 "Protein [Presence] in Urine by Test strip"
* item[=].item[=].text = "Urine dipstick protein"
* item[=].item[=].type = #coding
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = Canonical(HRDipstickProteinVS)
* item[=].item[+].linkId = "established-ckd"
* item[=].item[=].code = HRMeasurementCS#established-ckd
* item[=].item[=].text = "Established CKD diagnosis at the clinic, with an eGFR below 60 mL/min/1.73m2 for 3 months or more"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[=].enableWhen[+].question = "20454-5"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerCoding = HRDipstickProteinCS#negative

* item[+].linkId = "exclusions"
* item[=].text = "Exclusions"
* item[=].type = #group
* item[=].required = true
* item[=].item[+].linkId = "excl-undesirable"
* item[=].item[=].code = HRMeasurementCS#excl-undesirable
* item[=].item[=].text = "Any condition that in the investigator's opinion makes participation undesirable"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "excl-eye-condition"
* item[=].item[=].code = HRMeasurementCS#excl-eye-condition
* item[=].item[=].text = "Any known eye condition that may preclude clear imaging of the retina, such as cataracts"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "excl-emergency"
* item[=].item[=].code = HRMeasurementCS#excl-emergency
* item[=].item[=].text = "Hypertensive, hyperglycaemic or hypoglycaemic emergency"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "excl-involvement"
* item[=].item[=].code = HRMeasurementCS#excl-involvement
* item[=].item[=].text = "Involvement in the planning or conduct of the study, as HHA or AstraZeneca staff or staff at the study site"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "excl-noncompliance"
* item[=].item[=].code = HRMeasurementCS#excl-noncompliance
* item[=].item[=].text = "Unlikely to comply with study procedures"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
