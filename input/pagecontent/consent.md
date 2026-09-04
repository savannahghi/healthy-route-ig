The record that a participant granted or refused a permission.

### What this profile is not

It is not the consent. Consent is taken on paper and signed by hand, and the
paper is the legal instrument. Under the protocol it stays in the site file with
the investigator for five years after the study completes, and no records may be
transferred to another location or party without written notification to the
sponsor.

What the protocol requires of the electronic record is narrower and specific: a
statement that written informed consent was obtained, the date it was obtained,
and the identity of the authorised person who took it. That is
[HRConsent](StructureDefinition-hr-consent.html), and those three facts are
sufficient on their own.

### One resource per permission

A participant signs one form and is asked several things by it. Those things are
recorded separately, because they are withdrawn separately.

| Code | Permission |
| --- | --- |
| `study-participation` | to be screened, to give samples, and to have the resulting data analysed |
| `image-retention` | that retinal images may be retained after analysis, for the period stated in the information sheet |
| `future-research` | that data and images may be used beyond the study described, subject to further ethics approval |

A participant who asks for their images to be destroyed while remaining in the
study is served by setting the `image-retention` resource's `status` to
`inactive`. The resource is not deleted and its content is not altered, so the
fact that the permission was once held, and the date it ceased, remain available.
The permissions they kept are untouched.

#### Why not provisions

R5 offers an alternative shape: a single Consent whose `provision` entries carve
exceptions out of a base `decision`. This guide does not use it.

`Consent.provision` has no `type` element in R5. Permit and deny are expressed
once, at `Consent.decision`, and provisions are exceptions to that base rather
than independently signed permissions. Sibling provisions therefore cannot each
carry their own decision, which is precisely what three separately revocable
permissions require.

There is a consequence worth stating. The R5 specification notes that in a fully
computable consent the actors appear within `provision`, and that `grantor` and
`grantee` exist "for ease of search only". Because this guide does not use
provisions, `grantor` and `grantee` are the only record of who granted what to
whom. That is adequate for a consent read by people and by export logic. It would
not be adequate for one enforced by a policy engine.

### A refusal is a record, not an absence

`decision` is required at `1..1`, where the base resource makes it optional.

A participant who declines is recorded as an **active** consent with a decision
of `deny`. They are not recorded by the absence of a resource. The distinction
between a participant who was asked and declined, and a participant who was never
asked, is material at audit and is not recoverable later if it was never written
down.

An absent `decision` would be indistinguishable from a refusal that nobody
recorded, which is why the base resource's optional cardinality is tightened
here.

### Which version of the form

`policyBasis.url` is required. It identifies the approved version of the
participant information sheet and consent form that this participant was shown.

Ethics committees approve a specific version. The protocol requires participants
to be re-consented to the current version during their participation. When a form
is amended mid-study, the first question asked is which version each participant
signed, and a signature does not answer it.

`policyBasis.url` identifies a version. `policyText` references the document
itself — the approved blank form, identical for every participant given that
version, profiled as
[HRDocumentReference](StructureDefinition-hr-document-reference.html). Neither is
the individual signed page; see [documents](documents.html).

### Who took it

`verification.verifiedBy` is required and constrained to `Practitioner`.

Good clinical practice requires consent to be taken by a person authorised to do
so on the delegation log, and the protocol requires that person to sign the form.
Recording who took it is what allows the authorisation to be checked afterwards.

The base resource admits `Organization` and `PractitionerRole` as well. Both are
excluded. An organisation cannot be delegated to take consent, and recording a
role rather than a person would leave the signatory on the paper form unmatched
in the electronic record. Where the delegation itself must be established, a
`PractitionerRole` referring to the same practitioner carries it.

### Status and the draft window

`draft` covers the interval between the participant signing and the record being
checked against the paper. A draft consent authorises nothing.

`active` is the state in which the permission is in force, whether the decision
was permit or deny. `inactive` records withdrawal.

### Relationship to everything else

Every resource the study holds about a participant depends on an active consent
for the permission it relies on. A screening encounter, a specimen or a retinal
image that cannot be traced to one is a finding at audit, and this profile is
what makes that traceable rather than a matter of correspondence.
