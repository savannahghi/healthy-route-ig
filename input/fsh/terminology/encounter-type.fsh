// Healthy Route — the encounter type
//
// Both protocols allow the samples and the retinal photography up to 28 days
// after consent. The visit is still one encounter: everything recorded during it
// carries its own date, so the window is a query over those dates.

CodeSystem: HREncounterTypeCS
Id: hr-encounter-type
Title: "Encounter Type"
Description: "The kinds of encounter the study records. Today there is one, the study visit."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #visit "Study visit" "The visit at which a participant is consented, screened, measured, sampled and photographed."

ValueSet: HREncounterTypeVS
Id: hr-encounter-type-vs
Title: "Encounter Type Value Set"
Description: "The kinds of encounter the study records."
* ^status = #draft
* ^experimental = false
* include codes from system HREncounterTypeCS
