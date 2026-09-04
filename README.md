# Healthy Route Implementation Guide

FHIR R5 profiles for the AstraZeneca Healthy Heart Africa validation study of a
machine-learning algorithm predicting chronic kidney disease from digital
retinal images.

The study runs in five countries under one approved protocol per country. Each
country's approved protocol takes precedence over this guide for that country.

## Scope

This release defines the participant, consent, document, and site and staff
profiles. Study participation, measurement, imaging metadata, referral, export
and audit are in preparation.

| Artefact | Kind | Purpose |
| --- | --- | --- |
| `HRPatient` | Patient | A participant as held within a site tenant |
| `HRExportPatient` | Patient | A participant in the form transferred out of a site tenant |
| `HRConsent` | Consent | That a participant granted or refused one permission |
| `HRDocumentReference` | DocumentReference | Any document the study holds |
| `HRConsentEvidence` | DocumentReference | The photographed page a participant signed |
| `HRConsentPermissionCS` | CodeSystem | The three permissions a participant is asked to grant |
| `HROrganization` | Organization | A hospital running the study, or another party to it |
| `HRLocation` | Location | A clinic within a site, where participants are approached |
| `HRPractitioner` | Practitioner | A member of the study team |
| `HRTenant` | Extension | Identifies the owning site tenant |
| `HRAgeYears` | Extension | Age in completed years, substituting for `birthDate` on export |

Narrative documentation for each of these is under `input/pagecontent/` and is
rendered as the Resources menu of the built guide.

## Design rules

These govern what goes into a change and what waits for one.

1. **One increment, one pull request, one signed commit.** `main` requires
   linear history, signed commits and both status checks.
2. **Nothing references what does not exist, and nothing references a base
   resource this guide profiles.** SUSHI fails on an unresolved profile
   reference; `scripts/check-references.js` fails on a reference that resolves
   to a base resource for which a profile exists. Dependency order is therefore
   the build order.
3. **The export counterpart ships with its profile**, never as a later
   de-identification change. Deferring it risks discovering that something
   already modelled cannot be de-identified.
4. **Examples ship with the profile.** An example is the cheapest proof that a
   profile can be populated by the workflow it claims to describe.
5. **Country variance is instance data, never a profile.** The participating
   countries differ in thresholds and eligibility, not in structure.
6. **The protocol outranks any other source.** Where product intent and an
   approved protocol disagree, the protocol is correct.

## Building

Requires Node 20 or later and Java 17 or later.

```
npm ci
npm run sushi      # compile FSH to fsh-generated/
npm run build      # SUSHI followed by the HL7 IG Publisher
npm run qa         # fail on publisher errors, or on a reference to a
                   # base resource this guide profiles
```

`npm run build` downloads a pinned IG Publisher on first use and writes the
rendered guide to `output/`.

## Repository layout

```
input/fsh/aliases.fsh          aliases for external terminologies
input/fsh/extensions/          extensions required by the profiles
input/fsh/profiles/            profile definitions
input/fsh/terminology/         locally defined code systems and value sets
input/pagecontent/             narrative pages, one per resource area
scripts/                       publisher download, build, and the gates
```

## Canonical URL

```
https://fhir.savannahghi.org/ig/healthy-route
```

The canonical URL and the package identifier are set in `sushi-config.yaml` and
appear in every generated resource. They are not versioned and are not intended
to change. See `docs/PUBLISHING.md`.

## Continuous integration

Two workflows run on every pull request. SUSHI compiles the FSH source and fails
on any error. The IG Publisher then builds the full guide and the QA gate fails
the job if the publisher reports errors. The rendered guide is retained as a
build artefact.

## Versioning

Semantic versioning. The guide remains at `status: draft` until the profiles are
agreed with the sponsors and the collaborator.

## Licence

MIT. See `LICENSE`. The licence covers the artefacts in this repository and does
not extend to the study protocols or to any participant data.
