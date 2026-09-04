Where the study runs, and who runs it.

### Three resources, one purpose

| Profile | Represents |
| --- | --- |
| [HROrganization](StructureDefinition-hr-organization.html) | a hospital running the study, or another party to it |
| [HRLocation](StructureDefinition-hr-location.html) | a clinic within a hospital, where participants are approached |
| [HRPractitioner](StructureDefinition-hr-practitioner.html) | a member of the study team |

Until these existed, [HRConsent](StructureDefinition-hr-consent.html) and
[HRDocumentReference](StructureDefinition-hr-document-reference.html) required an
organisation and a practitioner that no profile described, at a cardinality of
`1..1`. Those references now resolve within the guide.

### None of them carries the tenant extension

This is the one place the tenancy rule does not apply, and the exception is
deliberate.

The extension records which site partition a record belongs to. These three
resources describe the partitions rather than sitting inside one. A site's tenant
is the identity of its organisation; a location resolves to one through
`managingOrganization`; a practitioner through the site that registered them.
Carrying the extension here as well would state the same fact twice and allow the
two statements to disagree.

`Location.managingOrganization` is therefore required at `1..1`. It is not a
convenience: it is how a location resolves to a partition at all, and a location
without one belongs nowhere.

### Why the clinic matters, not just the hospital

Both protocols recruit from the **general out-patient, hypertension, diabetes and
renal clinics** of their sites. That is not incidental detail.

A cohort drawn mostly from a renal clinic is not the same cohort as one drawn
mostly from general out-patients, even in the same hospital. Disease prevalence
differs between them, and predictive values move with prevalence. A study
reporting a positive predictive value without recording where its participants
were recruited from has reported a number that cannot be transferred to the
screening population the algorithm is intended for.

So `Location.type` is Must Support, and the location a participant was approached
at is recorded rather than assumed from the site.

`Location.type` binds extensibly to the HL7 service delivery location role
types, which cover three of the four clinics the protocols name — `GIM` for
general internal medicine, `ENDO` for endocrinology, `NEPH` for nephrology. There
is **no standard code for a hypertension clinic**. An extensible binding permits a
local code or plain text where no standard code exists, and this is a case for it
rather than for forcing the clinic into an approximate code that would then be
analysed as though it were exact.

`Location.mode` is fixed to `instance`. Every location here is a specific clinic
that exists, never a class of clinic described in the abstract — a reference to a
kind of place cannot be the place a participant was actually seen.

### Deactivation, not deletion

`Organization.active` and `Practitioner.active` are both required at `1..1`,
where the base resources make them optional.

Sites close to recruitment and staff leave, and in both cases the record has to
survive the event. A closed site still owns its records. A practitioner who has
left is still the person who took consent from forty participants, and a dangling
reference is not an improvement on a record of someone who has moved on.

A consumer that cannot distinguish active from inactive will offer a closed site
as somewhere to enrol.

### Staff are data subjects too

`HRPractitioner` prohibits `birthDate`, `address`, `photo` and `deceased[x]`.

The profile records what a delegation log needs — that a named, identifiable,
authorised person performed an act — and nothing beyond it. None of the
prohibited elements contributes to establishing that. This is the same
minimisation applied to participants on
[HRExportPatient](StructureDefinition-hr-export-patient.html), for the same
reason and by the same mechanism.

`identifier` is required at `1..*`. A name does not establish authorisation. A
registration or staff number is what connects this record to an entry on the
delegation log and to a professional register that can be checked independently.

### Training

`Practitioner.qualification` is Must Support.

Both protocols require study team members to be trained in the procedures they
perform, and both specify that retinal image capture is carried out by a member
of the team who has undergone training. Whether a given person was trained for a
given procedure is a question a monitor asks directly, and it cannot be answered
from a name.

### What is not here yet

The protocols distinguish **study staff** — who capture images and identify
abnormal findings — from **study medical staff**, who receive those findings and
complete referrals. That is a distinction between roles, not between people, and
the same person may hold both.

`PractitionerRole` is where a role, the organisation it is held at, and the period
it was held for belong, and it is what would make the delegation log a query
rather than a document. It is not yet defined in this guide.
