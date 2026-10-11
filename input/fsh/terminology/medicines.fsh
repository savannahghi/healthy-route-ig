// Healthy Route — how a medicine is taken
//
// The medicine itself is a code from the study's medicine catalogue on the
// terminology server, which carries strength and form with the product. These
// three scales describe how it is taken, as the medications form asks. All
// three are provisional: the wording follows the Uganda data collection tool
// and awaits the study team's confirmation.

CodeSystem: HRMedicineRouteCS
Id: hr-medicine-route
Title: "Medicine Route"
Description: "How a medicine is taken. Provisional."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #oral "Oral"
* #sublingual "Under the tongue"
* #injection "Injection"
* #topical "Applied to the skin"
* #inhaled "Inhaled"
* #rectal "Rectal"
* #other "Other"

ValueSet: HRMedicineRouteVS
Id: hr-medicine-route-vs
Title: "Medicine Route Value Set"
Description: "How a medicine is taken."
* ^status = #draft
* ^experimental = false
* include codes from system HRMedicineRouteCS

CodeSystem: HRDoseFormCS
Id: hr-dose-form
Title: "Dose Form"
Description: "The form a medicine is supplied in. Provisional."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #tablet "Tablet"
* #capsule "Capsule"
* #syrup "Syrup"
* #injection "Injection"
* #cream "Cream or ointment"
* #inhaler "Inhaler"
* #drops "Drops"
* #other "Other"

ValueSet: HRDoseFormVS
Id: hr-dose-form-vs
Title: "Dose Form Value Set"
Description: "The form a medicine is supplied in."
* ^status = #draft
* ^experimental = false
* include codes from system HRDoseFormCS

CodeSystem: HRMedicineFrequencyCS
Id: hr-medicine-frequency
Title: "Medicine Frequency"
Description: "How often a medicine is taken. Provisional."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #once-daily "Once a day"
* #twice-daily "Twice a day"
* #three-times-daily "Three times a day"
* #four-times-daily "Four times a day"
* #weekly "Once a week"
* #as-needed "When needed"
* #other "Other"

ValueSet: HRMedicineFrequencyVS
Id: hr-medicine-frequency-vs
Title: "Medicine Frequency Value Set"
Description: "How often a medicine is taken."
* ^status = #draft
* ^experimental = false
* include codes from system HRMedicineFrequencyCS
