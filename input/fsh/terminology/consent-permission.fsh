// Healthy Route — consent permissions
//
// The participant is asked to agree to several things at once, on one paper
// form. They are recorded separately because they are withdrawn separately: a
// participant may ask for their images to be destroyed while remaining in the
// study, and the study must be able to honour that without discarding the
// consent to the rest.
//
// consentcategorycodes carries no code for either of the permissions below.
// Its research code describes access to research information generally, which
// does not distinguish retention of an image from participation in a screening.

CodeSystem: HRConsentPermissionCS
Id: hr-consent-permission
Title: "Consent Permission"
Description: "The permissions a Healthy Route participant is asked to grant, each recorded as a separate Consent."
* ^status = #draft
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete

* #study-participation "Study participation"
    "Agreement to be screened, to give the samples the protocol requires, and to have the resulting data used for the analysis described in the information sheet."
* #image-retention "Retention of retinal images"
    "Agreement that retinal images may be retained after the analysis is complete, for the period stated in the information sheet."
* #future-research "Use in future research"
    "Agreement that data and images may be used in research beyond the study described in the information sheet, subject to further ethics approval."

ValueSet: HRConsentPermissionVS
Id: hr-consent-permission-vs
Title: "Consent Permission Value Set"
Description: "The permissions a Healthy Route participant is asked to grant."
* ^status = #draft
* ^experimental = false
* include codes from system HRConsentPermissionCS
