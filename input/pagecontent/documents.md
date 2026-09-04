Every document the study holds, and the one that carries a signature.

### Two profiles, one small and one specific

[HRDocumentReference](StructureDefinition-hr-document-reference.html) constrains
what is true of every document regardless of purpose.
[HRConsentEvidence](StructureDefinition-hr-consent-evidence.html) derives from it
and describes the photographed page a participant signed.

The study already holds two kinds of document and will hold more: the approved
blank information sheet and consent form, the signed page, laboratory reports,
and the letter sent with a participant who is referred. They differ in almost
every respect, so the base profile is deliberately small.

### What the base decides, and why only that

Two constraints are placed on the base rather than repeated on each derived
profile.

**The tenant extension is required.** A document profile added later cannot omit
it. This is the whole reason the base exists: an invariant enforced by
inheritance does not depend on the next author remembering it.

**Inline content is prohibited.** `content.attachment.data` is `0..0` and
`content.attachment.url` is `1..1`. Base64 content travels wherever the resource
travels, including into search bundles and audit payloads assembled for entirely
unrelated purposes. Referencing the file keeps it out of the response to every
read, and allows access to the document to be authorised and logged separately
from access to the metadata describing it.

`content.attachment.hash` is Must Support. The question of whether a stored file
is still the file that was registered is only ever asked long after the fact, and
it cannot be answered unless the hash was recorded at the time.

### What the base deliberately does not decide

Two constraints are absent from the base, and their absence is the reason the
split falls where it does.

**`subject` stays `0..1`.** The approved blank consent form is a document about
no one. Requiring a subject on the base would make it unrepresentable. The type
is still constrained to `Patient`, so a document is never hung off an arbitrary
resource — but it may have no subject at all.

**`securityLabel` stays unconstrained.** The blank form is the approved public
text. The signed page is the most identifying object the study holds. A
classification correct for one is wrong for the other, and a base profile that
picked either would be wrong half the time.

### The signed page

`HRConsentEvidence` is **optional, and not required by the protocol.**

The protocol requires the investigator to retain the signed form and states that
no records may be transferred to another location or party without written
notification to the sponsor. What it requires of the record is a statement that
consent was obtained, the date, and who took it — all of which
[HRConsent](StructureDefinition-hr-consent.html) carries on its own.

This profile exists for sites that choose to hold the page within their own
tenant. Using it is a decision for the site and its ethics committee rather than
one the protocol settles.

#### It is never exported

The image carries a name and a signature together. Nothing about it is
de-identifiable: a redacted signature is not evidence that consent was given.

There is therefore no export counterpart to this profile, and the absence is
deliberate. The export set is defined by enumerating what may leave a tenant, so
a resource type that is not enumerated cannot be selected by an export query at
all. Adding one later would be an addition to that list, visible as such in
review.

`securityLabel` carries a restricted confidentiality classification, applied at
creation rather than assigned by policy at read time, so that a copy of the
resource carries its classification with it and does not depend on the server
that serves it to apply one.

#### Re-consent

A participant re-consenting to an amended form produces a second page. The
earlier page is set to `superseded` and retained rather than replaced: it remains
the evidence for activity that took place while it was in force. `relatesTo`
links the two, which is what allows the version in force on a given date to be
established.

#### Witnesses

`attester` covers the case where a participant cannot read the form and it is
read to them in the presence of an impartial witness. The protocol provides for
this, and a signature alone does not evidence it.

### Which profile for which document

| Document | Profile | Subject | Security label |
| --- | --- | --- | --- |
| approved blank consent form | `HRDocumentReference` | absent | none required |
| signed consent page | `HRConsentEvidence` | required | restricted |
| laboratory report | to be added | required | to be decided |
| referral letter | to be added | required | to be decided |
