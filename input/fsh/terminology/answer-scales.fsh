// Healthy Route — answer scales for the coded questions
//
// Each scale is printed on the study's forms as a fixed list, the way the
// dipstick scale is. The lists marked provisional are the Uganda data
// collection tool's as the platform manual reproduces them, and the study team
// has not yet confirmed their wording. A confirmed list replaces the codes
// here; nothing else in the guide refers to the individual codes.

CodeSystem: HRUseStatusCS
Id: hr-use-status
Title: "Use Status"
Description: "Whether a person currently uses something, used to, or never has. The history form asks it of alcohol and tobacco."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #current "Current"
* #past "Past"
* #nil "Nil" "Never."

ValueSet: HRUseStatusVS
Id: hr-use-status-vs
Title: "Use Status Value Set"
Description: "Current, past or nil."
* ^status = #draft
* ^experimental = false
* include codes from system HRUseStatusCS

CodeSystem: HRFrequencyScaleCS
Id: hr-frequency-scale
Title: "Frequency Scale"
Description: "How often a dietary habit occurs. Provisional: the wording follows the Uganda data collection tool and awaits the study team's confirmation."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #never "Never"
* #rarely "Rarely"
* #sometimes "Sometimes"
* #often "Often"
* #always "Always"

ValueSet: HRFrequencyScaleVS
Id: hr-frequency-scale-vs
Title: "Frequency Scale Value Set"
Description: "How often a dietary habit occurs."
* ^status = #draft
* ^experimental = false
* include codes from system HRFrequencyScaleCS

CodeSystem: HRWorkActivityCS
Id: hr-work-activity
Title: "Physical Activity at Work"
Description: "How physically demanding a person's work is. Provisional: the wording follows the Uganda data collection tool and awaits the study team's confirmation."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #sedentary "Mostly sitting"
* #light "Mostly standing or walking"
* #moderate "Moderate physical work"
* #vigorous "Heavy physical work"

ValueSet: HRWorkActivityVS
Id: hr-work-activity-vs
Title: "Physical Activity at Work Value Set"
Description: "How physically demanding a person's work is."
* ^status = #draft
* ^experimental = false
* include codes from system HRWorkActivityCS

CodeSystem: HRReactiveCS
Id: hr-reactive
Title: "Reactive or Non-reactive"
Description: "The result of a screening test as the laboratory reports it."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #reactive "Reactive"
* #non-reactive "Non-reactive"

ValueSet: HRReactiveVS
Id: hr-reactive-vs
Title: "Reactive or Non-reactive Value Set"
Description: "Reactive or non-reactive."
* ^status = #draft
* ^experimental = false
* include codes from system HRReactiveCS

CodeSystem: HRBloodPressurePositionCS
Id: hr-bp-position
Title: "Blood Pressure Reading Position"
Description: "Whether a blood pressure reading was taken before or after retinal capture."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #before-capture "Before retinal capture"
* #after-capture "After retinal capture"

ValueSet: HRBloodPressurePositionVS
Id: hr-bp-position-vs
Title: "Blood Pressure Reading Position Value Set"
Description: "Before or after retinal capture."
* ^status = #draft
* ^experimental = false
* include codes from system HRBloodPressurePositionCS

CodeSystem: HRBloodPressureDeviceCS
Id: hr-bp-device
Title: "Blood Pressure Monitors"
Description: "The monitors the protocol names, selected by participant size."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #omron-m6 "Omron M6" "For small, medium and large participants."
* #omron-hbp-110 "Omron HBP 110" "For obese participants."

ValueSet: HRBloodPressureDeviceVS
Id: hr-bp-device-vs
Title: "Blood Pressure Monitors Value Set"
Description: "The monitors the protocol names."
* ^status = #draft
* ^experimental = false
* include codes from system HRBloodPressureDeviceCS

CodeSystem: HREyeCS
Id: hr-eye
Title: "Eye"
Description: "Which eye. The programme does not license SNOMED CT, so laterality takes a local code rather than the SNOMED codes the base resource suggests."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #right "Right eye"
* #left "Left eye"

ValueSet: HREyeVS
Id: hr-eye-vs
Title: "Eye Value Set"
Description: "Right or left."
* ^status = #draft
* ^experimental = false
* include codes from system HREyeCS
