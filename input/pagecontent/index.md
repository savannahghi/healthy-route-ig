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
> country.

#### Scope of this release

This release defines the Patient profiles only. Profiles for consent,
participation, measurement, imaging metadata, referral and export are in
preparation and will be added in subsequent releases.

#### The de-identification boundary

Participant data exists in two forms, and this guide constrains both.

`HRPatient` is held within a site tenant and carries the identifiers required to
operate the study locally. `HRExportPatient` is the form transferred to the
sponsor, in which direct identifiers are constrained to a cardinality of 0..0.

The constraint is expressed as cardinality rather than as a documented
transformation so that a resource containing a direct identifier fails
validation against the export profile. De-identification is therefore verifiable
by the same tooling that validates every other conformance rule.

#### Identifiers

A single opaque identifier, issued at registration, serves as the participant
identifier within the tenant, the study identifier on the case report form, and
the value entered on the retinal camera at image capture. It is retained
unchanged across rescreening.

The identifier system is `https://fhir.savannahghi.org/sid/optimalhealth-participant`.

#### Dependencies

{% include dependency-table.xhtml %}

#### Globals

{% include globals-table.xhtml %}

#### Terminology expansion parameters

{% include expansion-params.xhtml %}

#### Intellectual property

{% include ip-statements.xhtml %}
