// Healthy Route — a category for derived values
//
// FHIR's observation categories say what kind of value an Observation holds: a
// vital sign, a laboratory result, a survey answer. None says the value was
// worked out rather than measured or asked, and no published guide adds one. A
// derived value keeps its FHIR category and carries this one beside it, so a
// reader can ask for the derived values alone with one search on category.

CodeSystem: HRObservationCategoryCS
Id: hr-observation-category
Title: "Observation Category"
Description: "Categories the study adds to FHIR's observation categories. Today there is one, for values worked out rather than measured or asked."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #derived "Derived" "Worked out from other recorded values, by a calculation on the form or by the study's rules at sign-off, rather than measured or asked."

ValueSet: HRObservationCategoryVS
Id: hr-observation-category-vs
Title: "Observation Category Value Set"
Description: "The categories the study adds to FHIR's observation categories."
* ^status = #draft
* ^experimental = false
* include codes from system HRObservationCategoryCS
