# Healthy Route Implementation Guide

FHIR R5 profiles for the AstraZeneca Healthy Heart Africa validation study of a
machine-learning algorithm predicting chronic kidney disease from digital
retinal images.

The study runs in five countries under one approved protocol per country. Each
country's approved protocol takes precedence over this guide for that country.

## Scope

This release defines the Patient profiles. Profiles for consent, participation,
measurement, imaging metadata, referral and export are in preparation.

| Artefact | Purpose |
| --- | --- |
| `HRPatient` | A participant as held within a site tenant |
| `HRExportPatient` | A participant as transferred to the sponsor |
| `HRTenant` | Identifies the owning site tenant |
| `HRAgeYears` | Age in completed years, substituting for `birthDate` on export |

## Building

Requires Node 20 or later and Java 17 or later.

```
npm ci
npm run sushi      # compile FSH to fsh-generated/
npm run build      # SUSHI followed by the HL7 IG Publisher
npm run qa         # fail if the publisher reports errors
```

`npm run build` downloads a pinned IG Publisher on first use and writes the
rendered guide to `output/`.

## Repository layout

```
input/fsh/aliases.fsh          aliases for external terminologies
input/fsh/extensions/          extensions required by the profiles
input/fsh/profiles/            profile definitions
input/pagecontent/             narrative pages
scripts/                       publisher download, build, and QA gate
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
agreed with the sponsor.

## Licence

MIT. See `LICENSE`. The licence covers the artefacts in this repository and does
not extend to the study protocols or to any participant data.
