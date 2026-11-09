The forms a site fills in during the visit, the keys their questions use, and
what each answer becomes on the store.

### One Questionnaire per form, one map per Questionnaire

A Uganda site records the visit on six forms: the eligibility checklist, the
interview (history), the medicines, the blood pressure readings (vitals), the
laboratory results and the imaging. A Ghana site uses the same six and a
socio-demographics form, following the data collection tool in Appendix B of
the Ghana protocol, version 6.0. Each
is a Questionnaire in this guide (listed on the [artifacts page](artifacts.html)),
carrying the guide's version like everything else in a release, and each names
the StructureMap that turns a response to it
into the resources this guide profiles. A study amendment names the release it
was approved with, so forms, maps and terminology move together. The study service serves the forms to
the screen, stores the response, asks its FHIR store to run the map, and
commits what comes back in one transaction.

Each form is tagged with the identifier of the study it belongs to, `HR-UG`
for Uganda and `HR-GH` for Ghana, and the study service lists a study's forms
by that tag. Where the two protocols ask the same question the forms use the
same key, so one map serves both countries. Since version 0.2.0 both
countries' forms follow the 6 November 2026 review of the two protocols (below).
The urine dipstick is a laboratory result: it is on the laboratory form, not
required, and decides nothing, so neither eligibility checklist asks it, and
Ghana's no longer asks about an established CKD diagnosis. CKD is worked out
from the documented eGFR on the checklist and the eGFR the laboratory form
calculates.

Ghana's other forms ask what Appendix B asks and no more. Its socio-demographics
form asks the clinic, the ethnicity and the type of domicile; the tool's Study
ID, hospital number, date of birth, sex and contact are taken when the
participant is registered, and the address is left with the participant's
details rather than the study data. Its vitals form asks the three timed
readings only. The
Ghana protocol takes the average of all three readings where Uganda's takes
readings two and three, so Ghana's mean has its own key, `bp-mean-all`. The
time of retinal capture is asked once in Ghana, on the imaging form: a question
asked on two forms can be answered two ways, and the study service refuses to
sign a visit whose forms disagree.

The investigator signs a visit once its forms are saved. A form the protocol
leaves to the clinician's discretion is tagged `optional` from the
[sign-off code system](CodeSystem-hr-signoff.html), and the study service signs
a visit without it; when it was saved, it is signed with the rest. In Uganda
the medications form is optional. In Ghana the socio-demographics form is
optional, so a visit is not held for it; the medications form is not, because
the Ghana protocol counts treatment towards hypertension.

### Keys are codes

Every leaf item's `linkId` is the code its answer becomes: a LOINC code where
LOINC has one with exactly the question's meaning (`20454-5` for the urine
dipstick, `72166-2` for smoking status), and a code from the
[Healthy Route measurement](CodeSystem-hr-measurement.html) code system
otherwise (`history-dm`, `retinal-capture-time`). The maps find answers by these
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

A map never computes. A value worked out from other answers is either a
calculated item on the form, described below, or the rule set's. A map writes
the answers it was written for and nothing else, so a calculated item on a
response does not become a resource until a map is written for it.

### Values the form calculates

A value that needs only answers on the same form is an item on that form,
read-only, carrying its formula as an SDC calculated expression in FHIRPath.
The screen recalculates it whenever an answer it reads changes, so the person
entering the answers sees the result as they go and can never type it, and the
formula ships with the form, so a response names the version of the formula
that gave its value.

| Form | Calculated item | Formula |
|---|---|---|
| Vitals | Mean blood pressure, `bp-mean.8480-6` and `bp-mean.8462-4`, mm[Hg] | the mean of readings two and three, which the Uganda protocol takes as the true blood pressure, whole mm[Hg] |
| Vitals, Ghana | Mean blood pressure, `bp-mean-all.8480-6` and `bp-mean-all.8462-4`, mm[Hg] | the mean of all three readings, as the Ghana protocol records it, whole mm[Hg] |
| Laboratory | `creatinine-converted`, mg/dL | the creatinine as the equation uses it: as reported in mg/dL, divided by 88.4 from umol/L |
| Laboratory | eGFR, `98979-8`, mL/min/1.73m2 | CKD-EPI 2021 without the race coefficient, one decimal |

The eGFR needs the participant's age and sex, which no question on the form
asks. The form declares the participant and the visit as its launch context,
and two read-only items take them when the form opens: `egfr-sex` from the
participant's administrative gender, and `egfr-age` as the completed years on
the day the visit started, or on the day the form is opened when the screen
supplies no visit. The eGFR is calculated from those two items, so the age and
sex it used are on the response next to it. A sex other than female or male, a
creatinine in any other unit, or a missing input gives no eGFR rather than a
wrong one.

Each calculated item becomes an Observation when the response is extracted,
under the item's code like any answer, with `derivedFrom` naming the
Observations it was calculated from, so the calculation can be checked rather
than trusted. The mean blood pressure is a blood pressure Observation like the
readings, with no reading number, timed at reading three, and the readings it
averages in `derivedFrom`. The eGFR names the
converted creatinine and the age and sex it used, which are Observations of
their own. The derived laboratory values are the study's calculation rather
than the laboratory's, so the DiagnosticReport lists only what the laboratory
returned.

The values a reader looks at also carry a second category, `derived` from
[the study's observation categories](CodeSystem-hr-observation-category.html),
beside their FHIR one: the mean blood pressure and the eGFR. FHIR's categories have no code for a value that was worked out
rather than measured or asked, so this is how a reader asks for the derived
values alone, with one search on `category`. The converted creatinine and the
age and sex the eGFR uses are steps towards the eGFR, not results, and do not
carry it.

A value that needs answers from more than one form is not on any form. The
hypertension flag reads the readings and the treatment, the diabetes flag the
HbA1c and the history, and the CKD flag the laboratory eGFR; the rule set
computes them across the visit. The HbA1c needs no conversion on the Uganda
laboratory form, which records it in percent only.

The expressions read answers the way the Advantage formula builder writes them,
`%resource.repeat(item).where(linkId='...').answer.valueDecimal`, so a form can
be opened and edited there. In the repository, `tests/run-calculations.js` runs
every formula with the FHIRPath engine and version the Advantage renderer uses,
the way that renderer runs them: each example response must hold what its
answers calculate to, the eGFR must reproduce the platform scope's CKD-EPI 2021
test vectors, and a missing or unusable input must give no value.

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
| Eligibility | An Observation per criterion; the documented eGFR dated by the day it was documented. The outcome and the cohort are the rule set's. |
| Socio-demographics | An Observation per answer, category survey. An ethnicity answered other keeps the group the participant named as the value's text. |
| History | An Observation per answer, category survey; alcohol and smoking also social history. A Yes to diabetes, hypertension or CKD is also an [HRCondition](StructureDefinition-hr-condition.html), unconfirmed, with the answer as its evidence. |
| Medications | No current medication is one Observation. Each medicine is an [HRMedicationStatement](StructureDefinition-hr-medication-statement.html) against the catalogue code, with route and frequency on the study's scales; strength and form as notes. |
| Diet and activity (retired) | Served to no study since 0.2.0. Its map still turns a response recorded before then into an Observation per typed answer, category survey, and one per calculated item, also derived. |
| Vitals | Three [HRBloodPressure](StructureDefinition-hr-blood-pressure.html) readings, each timed by its own item, numbered, with the monitor and, on reading two, the position as extensions. The time of retinal capture as its own Observation. The mean blood pressure, also derived. Ghana's form gives the three readings and their mean only. |
| Laboratory | Two [HRSpecimen](StructureDefinition-hr-specimen.html) resources dated by the sample item; an Observation per result in the reported unit, with the LOINC code chosen by the unit, and the dipstick under `20454-5` on the urine specimen; an [HRDiagnosticReport](StructureDefinition-hr-diagnostic-report.html) gathering them. The converted creatinine, the age and sex the eGFR uses, and the eGFR, which alone is also derived. |
| Imaging | One [HRImagingStudy](StructureDefinition-hr-imaging-study.html) for the pack, started at the time of retinal capture, a series per eye answered Yes, the reason as a note; the answers as Observations, category imaging. Ghana does not ask about dilation. |

### What the 6 November 2026 review removed

The review of the Uganda and Ghana protocols applied the Uganda protocol
v3.1's list of what the study does not collect to both countries, and removed a
few questions neither protocol lists. Version 0.2.0 of this guide carries it.

- Uganda history no longer asks HIV history, heart disease or traditional
  medicine use, so it asks what Ghana's does. Alcohol and smoking are asked in
  both countries but not required.
- Uganda vitals no longer ask height, weight, waist or hip, so body mass index
  and the waist-to-hip ratio are no longer calculated.
- Uganda laboratory results no longer ask fasting blood sugar, an HIV test or
  whether a full blood count was taken.
- The diet and activity form, covering diet, physical activity and work, is
  retired. It stays in the guide tagged for no study, because loading the guide
  replaces what the store holds but never deletes, and responses recorded
  against it still resolve.
- The urine dipstick moves from the eligibility checklists to the laboratory
  forms, and Ghana's established CKD question goes.

The codes those questions used stay in their code systems, marked `retired`,
so answers recorded with them keep their meaning. The guide's version moved
from 0.1.0 to 0.2.0 because a saved response names its form's version: one
recorded against the 0.1.0 forms still says which questions it answered, and the
study service can tell it from a response to the forms in force now.

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
