// Healthy Route — the Ghana visit forms
//
// Built as the Uganda forms are (questionnaires-ug.fsh) and tagged for the
// study HR-GH. A question both protocols ask keeps the Uganda key, so one map
// extracts both countries' answers.
//
// The questions are the Ghana protocol's, version 6.0 of 10 July 2026: its
// data collection tool (Appendix B) and the schedule of activities. The tool's
// Study ID, hospital number, date of birth, sex and contact are taken when the
// participant is registered, and its date of interview is the visit's, so no
// form asks them again. Nothing here is optional at sign-off: the protocol
// counts treatment towards hypertension, so the medication list is needed.
// Ghana's tool has no diet and activity section.
//
// Where the 6 November 2026 review settled a difference between the two
// countries, these forms follow the review rather than v6.0: the urine dipstick
// is a laboratory result that decides nothing, established CKD is not asked,
// and alcohol and smoking are asked but not required.
//
// The time of retinal capture is asked once, on the imaging form. The blood
// pressure readings are timed around it, and a question asked on two forms can
// be answered two ways.


// --- Eligibility ------------------------------------------------------------

Instance: HREligibilityGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Eligibility checklist, Ghana"
Description: "The inclusion and exclusion criteria of the Ghana protocol (v6.0) as the site records them, as the 6 November 2026 review settled them: the urine dipstick does not decide eligibility and is recorded on the laboratory results, and established CKD is not asked. The outcome is not an item: the rules in force compute it from the answers."
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


// --- Socio-demographics ---------------------------------------------------------

Instance: HRDemographicsGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Socio-demographics, Ghana"
Description: "The socio-demographic questions of the Ghana data collection tool that registration does not ask. The address is not on this form: it identifies the participant, so it belongs with the participant's details rather than with the study data that is exported."
* insert HRForm(hr-demographics-gh, HRDemographicsGH, Socio-demographics\, Ghana, HRExtractDemographics, HR-GH, Healthy Route Ghana)
* meta.tag[+] = HRSignoffCS#optional "Optional at sign-off"

* item[+].linkId = "recruitment-clinic"
* item[=].code = HRMeasurementCS#recruitment-clinic
* item[=].text = "Clinic"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRClinicVS)
* item[+].linkId = "ethnicity"
* item[=].code = HRMeasurementCS#ethnicity
* item[=].text = "Ethnicity"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HREthnicityGhanaVS)
* item[+].linkId = "ethnicity.other"
* item[=].text = "Other ethnicity, specify"
* item[=].type = #string
* item[=].required = true
* item[=].enableWhen[+].question = "ethnicity"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerCoding = HREthnicityGhanaCS#other
* item[+].linkId = "domicile"
* item[=].code = HRMeasurementCS#domicile
* item[=].text = "Type of domicile"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRDomicileVS)


// --- Measure: history ---------------------------------------------------------

Instance: HRHistoryGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Measure: history, Ghana"
Description: "Conditions and exposures, as the participant reports them. The previously documented eGFR is on the eligibility checklist and is not asked again."
* insert HRForm(hr-history-gh, HRHistoryGH, Measure: history\, Ghana, HRExtractHistory, HR-GH, Healthy Route Ghana)

* item[+].linkId = "history-dm"
* item[=].code = HRMeasurementCS#history-dm
* item[=].text = "Diabetes"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "history-htn"
* item[=].code = HRMeasurementCS#history-htn
* item[=].text = "Hypertension"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "history-ckd"
* item[=].code = HRMeasurementCS#history-ckd
* item[=].text = "CKD"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "history-alcohol"
* item[=].code = HRMeasurementCS#history-alcohol
* item[=].text = "Alcohol use"
* item[=].type = #coding
* item[=].answerValueSet = Canonical(HRUseStatusVS)
* item[+].linkId = "72166-2"
* item[=].code = $loinc#72166-2 "Tobacco smoking status"
* item[=].text = "Smoking history"
* item[=].type = #coding
* item[=].answerValueSet = Canonical(HRUseStatusVS)


// --- Measure: medications ------------------------------------------------------

Instance: HRMedicationsGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Measure: medications, Ghana"
Description: "The participant's current medication list. The protocol counts treatment for high blood pressure towards hypertension, so the list is asked at every visit; the strength and what a medicine is taken for help tell a treatment apart."
* insert HRForm(hr-medications-gh, HRMedicationsGH, Measure: medications\, Ghana, HRExtractMedications, HR-GH, Healthy Route Ghana)

* item[+].linkId = "medications-current"
* item[=].text = "Currently taking any medication"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "medicine"
* item[=].text = "Medicine"
* item[=].type = #group
* item[=].repeats = true
* item[=].enableWhen[+].question = "medications-current"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = true
* item[=].item[+].linkId = "medicine.code"
* item[=].item[=].text = "Medication name"
* item[=].item[=].type = #coding
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = "https://fhir.optimalhealth.org/ValueSet/hr-medicine"
* item[=].item[=].answerConstraint = #optionsOrString
* item[=].item[+].linkId = "medicine.strength"
* item[=].item[=].text = "Strength"
* item[=].item[=].type = #string
* item[=].item[+].linkId = "medicine.reason"
* item[=].item[=].text = "Taken for"
* item[=].item[=].type = #string


// --- Measure: vitals ----------------------------------------------------------

Instance: HRVitalsGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Measure: vitals, Ghana"
Description: "Three timed blood pressure readings around the retinal capture, all taken before blood is sampled. The Ghana protocol records the average of the three, which is calculated on the form and cannot be typed. Whether the readings fit the protocol's timing is the rule set's."
* insert HRForm(hr-vitals-gh, HRVitalsGH, Measure: vitals\, Ghana, HRExtractVitals, HR-GH, Healthy Route Ghana)

* item[+].linkId = "bp-reading-1"
* item[=].text = "Reading 1, 45 to 75 minutes before retinal capture"
* item[=].type = #group
* item[=].required = true
* item[=].item[+].linkId = "bp-reading-1.8480-6"
* item[=].item[=].code = $loinc#8480-6 "Systolic blood pressure"
* item[=].item[=].text = "Systolic"
* item[=].item[=].type = #decimal
* item[=].item[=].required = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* item[=].item[+].linkId = "bp-reading-1.8462-4"
* item[=].item[=].code = $loinc#8462-4 "Diastolic blood pressure"
* item[=].item[=].text = "Diastolic"
* item[=].item[=].type = #decimal
* item[=].item[=].required = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* item[=].item[+].linkId = "bp-reading-1.time"
* item[=].item[=].text = "Time taken"
* item[=].item[=].type = #dateTime
* item[=].item[=].required = true

* item[+].linkId = "bp-reading-2"
* item[=].text = "Reading 2, 10 to 20 minutes before or after retinal capture"
* item[=].type = #group
* item[=].required = true
* item[=].item[+].linkId = "bp-reading-2.8480-6"
* item[=].item[=].code = $loinc#8480-6 "Systolic blood pressure"
* item[=].item[=].text = "Systolic"
* item[=].item[=].type = #decimal
* item[=].item[=].required = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* item[=].item[+].linkId = "bp-reading-2.8462-4"
* item[=].item[=].code = $loinc#8462-4 "Diastolic blood pressure"
* item[=].item[=].text = "Diastolic"
* item[=].item[=].type = #decimal
* item[=].item[=].required = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* item[=].item[+].linkId = "bp-reading-2.time"
* item[=].item[=].text = "Time taken"
* item[=].item[=].type = #dateTime
* item[=].item[=].required = true

* item[+].linkId = "bp-reading-3"
* item[=].text = "Reading 3, 45 to 75 minutes after retinal capture"
* item[=].type = #group
* item[=].required = true
* item[=].item[+].linkId = "bp-reading-3.8480-6"
* item[=].item[=].code = $loinc#8480-6 "Systolic blood pressure"
* item[=].item[=].text = "Systolic"
* item[=].item[=].type = #decimal
* item[=].item[=].required = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* item[=].item[+].linkId = "bp-reading-3.8462-4"
* item[=].item[=].code = $loinc#8462-4 "Diastolic blood pressure"
* item[=].item[=].text = "Diastolic"
* item[=].item[=].type = #decimal
* item[=].item[=].required = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* item[=].item[+].linkId = "bp-reading-3.time"
* item[=].item[=].text = "Time taken"
* item[=].item[=].type = #dateTime
* item[=].item[=].required = true

* item[+].linkId = "bp-mean-all"
* item[=].text = "Blood pressure, the average of the three readings"
* item[=].type = #group
* item[=].item[+].linkId = "bp-mean-all.8480-6"
* item[=].item[=].code = $loinc#8480-6 "Systolic blood pressure"
* item[=].item[=].text = "Systolic"
* item[=].item[=].type = #decimal
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* insert CalculatedChild
* item[=].item[=].extension[=].valueExpression.expression = "((%resource.repeat(item).where(linkId='bp-reading-1.8480-6').answer.valueDecimal + %resource.repeat(item).where(linkId='bp-reading-2.8480-6').answer.valueDecimal + %resource.repeat(item).where(linkId='bp-reading-3.8480-6').answer.valueDecimal) / 3).round(0)"
* item[=].item[+].linkId = "bp-mean-all.8462-4"
* item[=].item[=].code = $loinc#8462-4 "Diastolic blood pressure"
* item[=].item[=].text = "Diastolic"
* item[=].item[=].type = #decimal
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* insert CalculatedChild
* item[=].item[=].extension[=].valueExpression.expression = "((%resource.repeat(item).where(linkId='bp-reading-1.8462-4').answer.valueDecimal + %resource.repeat(item).where(linkId='bp-reading-2.8462-4').answer.valueDecimal + %resource.repeat(item).where(linkId='bp-reading-3.8462-4').answer.valueDecimal) / 3).round(0)"


// --- Laboratory results -------------------------------------------------------

Instance: HRLaboratoryGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Laboratory results, Ghana"
Description: "Serum creatinine, HbA1c, uACR and the urine dipstick as the laboratory reported them, in the unit it reported. The dipstick is recorded for characterisation and is not required. The eGFR is calculated on the form by CKD-EPI 2021 from the creatinine, shown with the creatinine in mg/dL and the age and sex it used, and none of them can be typed. The age and sex come from the participant's record when the form opens."
* insert HRForm(hr-laboratory-gh, HRLaboratoryGH, Laboratory results\, Ghana, HRExtractLaboratory, HR-GH, Healthy Route Ghana)
* insert LaunchContext(patient, Patient, Patient, The participant: the eGFR takes their sex and date of birth.)
* insert LaunchContext(encounter, Encounter, Encounter, The visit: the age the eGFR uses is the age on the day it started.)

// The same CKD-EPI 2021 formula as the Uganda form, explained there.
* insert Variable(creatinine)
* extension[=].valueExpression.expression = "%resource.repeat(item).where(linkId='2160-0').answer.valueDecimal"
* insert Variable(creatinineUnit)
* extension[=].valueExpression.expression = "%resource.repeat(item).where(linkId='2160-0.unit').answer.valueCoding.code"
* insert Variable(scr)
* extension[=].valueExpression.expression = "iif(%creatinineUnit = 'mg/dL', %creatinine, iif(%creatinineUnit = 'umol/L', %creatinine / 88.4, {}))"
* insert Variable(egfrAge)
* extension[=].valueExpression.expression = "%resource.repeat(item).where(linkId='egfr-age').answer.valueInteger"
* insert Variable(egfrSex)
* extension[=].valueExpression.expression = "%resource.repeat(item).where(linkId='egfr-sex').answer.valueString"
* insert Variable(kappa)
* extension[=].valueExpression.expression = "iif(%egfrSex = 'female', 0.7, iif(%egfrSex = 'male', 0.9, {}))"
* insert Variable(alpha)
* extension[=].valueExpression.expression = "iif(%egfrSex = 'female', -0.241, iif(%egfrSex = 'male', -0.302, {}))"
* insert Variable(sexFactor)
* extension[=].valueExpression.expression = "iif(%egfrSex = 'female', 1.012, iif(%egfrSex = 'male', 1.0, {}))"
* insert Variable(ratio)
* extension[=].valueExpression.expression = "%scr / %kappa"

* item[+].linkId = "samples-collected"
* item[=].text = "Sample date and time"
* item[=].type = #dateTime
* item[=].required = true
* item[+].linkId = "2160-0"
* item[=].code = $loinc#2160-0 "Creatinine [Mass/volume] in Serum or Plasma"
* item[=].text = "Serum creatinine"
* item[=].type = #decimal
* item[=].required = true
* item[+].linkId = "2160-0.unit"
* item[=].text = "Reported in"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRLabUnitVS)
* item[+].linkId = "creatinine-converted"
* item[=].code = HRMeasurementCS#creatinine-converted
* item[=].text = "Serum creatinine, as the eGFR uses it"
* item[=].type = #decimal
* insert Unit(mg/dL, mg/dL)
* insert Calculated
* item[=].extension[=].valueExpression.expression = "%scr.round(2)"
* item[+].linkId = "egfr-age"
* item[=].code = HRMeasurementCS#egfr-age
* item[=].text = "Age the eGFR uses, in completed years"
* item[=].type = #integer
* insert FromContext
* item[=].extension[=].valueExpression.expression = "iif(%encounter.actualPeriod.start.exists(), %encounter.actualPeriod.start, today()).toString().substring(0, 4).toInteger() - %patient.birthDate.toString().substring(0, 4).toInteger() - iif(iif(%encounter.actualPeriod.start.exists(), %encounter.actualPeriod.start, today()).toString().substring(5, 5) < %patient.birthDate.toString().substring(5, 5), 1, 0)"
* item[+].linkId = "egfr-sex"
* item[=].code = HRMeasurementCS#egfr-sex
* item[=].text = "Sex the eGFR uses"
* item[=].type = #string
* insert FromContext
* item[=].extension[=].valueExpression.expression = "%patient.gender"
* item[+].linkId = "98979-8"
* item[=].code = $loinc#98979-8 "Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI 2021)/1.73 sq M"
* item[=].text = "eGFR, CKD-EPI 2021"
* item[=].type = #decimal
* insert Unit(mL/min/{1.73_m2}, mL/min/{1.73_m2})
* insert Calculated
* item[=].extension[=].valueExpression.expression = "iif(%ratio.exists() and %egfrAge.exists() and %alpha.exists(), (142 * iif(%ratio < 1, %ratio, 1).power(%alpha) * iif(%ratio > 1, %ratio, 1).power(-1.2) * (0.9938).power(%egfrAge) * %sexFactor).round(1), {})"
* item[+].linkId = "4548-4"
* item[=].code = $loinc#4548-4 "Hemoglobin A1c/Hemoglobin.total in Blood"
* item[=].text = "HbA1c"
* item[=].type = #decimal
* item[=].required = true
* insert Unit(%, %)
* item[+].linkId = "9318-7"
* item[=].code = $loinc#9318-7 "Albumin/Creatinine [Mass Ratio] in Urine"
* item[=].text = "uACR"
* item[=].type = #decimal
* item[=].required = true
* item[+].linkId = "9318-7.unit"
* item[=].text = "Reported in"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRLabUnitVS)
* item[+].linkId = "20454-5"
* item[=].code = $loinc#20454-5 "Protein [Presence] in Urine by Test strip"
* item[=].text = "Urine dipstick protein"
* item[=].type = #coding
* item[=].answerValueSet = Canonical(HRDipstickProteinVS)


// --- Imaging ------------------------------------------------------------------

Instance: HRImagingGH
InstanceOf: Questionnaire
Usage: #definition
Title: "Imaging, Ghana"
Description: "The pack both eyes were written to, when they were captured, whether they were taken with dilation, and the three answers about them, given against what is in the device's cloud storage. An eye counts as captured once its image passes the device's quality check, in up to five attempts. The investigator's confirmation is not an item."
* insert HRForm(hr-imaging-gh, HRImagingGH, Imaging\, Ghana, HRExtractImaging, HR-GH, Healthy Route Ghana)

* item[+].linkId = "pack-id"
* item[=].text = "Optomed pack ID"
* item[=].type = #string
* item[=].required = true
* item[+].linkId = "imaging-date"
* item[=].text = "Imaging date"
* item[=].type = #date
* item[=].required = true
* item[+].linkId = "retinal-capture-time"
* item[=].code = HRMeasurementCS#retinal-capture-time
* item[=].text = "Time of retinal capture"
* item[=].type = #dateTime
* item[=].required = true
* item[+].linkId = "images-dilated"
* item[=].code = HRMeasurementCS#images-dilated
* item[=].text = "Have the images been taken with dilation?"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "images-right"
* item[=].code = HRMeasurementCS#images-right
* item[=].text = "Has an image been captured of the RIGHT eye?"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "images-left"
* item[=].code = HRMeasurementCS#images-left
* item[=].text = "Has an image been captured of the LEFT eye?"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "images-synced"
* item[=].code = HRMeasurementCS#images-synced
* item[=].text = "Have the images been synced to the Optomed Cloud Storage?"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "images-reason"
* item[=].text = "Reason the images were not obtained"
* item[=].type = #string
* item[=].enableBehavior = #any
* item[=].enableWhen[+].question = "images-right"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
* item[=].enableWhen[+].question = "images-left"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
* item[=].enableWhen[+].question = "images-synced"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
