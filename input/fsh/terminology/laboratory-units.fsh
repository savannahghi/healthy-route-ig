// Healthy Route — the units laboratories report in
//
// Each site's laboratory reports in its own units, and the record keeps the
// value in the unit it was reported in. This is the list a site chooses from.
// The LOINC code of a result follows the unit: a creatinine in mg/dL is
// 2160-0 and one in umol/L is 14682-9, because LOINC separates mass from molar
// concentration, and the form's map picks the code from the unit.

ValueSet: HRLabUnitVS
Id: hr-lab-unit-vs
Title: "Laboratory Units Value Set"
Description: "The UCUM units a site's laboratory may report the study's results in."
* ^status = #draft
* ^experimental = false
* $ucum#umol/L "micromole per litre"
* $ucum#mg/dL "milligram per decilitre"
* $ucum#mmol/L "millimole per litre"
* $ucum#mg/g "milligram per gram"
* $ucum#mg/mmol "milligram per millimole"
* $ucum#% "percent"
