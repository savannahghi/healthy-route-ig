// Healthy Route — Documents
//
// HRDocumentReference     Any document the study holds. Constrains what is
//                         true of all of them and nothing else.
// HRConsentEvidence       The photographed page a participant signed.
//
// The study holds several kinds of document and will hold more: the approved
// blank information sheet and consent form, the signed page, laboratory
// reports, and the letter sent with a participant who is referred. They differ
// in almost every respect, so the base profile is deliberately small.
//
// Two constraints are placed there rather than repeated. The tenant extension,
// so that a document profile added later cannot omit it; and the prohibition
// on inline content, so that the decision to hold documents as files in
// storage rather than as base64 inside the resource is made once.
//
// Two constraints are deliberately absent from the base. subject stays
// optional, because the approved blank form is a document about no one.
// securityLabel stays unconstrained, because the blank form is the approved
// public text while the signed page is the most identifying object the study
// holds, and a classification correct for one is wrong for the other.

Profile: HRDocumentReference
Parent: DocumentReference
Id: hr-document-reference
Title: "Healthy Route Document"
Description: "Any document held by the study, in the form common to all of them."
* ^status = #draft
* ^experimental = false
* ^abstract = false
* ^purpose = "Carries the constraints that hold for every document regardless of its purpose, so that they are inherited rather than restated. Profiles derived from it narrow it to a particular kind of document; it is usable directly for documents that need no further constraint."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS

* subject 0..1 MS
* subject only Reference(HRPatient)
* subject ^comment = "Optional. A document about a participant references them here; a document such as the approved blank consent form is about no one and omits it. Constrained to Patient in either case, because the base resource permits a reference to any resource type at all."

* date 1..1 MS
* date ^short = "When the document was registered"
* date ^comment = "When this record was created, which is not necessarily when the document itself was produced or signed."

* custodian 1..1 MS
* custodian only Reference(Organization)
* custodian ^short = "Organisation holding the original"
* custodian ^requirements = "What is held here is a copy. Establishing who holds the original is a routine step in monitoring and is not derivable from the tenant once a site operates more than one physical location."

* content 1..1 MS
* content.attachment 1..1 MS
* content.attachment.contentType 1..1 MS
* content.attachment.url 1..1 MS
* content.attachment.url ^requirements = "Referencing the file rather than embedding it keeps it out of the response to every read of this resource, and allows access to the document to be authorised and logged separately from access to the metadata describing it."
* content.attachment.data 0..0
* content.attachment.data ^comment = "Inline content is prohibited. Base64 content travels wherever the resource travels, including into search bundles and audit payloads assembled for unrelated purposes."
* content.attachment.hash MS
* content.attachment.hash ^short = "SHA-1 hash of the file"
* content.attachment.hash ^requirements = "Distinguishes an unchanged document from one that has been replaced in storage since it was registered. The question is only ever asked long after the fact, so the hash has to have been recorded at the time."


// The photograph of the page the participant signed.
//
// Optional, and not required by the protocol. The protocol requires the
// investigator to retain the signed form for five years and states that no
// records may be transferred to another location or party without written
// notification to the sponsor. What it requires of the record is a statement
// that consent was obtained and the date it was obtained, which HRConsent
// carries on its own. This profile exists for sites that choose to hold the
// page within their own tenant, and using it is a decision for the site and
// its ethics committee rather than one the protocol settles.
//
// The image carries a name and a signature together, which makes it the most
// directly identifying object the study holds. Nothing about it is
// de-identifiable: a redacted signature is not evidence that consent was given.
//
// It is therefore never exported. There is no export counterpart to this
// profile, and the absence is deliberate — the export set is defined by
// enumerating what may leave a tenant, so a resource type that is not
// enumerated cannot be selected by an export query. Adding one later would be
// an addition to that list and would be visible as such in review.

Profile: HRConsentEvidence
Parent: HRDocumentReference
Id: hr-consent-evidence
Title: "Healthy Route Consent Evidence"
Description: "The photographed page a participant signed, referenced by the consent it evidences."
* ^status = #draft
* ^experimental = false
* ^purpose = "Holds the signed paper in retrievable form. A monitor asked to verify that a participant consented before a given procedure needs the page itself, and retrieving it from a site file in another country is not a practical answer during a remote monitoring visit."

* status ^comment = "Set to superseded when a participant re-consents to a later version of the form. The earlier page is retained rather than replaced, because it remains the evidence for activity that took place while it was in force."

* docStatus MS
* docStatus ^comment = "final once the page has been checked as legible and complete. A photograph that cuts off the signature is recorded as preliminary, though only a human can tell the difference."

* type MS
* type ^short = "Document type"
* type ^comment = "Left to the instance rather than fixed here. The binding inherited from the base resource is preferred rather than required, and fixing a single code would prevent sites recording the distinct document types used by their national ethics frameworks."

* subject 1..1 MS
* subject ^comment = "Required, where the base profile leaves it optional. A signed page that is not tied to the participant who signed it is not evidence of anything."

* author MS
* author only Reference(Practitioner or PractitionerRole or Organization)
* author ^short = "Who captured the page"

* attester MS
* attester ^short = "Witness to the signature"
* attester ^comment = "Used where the participant cannot read the form and it is read to them in the presence of an impartial witness, a case the protocol provides for and which the signature alone does not evidence."

* relatesTo MS
* relatesTo ^short = "The page this one replaces"
* relatesTo ^requirements = "A participant who re-consents to an amended form produces a second page. Linking the two is what allows the version in force on a given date to be established, which is the question asked when an amendment is made mid-study."
* relatesTo.code ^comment = "replaces for re-consent to an amended form."

* securityLabel 1..* MS
* securityLabel ^slicing.discriminator[0].type = #value
* securityLabel ^slicing.discriminator[0].path = "coding.system"
* securityLabel ^slicing.rules = #open
* securityLabel ^slicing.description = "Sliced by coding system to require a confidentiality classification while permitting additional labels."
* securityLabel contains confidentiality 1..1 MS
* securityLabel[confidentiality] = $v3-Confidentiality#R
* securityLabel[confidentiality] ^short = "Restricted"
* securityLabel[confidentiality] ^requirements = "Applied at creation rather than assigned by policy at read time, so that a copy of the resource carries its classification with it and does not depend on the server that serves it to apply one."
