// Healthy Route — how a form counts towards signing a visit
//
// The investigator signs a visit once its forms are saved. A form the protocol
// leaves to the clinician's discretion carries the code below as a tag, and the
// study service signs a visit without it; when it was saved, it is signed with
// the rest.

CodeSystem: HRSignoffCS
Id: hr-signoff
Title: "Sign-off"
Description: "How a form counts towards signing a visit. Carried as a tag on the form."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #optional "Optional at sign-off" "A visit can be signed without a response to this form. A response saved at the visit is signed with the rest."
