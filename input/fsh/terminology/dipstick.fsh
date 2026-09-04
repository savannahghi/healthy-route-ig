// Healthy Route — urine dipstick protein scale
//
// Defined, and deliberately not bound to anything.
//
// The scale is printed on the protocols' own data collection tool, which lists
// Negative, Trace, +1, +2 and +3 as fixed options. Values reach the record by
// transcription from that form, so the constraint that matters is on the entry
// screen rather than on a StructureDefinition. LOINC publishes an answer list
// for 5804-0 but it is not expandable on the public terminology server, so a
// binding would have had to invent a local scale and require it of every site.
//
// This exists so that whoever builds the form has a canonical list to build
// from, and so that a consumer reading the data knows what the values mean.

CodeSystem: HRDipstickProteinCS
Id: hr-dipstick-protein
Title: "Urine Dipstick Protein Scale"
Description: "The ordinal scale printed on the study's data collection tool for urine dipstick protein."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete

* #negative "Negative" "No protein detected."
* #trace "Trace" "The lowest positive reading on the strip. Both protocols treat trace as positive."
* #1plus "+1"
* #2plus "+2"
* #3plus "+3"

ValueSet: HRDipstickProteinVS
Id: hr-dipstick-protein-vs
Title: "Urine Dipstick Protein Value Set"
Description: "Permitted results for urine dipstick protein, as printed on the data collection tool."
* ^status = #draft
* ^experimental = false
* include codes from system HRDipstickProteinCS
