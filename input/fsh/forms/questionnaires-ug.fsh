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
//
// A form is tagged with the identifier of the study it belongs to. The study
// service lists a study's forms by that tag, so these are found by the Uganda
// study once it is created with the identifier HR-UG.
//
// A value worked out from answers on the same form is an item on that form,
// read-only, with the formula as an SDC calculated expression: body mass index,
// waist-to-hip ratio and the mean blood pressure on vitals, the weekly activity
// and the fruit and vegetable count on diet and activity, the eGFR on the
// laboratory results. The screen recalculates it as the answers change, so the
// person entering the answers sees the result and can never type it, and the
// formula ships with the form's version, so a response says which formula gave
// its value. The expressions read answers the way the Advantage formula builder
// writes them, %resource.repeat(item).where(linkId='...').answer.valueDecimal,
// so a form can be opened and edited there. A value that needs answers from
// more than one form, such as the hypertension, diabetes and CKD flags, is not
// on any form: the rule set computes it across the visit.

RuleSet: HRForm(id, name, title, map, study, studyName)
* id = "{id}"
* meta.tag[+] = $optimalhealth-study#{study} "{studyName}"
* name = "{name}"
* title = "{title}"
* status = #draft
* experimental = false
* subjectType = #Patient
* date = "2026-10-10"
* publisher = "Savannah Informatics"
* extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-targetStructureMap"
* extension[=].valueCanonical = "https://fhir.optimalhealth.org/ig/healthy-route/StructureMap/{map}"

RuleSet: Unit(unit, display)
* item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].extension[=].valueCoding = $ucum#{unit} "{display}"

RuleSet: Bounds(lo, hi)
* item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/minValue"
* item[=].extension[=].valueInteger = {lo}
* item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/maxValue"
* item[=].extension[=].valueInteger = {hi}

// A calculated item: read-only, its value the expression set on the next line.
RuleSet: Calculated
* item[=].readOnly = true
* item[=].extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression"
* item[=].extension[=].valueExpression.language = #text/fhirpath

// The same, for an item inside a group.
RuleSet: CalculatedChild
* item[=].item[=].readOnly = true
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression"
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath

// An item filled once from the launch context when the form opens, read-only.
RuleSet: FromContext
* item[=].readOnly = true
* item[=].extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-initialExpression"
* item[=].extension[=].valueExpression.language = #text/fhirpath

// A named value the form's calculated expressions share, read as %{name}.
RuleSet: Variable(name)
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/variable"
* extension[=].valueExpression.name = #{name}
* extension[=].valueExpression.language = #text/fhirpath

// A resource the screen must supply when it opens the form, read as %{name}.
RuleSet: LaunchContext(name, type, display, description)
* extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-launchContext"
* extension[=].extension[+].url = "name"
* extension[=].extension[=].valueCoding = http://hl7.org/fhir/uv/sdc/CodeSystem/launchContext#{name} "{display}"
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCode = #{type}
* extension[=].extension[+].url = "description"
* extension[=].extension[=].valueString = "{description}"


// --- Eligibility ------------------------------------------------------------

Instance: HREligibilityUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Eligibility checklist, Uganda"
Description: "The inclusion and exclusion criteria as the site records them. The outcome is not an item: the rules in force compute it from the answers."
* insert HRForm(hr-eligibility-ug, HREligibilityUG, Eligibility checklist\, Uganda, HRExtractEligibility, HR-UG, Healthy Route Uganda)

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
* insert HRForm(hr-history-ug, HRHistoryUG, Measure: history\, Uganda, HRExtractHistory, HR-UG, Healthy Route Uganda)

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
* insert HRForm(hr-medications-ug, HRMedicationsUG, Measure: medications\, Uganda, HRExtractMedications, HR-UG, Healthy Route Uganda)

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
Description: "Dietary habits and physical activity in a usual week. Recorded at the clinician's discretion. Whether fruit and vegetables are both eaten five days or more, the weekly minutes of activity and whether they meet the WHO recommendation are calculated on the form and cannot be typed."
* insert HRForm(hr-diet-activity-ug, HRDietActivityUG, Measure: diet and activity\, Uganda, HRExtractDietActivity, HR-UG, Healthy Route Uganda)

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
* item[+].linkId = "fruit-veg-5plus"
* item[=].code = HRMeasurementCS#fruit-veg-5plus
* item[=].text = "Fruit and vegetables both eaten five days or more"
* item[=].type = #boolean
* insert Calculated
* item[=].extension[=].valueExpression.expression = "%resource.repeat(item).where(linkId='fruit-days').answer.valueInteger >= 5 and %resource.repeat(item).where(linkId='veg-days').answer.valueInteger >= 5"
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
* item[+].linkId = "activity-weekly-minutes"
* item[=].code = HRMeasurementCS#activity-weekly-minutes
* item[=].text = "Minutes of moderate or vigorous activity a week"
* item[=].type = #integer
* insert Calculated
* item[=].extension[=].valueExpression.expression = "%resource.repeat(item).where(linkId='activity-days').answer.valueInteger * %resource.repeat(item).where(linkId='activity-minutes').answer.valueInteger"
* item[+].linkId = "activity-who-met"
* item[=].code = HRMeasurementCS#activity-who-met
* item[=].text = "Meets the WHO recommendation of 150 minutes a week"
* item[=].type = #boolean
* insert Calculated
* item[=].extension[=].valueExpression.expression = "(%resource.repeat(item).where(linkId='activity-days').answer.valueInteger * %resource.repeat(item).where(linkId='activity-minutes').answer.valueInteger) >= 150"
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
Description: "Anthropometry and three timed blood pressure readings around the retinal capture. Body mass index, the waist-to-hip ratio and the mean of readings two and three, which the Uganda protocol takes as the true blood pressure, are calculated on the form and cannot be typed. Whether the readings fit the protocol's sequence is the rule set's."
* insert HRForm(hr-vitals-ug, HRVitalsUG, Measure: vitals\, Uganda, HRExtractVitals, HR-UG, Healthy Route Uganda)

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
* item[+].linkId = "39156-5"
* item[=].code = $loinc#39156-5 "Body mass index (BMI) [Ratio]"
* item[=].text = "Body mass index"
* item[=].type = #decimal
* insert Unit(kg/m2, kg/m2)
* insert Calculated
* item[=].extension[=].valueExpression.expression = "(%resource.repeat(item).where(linkId='29463-7').answer.valueDecimal / (%resource.repeat(item).where(linkId='8302-2').answer.valueDecimal / 100).power(2)).round(1)"
* item[+].linkId = "waist-hip-ratio"
* item[=].code = HRMeasurementCS#waist-hip-ratio
* item[=].text = "Waist-to-hip ratio"
* item[=].type = #decimal
* insert Calculated
* item[=].extension[=].valueExpression.expression = "(%resource.repeat(item).where(linkId='8280-0').answer.valueDecimal / %resource.repeat(item).where(linkId='hip-circumference').answer.valueDecimal).round(2)"
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

* item[+].linkId = "bp-mean"
* item[=].text = "Blood pressure, the mean of readings 2 and 3"
* item[=].type = #group
* item[=].item[+].linkId = "bp-mean.8480-6"
* item[=].item[=].code = $loinc#8480-6 "Systolic blood pressure"
* item[=].item[=].text = "Systolic"
* item[=].item[=].type = #decimal
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* insert CalculatedChild
* item[=].item[=].extension[=].valueExpression.expression = "((%resource.repeat(item).where(linkId='bp-reading-2.8480-6').answer.valueDecimal + %resource.repeat(item).where(linkId='bp-reading-3.8480-6').answer.valueDecimal) / 2).round(0)"
* item[=].item[+].linkId = "bp-mean.8462-4"
* item[=].item[=].code = $loinc#8462-4 "Diastolic blood pressure"
* item[=].item[=].text = "Diastolic"
* item[=].item[=].type = #decimal
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
* item[=].item[=].extension[=].valueCoding = $ucum#mm[Hg] "mm[Hg]"
* insert CalculatedChild
* item[=].item[=].extension[=].valueExpression.expression = "((%resource.repeat(item).where(linkId='bp-reading-2.8462-4').answer.valueDecimal + %resource.repeat(item).where(linkId='bp-reading-3.8462-4').answer.valueDecimal) / 2).round(0)"


// --- Laboratory results -------------------------------------------------------

Instance: HRLaboratoryUG
InstanceOf: Questionnaire
Usage: #definition
Title: "Laboratory results, Uganda"
Description: "The results as the laboratory reported them, in the unit it reported. The eGFR is calculated on the form by CKD-EPI 2021 from the creatinine, shown with the creatinine in mg/dL and the age and sex it used, and none of them can be typed. The age and sex come from the participant's record when the form opens."
* insert HRForm(hr-laboratory-ug, HRLaboratoryUG, Laboratory results\, Uganda, HRExtractLaboratory, HR-UG, Healthy Route Uganda)
* insert LaunchContext(patient, Patient, Patient, The participant: the eGFR takes their sex and date of birth.)
* insert LaunchContext(encounter, Encounter, Encounter, The visit: the age the eGFR uses is the age on the day it started.)

// CKD-EPI 2021, without the race coefficient, on creatinine in mg/dL:
//   142 x min(Scr/k, 1)^a x max(Scr/k, 1)^-1.200 x 0.9938^age x 1.012 if female
// with k 0.7 and a -0.241 for a woman, k 0.9 and a -0.302 for a man. A
// creatinine in umol/L is divided by 88.4 first. Any other unit, sex or a
// missing input gives no value rather than a wrong one.
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
* insert HRForm(hr-imaging-ug, HRImagingUG, Imaging\, Uganda, HRExtractImaging, HR-UG, Healthy Route Uganda)

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
