The forms a site fills in during the visit, the keys their questions use, and
what each answer becomes on the store.

### One Questionnaire per form, one map per Questionnaire

The site records the visit on seven forms: the eligibility checklist, the
interview (history), the medicines, diet and activity, the anthropometry and
blood pressure readings (vitals), the laboratory results and the imaging. Each
is a Questionnaire in this guide (listed on the [artifacts page](artifacts.html)),
carrying the guide's version like everything else in a release, and each names
the StructureMap that turns a response to it
into the resources this guide profiles. A study amendment names the release it
was approved with, so forms, maps and terminology move together. The study service serves the forms to
the screen, stores the response, asks its FHIR store to run the map, and
commits what comes back in one transaction.

### Keys are codes

Every leaf item's `linkId` is the code its answer becomes: a LOINC code where
LOINC has one with exactly the question's meaning (`8302-2` for height,
`72166-2` for smoking status), and a code from the
[Healthy Route measurement](CodeSystem-hr-measurement.html) code system
otherwise (`history-dm`, `hip-circumference`). The maps find answers by these
keys and nothing else, so the map from question to resource is the identity
and nobody maintains a second table.

Inside a numbered or repeating group the key is the group's key, a dot, then
the code: the three blood pressure readings are `bp-reading-1.8480-6`,
`bp-reading-2.8480-6` and `bp-reading-3.8480-6`, and a medicine is
`medicine.code`, `medicine.route` and so on. A result whose unit the
laboratory chooses has a sibling item for the unit, `2160-0.unit`, and the map
picks the LOINC code from it: a creatinine reported in `umol/L` becomes
`14682-9`, one in `mg/dL` becomes `2160-0`.

### What a map never does

A map reads the response and nothing else, so everything a resource needs
beyond the answers is on the response before the map runs: the tags naming
the study, site, participant and visit, the tenant extension, the subject,
the encounter, and the author. The maps copy them onto every resource.

A map never computes. Body mass index, the waist-to-hip ratio, the mean blood
pressure and whether the readings fit the protocol's sequence, the calculated
eGFR, the flags and the weekly activity are the rule set's, written as
measurements that name what they were derived from. A map writes only what
was typed.

### Ids are derived, so a re-save replaces

Every resource a map writes takes the response's logical id followed by the
item's key, and the Bundle asks for it to be `PUT`. Inside the FHIR store a
stored response's id reads `QuestionnaireResponse/<id>/_history/<n>`, so the
maps strip it to the logical id first. Saving the same response again
produces the same ids, so the store replaces what the first save wrote rather
than duplicating it. The one exception is a medicine the catalogue does not
list, which has no code to derive an id from and takes a fresh one; the
service clears what the previous save of that response wrote before it
commits, by the response's tag.

### What each form becomes

| Form | Becomes |
|---|---|
| Eligibility | An Observation per criterion; the documented eGFR dated by the day it was documented; the dipstick under `20454-5`. The outcome and the cohort are the rule set's. |
| History | An Observation per answer, category survey; alcohol and smoking also social history. A Yes to diabetes, hypertension or CKD is also an [HRCondition](StructureDefinition-hr-condition.html), unconfirmed, with the answer as its evidence. |
| Medications | No current medication is one Observation. Each medicine is an [HRMedicationStatement](StructureDefinition-hr-medication-statement.html) against the catalogue code, with route and frequency on the study's scales; strength and form as notes. |
| Diet and activity | An Observation per answer, category survey. |
| Vitals | Height, weight, waist and hip as quantities. Three [HRBloodPressure](StructureDefinition-hr-blood-pressure.html) readings, each timed by its own item, numbered, with the monitor and, on reading two, the position as extensions. The time of retinal capture as its own Observation. |
| Laboratory | Two [HRSpecimen](StructureDefinition-hr-specimen.html) resources dated by the sample item; an Observation per result in the reported unit, with the LOINC code chosen by the unit; an [HRDiagnosticReport](StructureDefinition-hr-diagnostic-report.html) gathering them. |
| Imaging | One [HRImagingStudy](StructureDefinition-hr-imaging-study.html) for the pack, a series per eye answered Yes, the reason as a note; the four answers as Observations, category imaging. |

### The maps are tested, not trusted

Each form has an example response under the guide's examples and, in the
repository's `tests/expected`, the Bundle its map must produce. Continuous
integration replays every example through the validator's R5 mapping engine
and fails when a Bundle differs. Change a map, regenerate the Bundle, read the
diff, commit both.

That replay is not enough on its own. The FHIR store runs the same maps on
HAPI's typed model, where a stored response's id carries its type and version,
a resource id only accepts an `id` value, and `cc()` looks up a code system the
store may not hold. None of that shows offline. So the maps strip the response
id to its logical part, cast every id they build, and spell out each
CodeableConcept, and `tests/run-on-hapi.py` runs every form through a real HAPI
R5 server carrying the SIL `$extract` provider: it loads the built package,
expands every value set, extracts, commits, saves again to prove the ids are
reused, and validates every committed resource against its profile. Run it
against the hapi-fhir-interceptors local stack, or a store kept for testing,
before a release.
