// Healthy Route — Consent
//
// Consent is taken on paper and signed by hand. This profile is not the
// consent; it is the record that consent was taken. The paper remains the
// legal instrument and, under the protocol, stays in the site file with the
// investigator for five years after the study completes.
//
// What the protocol requires of the record is a statement that written
// informed consent was obtained, the date it was obtained, and the identity of
// the authorised person who took it. Those are date, decision and verification
// below, and they are sufficient on their own. A photograph of the signed page
// is not required and is not assumed; where a site chooses to hold one, it is
// referenced from sourceReference and profiled as HRConsentEvidence.
//
// One Consent resource carries one permission. R5 offers an alternative —
// a single Consent whose provisions carve exceptions out of a base decision —
// and it is not used here. Consent.provision has no type element in R5, so
// sibling provisions cannot each carry their own permit or deny; the decision
// is expressed once, at the root. Recording each permission as its own
// resource means a participant who withdraws one of them is served by setting
// that resource's status to inactive, which leaves an auditable record and
// does not require editing a structure shared with the permissions they kept.

Profile: HRConsent
Parent: Consent
Id: hr-consent
Title: "Healthy Route Consent"
Description: "The record that a participant granted or refused one permission, and the index to the page they signed."
* ^status = #draft
* ^experimental = false
* ^purpose = "Establishes the lawful basis for every subsequent resource held about the participant. A screening encounter, a specimen or a retinal image that cannot be traced to an active consent for the permission it relies on is a finding at audit, and this resource is what makes that traceable rather than a matter of correspondence."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS
* status ^requirements = "Withdrawal is recorded by setting this to inactive. The resource is not deleted and its content is not altered, so the fact that consent was once held, and the date it ceased, remain available to an auditor."
* status ^comment = "draft is used between the point at which the participant signs and the point at which the record has been checked against the paper. A draft consent does not authorise any activity."

* category 1..* MS
* category ^slicing.discriminator[0].type = #value
* category ^slicing.discriminator[0].path = "coding.system"
* category ^slicing.rules = #open
* category ^slicing.description = "Sliced by coding system to require exactly one permission code while permitting the HL7 consent category codes alongside it."
* category contains permission 1..1 MS
* category[permission] from HRConsentPermissionVS (required)
* category[permission] ^short = "Which permission this resource records"
* category[permission].coding 1..1 MS
* category[permission].coding.system 1..1 MS
* category[permission].coding.system = $hr-consent-permission
* category[permission] ^comment = "One permission per resource. A participant who is asked three questions on one form is represented by three resources sharing a date and a source reference."

* subject 1..1 MS
* subject only Reference(HRPatient)
* subject ^comment = "Constrained to Patient. Consent is never taken from a practitioner or a group in this study, and the base resource permits both."

* date 1..1 MS
* date ^short = "Date the participant signed"
* date ^requirements = "Compared against the date of the earliest study activity. An encounter, specimen or image dated before this is a protocol deviation, and the comparison is only possible if the signature date rather than the data entry date is recorded here."
* date ^comment = "The date on the paper form, which may precede the date the record was created."

* period MS
* period ^short = "Period over which the permission applies"
* period ^comment = "Distinct from the retention period stated in the information sheet. Present where the permission itself is time limited."

* grantor 1..1 MS
* grantor only Reference(HRPatient)
* grantor ^comment = "The participant. Recorded separately from subject because the two differ where consent is given by a legal representative, which this study does not currently permit but which the resource must not preclude."

* grantee 1..* MS
* grantee only Reference(Organization)
* grantee ^short = "Party the permission is granted to"
* grantee ^requirements = "The information sheet names the parties who will hold the data. Where a permission extends beyond the site to the sponsor, both appear here, and a permission naming only the site does not authorise transfer."

* controller MS
* controller only Reference(Organization)
* controller ^short = "Data controller"

* decision 1..1 MS
* decision ^short = "permit or deny"
* decision ^requirements = "Required, where the base resource makes it optional. A consent record whose decision is absent cannot be acted on, and its absence is indistinguishable from a refusal that was never recorded."
* decision ^comment = "A refusal is recorded as an active consent with a decision of deny, not as an absent resource. The distinction between a participant who declined and a participant who was never asked is material at audit."

* regulatoryBasis MS
* regulatoryBasis ^short = "Regulatory framework the consent was taken under"
* regulatoryBasis ^comment = "The national research regulation that governs the site, which differs between participating countries. Country variation is carried on instances rather than by separate profiles."

* policyBasis 1..1 MS
* policyBasis.url 1..1 MS
* policyBasis.url ^short = "Versioned identifier of the approved information sheet"
* policyBasis.url ^requirements = "Ethics committees approve a specific version of the participant information sheet and consent form. Establishing which version a participant was shown is the first question asked when a form is amended mid-study, and it cannot be answered from the signature alone."
* policyBasis.url ^comment = "Identifies a version, not a document to display. The document itself is referenced from policyText."

* policyText MS
* policyText only Reference(HRDocumentReference)
* policyText ^short = "The approved blank information sheet and consent form"
* policyText ^comment = "The unsigned template as approved, identical for every participant given that version. Not to be confused with sourceReference, which is the individual signed page and is identifying."

* sourceReference 0..1 MS
* sourceReference only Reference(HRConsentEvidence)
* sourceReference ^short = "The photographed signed page"
* sourceReference ^comment = "Optional, and expected to be absent at most sites. The protocol requires the investigator to retain the signed form and states that no records may be transferred to another location or party without written notification to the sponsor; it requires the medical record to carry a statement that consent was obtained and the date, which this resource satisfies without an image. Present only where a site has chosen to hold a photograph of the page within its own tenant and its ethics committee has approved that, which is a decision beyond the protocol rather than one it mandates."

* verification 1..1 MS
* verification.verified 1..1 MS
* verification.verifiedBy 1..1 MS
* verification.verifiedBy only Reference(Practitioner)
* verification.verifiedBy ^short = "Person who took consent"
* verification.verifiedBy ^requirements = "Good clinical practice requires that consent be taken by a person authorised to do so on the delegation log, and the protocol requires that person to sign the form. Recording who took it is what allows that authorisation to be checked after the fact."
* verification.verifiedBy ^comment = "The individual, not the organisation and not the role they held. The base resource admits all three; an organisation cannot be delegated to take consent, and recording the role rather than the person would leave the identity of the signatory on the paper form unmatched in the record. Where the delegation itself needs to be established, a PractitionerRole referring to the same practitioner carries it."
* verification.verificationDate 1..1 MS
