The screening visit, and everything measured during it.

### One visit, one encounter

The protocols describe a single cross-sectional contact. A participant attending
a routine clinic is approached, consented, interviewed, has three blood pressure
readings taken, gives a urine sample for dipstick, gives blood and urine for the
laboratory, and has both eyes photographed. There is no follow-up visit and no
admission.

[HREncounter](StructureDefinition-hr-encounter.html) is the spine everything else
hangs from. `Observation`, `ServiceRequest`, `DiagnosticReport` and
`ImagingStudy` all require one, because a result that cannot be placed at a visit
cannot be placed against the consent that was in force, or against the clinic the
participant was recruited from.

The clinic matters. Both protocols recruit from general out-patient, hypertension,
diabetes and renal clinics, and a cohort drawn mostly from a renal clinic has a
different disease prevalence from one drawn mostly from general out-patients.
Predictive values move with prevalence, so `Encounter.location` is where an
analysis finds out which population it is actually looking at.

### A visit, and its dated parts

Both protocols let the samples and the retinal photography fall up to 28 days
after consent. So a visit is one parent encounter typed `visit`, and a child
encounter for each part that carries its own date: `samples` and `imaging`,
typed from the [visit part](CodeSystem-hr-encounter-type.html) code system and
pointing at the parent through `partOf`. The 28-day window is then a query over
the children's dates rather than a note on the visit.

### The forms, and the codes their questions take

The site fills in forms during the visit: the interview, the medicines, diet and
activity, the anthropometry and blood pressure readings, the laboratory results
and the imaging. Each answer becomes a resource. A question takes a LOINC code
where LOINC has one with exactly its meaning, and a code from the
[Healthy Route measurement](CodeSystem-hr-measurement.html) code system
otherwise. That code is both the question's `linkId` and the `Observation.code`
its answer becomes, so the map from one to the other is the identity.

The coded answers take short scales printed on the forms, each a code system of
its own: use status, the frequency scale, physical activity at work, reactive or
non-reactive, the blood pressure position and monitor, and which eye. The
laboratory reports in the site's own [units](ValueSet-hr-lab-unit-vs.html), and
the LOINC code of a result follows the unit the laboratory reported.

A Yes to diabetes, hypertension or chronic kidney disease on the interview is
also an [HRCondition](StructureDefinition-hr-condition.html), unconfirmed and
traceable to the answer. A medicine the participant reports is an
[HRMedicationStatement](StructureDefinition-hr-medication-statement.html) against
the study's medicine catalogue. The samples the results came from are an
[HRSpecimen](StructureDefinition-hr-specimen.html), which carries the collection
time the window is checked against.

### One profile for every measurement

[HRObservation](StructureDefinition-hr-observation.html) carries creatinine,
eGFR, HbA1c, the urine albumin-to-creatinine ratio, the urine dipstick, height,
weight, body mass index, and the additional investigations one country collects.

They differ in code, unit and value type. They do not differ in **shape**, and a
profile for each analyte would mean a new StructureDefinition and a new release
of this guide every time a laboratory adds a test. What distinguishes one
measurement from another is `Observation.code`, which is what a consumer filters
on.

The rule this follows: **profile where the datatype alone does not constrain the
value; do not where it does.** A creatinine is a `Quantity` with a UCUM unit and
the datatype has already done the work.

#### The one exception, and we did not write it

Blood pressure puts its two readings in `component` rather than in `value[x]`.
FHIR core already profiles that as
[`http://hl7.org/fhir/StructureDefinition/bp`](http://hl7.org/fhir/R5/bp.html),
with the components sliced, their LOINC codes fixed and their units fixed to
mmHg. [HRBloodPressure](StructureDefinition-hr-blood-pressure.html) derives from
it and adds only tenancy and the encounter requirement.

FHIR is single-inheritance, so the tenant extension is restated there rather than
inherited from `HRObservation`. Three lines of duplication is a better trade than
reimplementing a profile HL7 maintains.

### Three readings and a derived value

This is where the two protocols visibly differ, and where the guide's
architecture was tested.

One times three readings around the retinal photography — sixty minutes before,
fifteen minutes either side, sixty minutes after — and averages them. The other
takes a triplicate after five minutes of rest and uses **the mean of the last
two**, discarding the first.

Those are different procedures, not different thresholds. They are nevertheless
instance data, because of how the readings are modelled:

- each reading is its own `HRBloodPressure`, with its own `effectiveDateTime`
- the value carried to analysis is a **fourth** resource, whose `derivedFrom`
  names the readings it actually used

Three readings and their mean are four resources, not one resource with four
values. What differs between countries is which readings `derivedFrom` points at,
and that is data. The averaging rule itself belongs to the study, not to the
resource — so the profile deliberately does not encode it, and a consumer can
check the arithmetic instead of trusting it.

### The dipstick scale is defined and bound to nothing

[HRDipstickProteinVS](ValueSet-hr-dipstick-protein-vs.html) lists Negative,
Trace, +1, +2 and +3.

It is not bound to `HRObservation.value[x]`, and that is deliberate. The scale is
printed on the protocols' own data collection tool as fixed options, so values
reach the record by transcription from a form. The constraint that matters is on
the entry screen, not on a StructureDefinition. LOINC publishes an answer list for
`5804-0`, but it is not expandable on the public terminology server, so a binding
would have meant inventing a local scale and requiring it of every site.

The value set exists so that whoever builds the form has a canonical list, and so
a consumer knows what the values mean.

It matters more than its size suggests: in one protocol the dipstick gates
eligibility, and in the other it is the **comparator** the algorithm's sensitivity
and specificity are computed against.

### eGFR is calculated, and says so

An eGFR is a number produced by an equation, and the equation is not recoverable
from the number.

The example records `derivedFrom` naming the creatinine it was computed from, and
`method` naming the equation. The LOINC code is **`98979-8`**, the CKD-EPI **2021**
revision with the race coefficient removed. `62238-1` is the generic CKD-EPI code
and would understate what was done.

Where a laboratory reports eGFR directly rather than the platform deriving it,
the same profile applies and `derivedFrom` is simply absent.

### Orders and reports

[HRServiceRequest](StructureDefinition-hr-service-request.html) records that an
investigation was asked for, by whom and when. `authoredOn` is required: samples
are drawn during a routine clinical visit where the participant's ordinary care is
also happening, and a result with no request behind it cannot be told apart from
one belonging to that other episode. `intent` is fixed to `order` — nothing here
is a proposal awaiting authorisation.

[HRDiagnosticReport](StructureDefinition-hr-diagnostic-report.html) gathers the
results a laboratory issued together. The individual values are `HRObservation`
resources and stand on their own; the report ties them to one issuing laboratory
and one point in time. `issued` is kept distinct from `effective[x]`, because the
interval between a sample being drawn and a result being released is what a site
is asked about once the participant has gone home.

### Imaging: one series per eye

[HRImagingStudy](StructureDefinition-hr-imaging-study.html) is metadata. It
records which eye, when, and where the pixel data is held — it is not the images.

`series.laterality` is **required**, where the base resource leaves it optional.
It is the only thing distinguishing two otherwise identical series, and a
prediction attributed to the wrong eye is not detectable after the fact.

`series` is `1..*` rather than `2..*`. The protocols photograph both eyes, so a
conforming study ordinarily carries two — but a capture can fail on the day, and a
study recording a single usable eye is a truthful record where one asserting two
would not be.

`started` is required because one protocol times its blood pressure readings
relative to this moment. The interval is meaningless unless both carry a time.

### What is not here

`Specimen` is referenced by `Observation.specimen`,
`ServiceRequest.specimen` and `DiagnosticReport.specimen`, and is not yet
profiled — those references point at the base resource. `Device` is likewise
unprofiled, so the instrument on a blood pressure reading or a retinal camera can
be referenced but not constrained.

Eligibility is absent deliberately. Encoding it needs a contradiction in one
protocol resolved first: its screen-failure rule excludes a negative dipstick,
while its recruitment target requires a control group most of whom will have one.
