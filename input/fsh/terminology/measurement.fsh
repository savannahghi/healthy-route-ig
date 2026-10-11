// Healthy Route — item codes for the visit forms
//
// The forms a site fills in during the visit ask questions that LOINC either
// does not code or codes with a meaning the question does not have. Those
// questions take a code from this system. Where LOINC has a code with exactly
// the question's meaning, the question uses LOINC and does not appear here.
//
// A code here is both the linkId of the item on the Questionnaire and the
// Observation.code the answer becomes, so the map from one to the other is the
// identity. The derived values are listed with the questions because the rule
// set that computes them writes Observations under the same system.
//
// The answer scales for the coded questions are their own code systems in this
// folder. A boolean question answers true or false and binds to nothing.

CodeSystem: HRMeasurementCS
Id: hr-measurement
Title: "Healthy Route Measurement Codes"
Description: "Codes for the questions on the visit forms that LOINC does not cover, and for the values the study derives from them."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete

// Eligibility
* #age-at-consent "Age at consent" "Completed years on the date consent was given, calculated from the date of birth. Derived."
* #capable-of-consent "Capable of giving signed informed consent" "Inclusion criterion. True or false."
* #documented-egfr "Documented eGFR" "An eGFR documented by the referring service before the visit, as the record shows it. Distinct from the eGFR the study calculates from its own creatinine."
* #excl-undesirable "Condition making participation undesirable" "Exclusion criterion, in the investigator's opinion. True or false."
* #excl-eye-condition "Eye condition precluding retinal imaging" "Exclusion criterion. True or false."
* #excl-emergency "Hypertensive, hyperglycaemic or hypoglycaemic emergency" "Exclusion criterion. True or false."
* #excl-involvement "Involvement in the planning or conduct of the study" "Exclusion criterion. True or false."
* #excl-noncompliance "Unlikely to comply with study procedures" "Exclusion criterion. True or false."
* #eligibility-outcome "Eligibility outcome" "The outcome the rules in force computed from the criteria. Derived."
* #cohort "Cohort" "Case or control, assigned from the documented eGFR. Derived."

// History, as the participant reports it
* #history-dm "Diabetes, reported" "The participant reports a diagnosis of diabetes. True or false."
* #history-htn "Hypertension, reported" "The participant reports a diagnosis of hypertension. True or false."
* #history-ckd "Chronic kidney disease, reported" "The participant reports a diagnosis of chronic kidney disease. True or false."
* #history-hiv "HIV, reported" "The participant reports a diagnosis of HIV. True or false."
* #history-heart "Heart disease, reported" "The participant reports a diagnosis of heart disease. True or false."
* #history-traditional "Traditional medicine use" "The participant reports current or previous use of traditional medicine. True or false."
* #history-alcohol "Alcohol use" "Current, past or nil. LOINC codes the quantity of alcohol, not whether a person drinks, so the status takes a local code."

// Medications
* #medications-none "No current medication" "The participant takes no medication at present. Recorded so that an absent medication list is distinguishable from one not yet taken."

// Diet and physical activity
* #fruit-days "Days fruit eaten in a usual week" "0 to 7."
* #veg-days "Days vegetables eaten in a usual week" "0 to 7."
* #salt-added "Salt added at the table" "How often, on the study's frequency scale."
* #sugar-drinks "Sugar-sweetened drinks" "How often, on the study's frequency scale."
* #work-activity "Physical activity at work" "On the study's work activity scale."
* #activity-days "Days of moderate or vigorous activity in a usual week" "0 to 7."
* #activity-minutes "Minutes of moderate or vigorous activity on those days" "0 to 1440."
* #seated-hours "Hours seated in a usual day" "0 to 24."
* #fruit-veg-5plus "Fruit and vegetables eaten five days or more" "Both day counts at five or more. Derived."
* #activity-weekly-minutes "Weekly minutes of moderate or vigorous activity" "Days multiplied by minutes. Derived."
* #activity-who-met "WHO physical activity recommendation met" "150 minutes a week or more. Derived."

// Anthropometry and blood pressure
* #hip-circumference "Hip circumference" "In centimetres. LOINC publishes a protocol code for hip circumference but not a measurement code, so the measurement takes a local one."
* #waist-hip-ratio "Waist-to-hip ratio" "Waist circumference over hip circumference. Derived."
* #bp-position "Blood pressure reading position" "Whether the reading was taken before or after retinal capture, for the reading the protocol allows either side of it. Carried on the reading as an extension."
* #bp-device "Blood pressure monitor" "Which of the study's monitors took the reading. Carried on each reading as an extension."
* #retinal-capture-time "Time of retinal capture" "When retinal photography finished. The blood pressure readings are timed relative to it."
* #flag-hypertension "Hypertension flag" "Raised readings, a reported history or current antihypertensive treatment. Derived."
* #flag-t2d "Type 2 diabetes flag" "HbA1c above threshold or a reported history. Derived."
* #flag-ckd-stage-3 "CKD stage 3 or worse flag" "Calculated eGFR below 60. Derived."

// Laboratory
* #creatinine-converted "Serum creatinine, converted" "The creatinine in mg/dL as the eGFR equation used it, when the laboratory reported another unit. Derived."
* #hiv-test "HIV test result" "Reactive or non-reactive, as the laboratory reports it. The test method is not captured, so no LOINC code asserting one is used."
* #fbc-taken "Full blood count taken" "Whether a full blood count was taken. The count itself is not captured. True or false."

// Imaging
* #images-dilated "Images taken with dilation" "True or false."
* #images-right "Image captured of the right eye" "True or false."
* #images-left "Image captured of the left eye" "True or false."
* #images-synced "Images synced to the device cloud storage" "True or false."
