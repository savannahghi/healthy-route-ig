// Healthy Route — the Uganda visit forms
//
// One Questionnaire per form the site fills in, as the platform manual shows
// them. Every leaf item's linkId is the code its answer becomes: a LOINC code
// where LOINC has one with the question's meaning, a Healthy Route measurement
// code otherwise. Inside a repeating or numbered group the linkId is the
// group's linkId, a dot, then the code, so that three blood pressure readings
// do not share one key. The maps read answers by these keys and nothing else.
//
// Each form names the StructureMap that extracts it. Times are asked as
// dateTime items: the screen shows a time picker, and the frontend sends the
// full timestamp on the day of the measurement, so the map never has to join a
// date to a time.
//
// A form carries the guide's version, as the publisher gives every resource in
// a release: forms, maps and terminology ship together, and a study amendment
// names the release it was approved with. A superseded release stays
// retrievable for the participants judged under it.

RuleSet: HRForm(id, name, title, map)
* id = "{id}"
* name = "{name}"
* title = "{title}"
* status = #draft
* experimental = false
* subjectType = #Patient
* date = "2026-10-10"
* publisher = "Savannah Informatics"
* extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-targetStructureMap"
* extension[=].valueCanonical = "https://fhir.savannahghi.org/ig/healthy-route/StructureMap/{map}"

RuleSet: Unit(unit, display)
* item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].extension[=].valueCoding = $ucum#{unit} "{display}"

RuleSet: Bounds(lo, hi)
* item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/minValue"
* item[=].extension[=].valueInteger = {lo}
* item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/maxValue"
* item[=].extension[=].valueInteger = {hi}


// --- Eligibility ------------------------------------------------------------

Instance: HREligibilityUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Eligibility checklist, Uganda"
Description: "The inclusion and exclusion criteria as the site records them. The outcome is not an item: the rules in force compute it from the answers."
* insert HRForm(hr-eligibility-ug, HREligibilityUG, Eligibility checklist\, Uganda, HRExtractEligibility)

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
* item[=].item[=].text = "Documented eGFR value"
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
* item[=].item[=].text = "Any known eye condition that may preclude clear imaging of the retina"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "excl-emergency"
* item[=].item[=].code = HRMeasurementCS#excl-emergency
* item[=].item[=].text = "Hypertensive, hyperglycaemic or hypoglycaemic emergency"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "excl-involvement"
* item[=].item[=].code = HRMeasurementCS#excl-involvement
* item[=].item[=].text = "Involvement in the planning or conduct of the study"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true
* item[=].item[+].linkId = "excl-noncompliance"
* item[=].item[=].code = HRMeasurementCS#excl-noncompliance
* item[=].item[=].text = "Unlikely to comply with study procedures"
* item[=].item[=].type = #boolean
* item[=].item[=].required = true


// --- Measure: history ---------------------------------------------------------

Instance: HRHistoryUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Measure: history, Uganda"
Description: "Conditions and exposures, as the participant reports them."
* insert HRForm(hr-history-ug, HRHistoryUG, Measure: history\, Uganda, HRExtractHistory)

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
* item[=].required = true
* item[=].answerValueSet = Canonical(HRUseStatusVS)
* item[+].linkId = "72166-2"
* item[=].code = $loinc#72166-2 "Tobacco smoking status"
* item[=].text = "Smoking history"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRUseStatusVS)
* item[+].linkId = "history-hiv"
* item[=].code = HRMeasurementCS#history-hiv
* item[=].text = "HIV history"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "history-heart"
* item[=].code = HRMeasurementCS#history-heart
* item[=].text = "Heart disease"
* item[=].type = #boolean
* item[=].required = true
* item[+].linkId = "history-traditional"
* item[=].code = HRMeasurementCS#history-traditional
* item[=].text = "Traditional medicine use"
* item[=].type = #boolean
* item[=].required = true


// --- Measure: medications ------------------------------------------------------

Instance: HRMedicationsUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Measure: medications, Uganda"
Description: "Every medicine taken now, including traditional or over-the-counter medicines. Recorded at the clinician's discretion."
* insert HRForm(hr-medications-ug, HRMedicationsUG, Measure: medications\, Uganda, HRExtractMedications)

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
* item[=].item[=].answerValueSet = "https://fhir.savannahghi.org/ValueSet/hr-medicine"
* item[=].item[=].answerConstraint = #optionsOrString
* item[=].item[+].linkId = "medicine.strength"
* item[=].item[=].text = "Strength"
* item[=].item[=].type = #string
* item[=].item[+].linkId = "medicine.form"
* item[=].item[=].text = "Form"
* item[=].item[=].type = #coding
* item[=].item[=].answerValueSet = Canonical(HRDoseFormVS)
* item[=].item[+].linkId = "medicine.route"
* item[=].item[=].text = "Route"
* item[=].item[=].type = #coding
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = Canonical(HRMedicineRouteVS)
* item[=].item[+].linkId = "medicine.frequency"
* item[=].item[=].text = "How often"
* item[=].item[=].type = #coding
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = Canonical(HRMedicineFrequencyVS)
* item[=].item[+].linkId = "medicine.reason"
* item[=].item[=].text = "Taken for"
* item[=].item[=].type = #string


// --- Measure: diet and activity ----------------------------------------------

Instance: HRDietActivityUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Measure: diet and activity, Uganda"
Description: "Dietary habits and physical activity in a usual week. Recorded at the clinician's discretion; the derived values are the rule set's."
* insert HRForm(hr-diet-activity-ug, HRDietActivityUG, Measure: diet and activity\, Uganda, HRExtractDietActivity)

* item[+].linkId = "fruit-days"
* item[=].code = HRMeasurementCS#fruit-days
* item[=].text = "Days fruit eaten in a usual week"
* item[=].type = #integer
* insert Bounds(0, 7)
* item[+].linkId = "veg-days"
* item[=].code = HRMeasurementCS#veg-days
* item[=].text = "Days vegetables eaten in a usual week"
* item[=].type = #integer
* insert Bounds(0, 7)
* item[+].linkId = "salt-added"
* item[=].code = HRMeasurementCS#salt-added
* item[=].text = "Salt added at the table"
* item[=].type = #coding
* item[=].answerValueSet = Canonical(HRFrequencyScaleVS)
* item[+].linkId = "sugar-drinks"
* item[=].code = HRMeasurementCS#sugar-drinks
* item[=].text = "Sugar-sweetened drinks"
* item[=].type = #coding
* item[=].answerValueSet = Canonical(HRFrequencyScaleVS)
* item[+].linkId = "work-activity"
* item[=].code = HRMeasurementCS#work-activity
* item[=].text = "Physical activity at work"
* item[=].type = #coding
* item[=].answerValueSet = Canonical(HRWorkActivityVS)
* item[+].linkId = "activity-days"
* item[=].code = HRMeasurementCS#activity-days
* item[=].text = "Days of moderate or vigorous activity in a usual week"
* item[=].type = #integer
* insert Bounds(0, 7)
* item[+].linkId = "activity-minutes"
* item[=].code = HRMeasurementCS#activity-minutes
* item[=].text = "Minutes of moderate or vigorous activity on those days"
* item[=].type = #integer
* insert Bounds(0, 1440)
* item[+].linkId = "seated-hours"
* item[=].code = HRMeasurementCS#seated-hours
* item[=].text = "Hours seated in a usual day"
* item[=].type = #integer
* insert Bounds(0, 24)


// --- Measure: vitals ----------------------------------------------------------

Instance: HRVitalsUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Measure: vitals, Uganda"
Description: "Anthropometry and three timed blood pressure readings around the retinal capture. Body mass index, waist-to-hip ratio, the mean and the reading sequence are the rule set's."
* insert HRForm(hr-vitals-ug, HRVitalsUG, Measure: vitals\, Uganda, HRExtractVitals)

* item[+].linkId = "8302-2"
* item[=].code = $loinc#8302-2 "Body height"
* item[=].text = "Height"
* item[=].type = #decimal
* item[=].required = true
* insert Unit(cm, cm)
* item[+].linkId = "29463-7"
* item[=].code = $loinc#29463-7 "Body weight"
* item[=].text = "Weight"
* item[=].type = #decimal
* item[=].required = true
* insert Unit(kg, kg)
* item[+].linkId = "8280-0"
* item[=].code = $loinc#8280-0 "Waist Circumference at umbilicus by Tape measure"
* item[=].text = "Waist circumference"
* item[=].type = #decimal
* item[=].required = true
* insert Unit(cm, cm)
* item[+].linkId = "hip-circumference"
* item[=].code = HRMeasurementCS#hip-circumference
* item[=].text = "Hip circumference"
* item[=].type = #decimal
* item[=].required = true
* insert Unit(cm, cm)
* item[+].linkId = "bp-device"
* item[=].code = HRMeasurementCS#bp-device
* item[=].text = "Blood pressure monitor"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRBloodPressureDeviceVS)

* item[+].linkId = "bp-reading-1"
* item[=].text = "Reading 1, before retinal capture"
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
* item[=].text = "Reading 2"
* item[=].type = #group
* item[=].required = true
* item[=].item[+].linkId = "bp-reading-2.bp-position"
* item[=].item[=].code = HRMeasurementCS#bp-position
* item[=].item[=].text = "When is this reading taken?"
* item[=].item[=].type = #coding
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = Canonical(HRBloodPressurePositionVS)
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

* item[+].linkId = "retinal-capture-time"
* item[=].code = HRMeasurementCS#retinal-capture-time
* item[=].text = "Time of retinal capture"
* item[=].type = #dateTime
* item[=].required = true

* item[+].linkId = "bp-reading-3"
* item[=].text = "Reading 3, after retinal capture"
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


// --- Laboratory results -------------------------------------------------------

Instance: HRLaboratoryUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Laboratory results, Uganda"
Description: "The results as the laboratory reported them, in the unit it reported. The calculated eGFR is the rule set's and has no item."
* insert HRForm(hr-laboratory-ug, HRLaboratoryUG, Laboratory results\, Uganda, HRExtractLaboratory)

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
* item[+].linkId = "1558-6"
* item[=].code = $loinc#1558-6 "Fasting glucose [Mass/volume] in Serum or Plasma"
* item[=].text = "Fasting blood sugar"
* item[=].type = #decimal
* item[=].required = true
* item[+].linkId = "1558-6.unit"
* item[=].text = "Reported in"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRLabUnitVS)
* item[+].linkId = "hiv-test"
* item[=].code = HRMeasurementCS#hiv-test
* item[=].text = "HIV test"
* item[=].type = #coding
* item[=].required = true
* item[=].answerValueSet = Canonical(HRReactiveVS)
* item[+].linkId = "fbc-taken"
* item[=].code = HRMeasurementCS#fbc-taken
* item[=].text = "Full blood count taken"
* item[=].type = #boolean
* item[=].required = true


// --- Imaging ------------------------------------------------------------------

Instance: HRImagingUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Imaging, Uganda"
Description: "The pack both eyes were written to, and the four answers about it, given against what is in the device's cloud storage. The investigator's confirmation is not an item."
* insert HRForm(hr-imaging-ug, HRImagingUG, Imaging\, Uganda, HRExtractImaging)

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
* item[=].enableWhen[+].question = "images-dilated"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
* item[=].enableWhen[+].question = "images-right"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
* item[=].enableWhen[+].question = "images-left"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
* item[=].enableWhen[+].question = "images-synced"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
