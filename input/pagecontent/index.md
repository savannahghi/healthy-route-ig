<div style="display:flex;align-items:center;gap:14px;padding:4px 0 18px;border-bottom:3px solid #B5177E;margin-bottom:22px">
  <img src="optimalhealth-logo.svg" alt="" width="36" height="36"/>
  <span style="font-weight:700;font-size:20px;color:#1A1A2E">OptimalHealth</span>
  <span style="margin-left:auto;font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:#6E6880">Healthy Route</span>
</div>

### Healthy Route Implementation Guide

Clinical data management profiles for the AstraZeneca Healthy Heart Africa
validation study of a machine-learning algorithm predicting chronic kidney
disease from digital retinal images.

The study runs in five countries under one approved protocol per country, with
approximately 500 participants in each.

> Each country's approved protocol takes precedence over this guide for that
> country. Where this guide and a protocol disagree, the protocol is correct.

#### Scope of this release

| Area | Status |
| --- | --- |
| [Participant](patient.html) | defined |
| [Consent](consent.html) | defined |
| [Documents](documents.html) | defined |
| Sites, people and study participation | in preparation |
| Encounter, measurement and specimens | in preparation |
| Imaging metadata and algorithm output | in preparation |
| Referral, export and audit | in preparation |

#### Two principles carried through every profile

**The de-identification boundary is expressed as cardinality.** Participant data
exists in two forms and this guide constrains both. Elements that may not leave a
site tenant are set to a cardinality of `0..0` on the export profile, so a
resource containing one fails validation rather than passing review. The boundary
is enforced by the same tooling that validates every other conformance rule. See
[participant](patient.html).

**Country variance is instance data, never a profile.** The participating
countries differ in thresholds, eligibility and sample size — not in structure.
Those differences belong in `ResearchStudy` and `PlanDefinition` instances. There
is deliberately no country-specific profile in this guide, and there will not be
one.

#### The participant identifier

A single opaque identifier, issued at registration, serves as the participant
identifier within the tenant, the study identifier on the case report form, and
the value entered on the retinal camera at image capture. It is retained
unchanged across rescreening.

```
https://fhir.savannahghi.org/sid/optimalhealth-participant
```

#### Tenancy

Every resource carries the [tenant extension](StructureDefinition-hr-tenant.html).
Records are partitioned by site, and partition membership is a property of the
record rather than of the storage location it happens to occupy.

#### Dependencies

{% include dependency-table.xhtml %}

#### Globals

{% include globals-table.xhtml %}

#### Terminology expansion parameters

{% include expansion-params.xhtml %}

#### Intellectual property

{% include ip-statements.xhtml %}
