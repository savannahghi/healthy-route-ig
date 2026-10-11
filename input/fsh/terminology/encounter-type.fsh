// Healthy Route — the parts of a visit
//
// Both protocols allow the samples and the retinal photography up to 28 days
// after consent. A visit is therefore one parent encounter and a dated child
// encounter for each part that can fall on its own day, so that the window is a
// query over encounter dates rather than a note.

CodeSystem: HREncounterTypeCS
Id: hr-encounter-type
Title: "Visit Part"
Description: "The visit, and the parts of it that carry their own date."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #visit "Study visit" "The parent encounter that the parts belong to."
* #consent "Consent" "The day consent was taken."
* #measure "Measurement" "The interview, anthropometry and blood pressure readings."
* #samples "Samples" "The day blood and urine were drawn for the laboratory."
* #imaging "Imaging" "The day the retina was photographed."

ValueSet: HREncounterTypeVS
Id: hr-encounter-type-vs
Title: "Visit Part Value Set"
Description: "The visit and its dated parts."
* ^status = #draft
* ^experimental = false
* include codes from system HREncounterTypeCS
