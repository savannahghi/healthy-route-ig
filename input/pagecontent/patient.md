The participant, in the two forms the study holds them.

### Why there are two profiles

A validation study of this kind holds the same person twice. The site needs to
recognise a returning participant, avoid enrolling them a second time, and match
their record to the paper form in the site file. The receiving party needs age, sex and a
key that links a retinal image to a laboratory result, and needs nothing else.

Those are not two views of one record. They are two records with different
contents, and the boundary between them is the point at which participant data
leaves the country it was collected in.

| Profile | Held | Contains |
| --- | --- | --- |
| [HRPatient](StructureDefinition-hr-patient.html) | within a site tenant | name, date of birth, contact number, participant identifier |
| [HRExportPatient](StructureDefinition-hr-export-patient.html) | transferred out of the tenant | participant identifier, sex, age in completed years |

### The constraint is cardinality, not documentation

`HRExportPatient` sets `name`, `telecom`, `address`, `photo`, `contact`,
`birthDate`, `deceased[x]`, `generalPractitioner` and `link` to a cardinality of
`0..0`.

That is deliberate, and it is the central design decision of this guide. A
resource carrying a direct identifier does not merely violate a policy written in
a document that someone has to read: it fails validation against the export
profile, using the same tooling that validates every other conformance rule. A
de-identification failure is therefore a build failure rather than a finding at
audit.

The list is an allow-list expressed as a deny-list of everything else. Adding an
element to what may be exported is a change to this profile, visible in review as
a change to this profile.

### Age, not date of birth

`HRExportPatient` prohibits `birthDate` and requires the
[age in completed years](StructureDefinition-hr-age-years.html) extension
instead.

Analysis requires age. The CKD-EPI 2021 equation takes age as a coefficient, and
the algorithm under validation takes it as a model input. Neither requires a date
of birth. A date of birth, combined with a site and an encounter date, approaches
a unique identifier in a cohort of a few hundred people per country, and it is
that combination rather than the date alone that makes it worth removing.

### The participant identifier

One opaque identifier, issued at registration, does three jobs:

- it identifies the participant within the tenant
- it is the study identifier written on the case report form
- it is the value typed into the retinal camera at image capture

A single identifier across all three means an image captured on the device can be
matched to the participant record at the receiving party without any second key passing
between the parties.

```
https://fhir.savannahghi.org/sid/optimalhealth-participant
```

It encodes nothing about the person or the site, and it is retained unchanged
across rescreening, so a participant screened twice is not issued a second
identifier.

It is held in `Patient.identifier` and deliberately not in `Resource.id`.
Resource identifiers appear in request URLs, server logs and cache keys, none of
which are covered by de-identification of resource content.

### Pseudonymous, not anonymous

The exported record is not anonymous, and the guide does not claim it is.
Re-identification remains possible to the site holding the corresponding
registration record, and to no other party. That is the property the study
requires: a participant who withdraws must be traceable at their own site, and
untraceable everywhere else.

### What is required, and why

| Element | Cardinality | Reason |
| --- | --- | --- |
| `identifier[participantId]` | `1..1` | the key linking record, form and image |
| `name` | `1..1` | matches the electronic record to the signed consent form, which carries a handwritten name and no study identifier |
| `name.family` | `1..1` | a mononymous participant records the single name here |
| `birthDate` | `1..1` | derives age |
| `gender` | `1..1` | a coefficient in CKD-EPI 2021 and a direct model input — a record without it cannot be analysed |
| `telecom` | `0..*` | contributes to the site's duplicate-enrolment log |

`telecom` is deliberately optional. Enrolment must not depend on a participant
owning a telephone.

#### Two of these are decisions, not protocol requirements

`name` and `birthDate` are required here because a site needs to recognise a
returning participant and tie the record to a signed sheet of paper. **Neither
protocol asks for either.** Their shared data collection tool records date, study
identifier, contact number, age and gender; Uganda specifies that duplicate
enrolment be prevented by a confidential local log of coded identifiers, held at
the site and never transmitted.

A site operating strictly from that tool would hold neither a name nor a date of
birth, and could not produce a resource valid against this profile. `birthDate`
is also in tension with the rest of the guide, which prohibits it on export as a
re-identification risk and states elsewhere that analysis needs age rather than a
full date.

Whether both should be relaxed to `0..1` is open, and is a question about how
sites will actually operate rather than about FHIR.

Where only a year, or a year and month, of birth are known, a partial date is
recorded and age is derived to the precision available.

### Tenant

Every resource holding participant data carries the
[tenant extension](StructureDefinition-hr-tenant.html). Records are partitioned
by site, and partition membership is a property of the record rather than of the
storage location it happens to sit in. The resources describing
[sites and people](sites.html) do not carry it, because they describe the
partitions rather than sitting inside one.
