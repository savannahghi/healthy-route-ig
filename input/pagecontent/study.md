The protocol as a resource, and one participant's enrolment onto it.

### This is where the countries differ

It is the only place they differ in what the guide models today, and that is
deliberate. It is not yet established for what it does not model — see
[the limit of the claim](#the-limit-of-the-claim) below.

The participating countries run separate protocols with separate ethics
approvals, separate sponsors, separate site lists and different case and control
targets. None of that is a difference of *structure*. A country-specific profile
would force every downstream consumer to branch on country, and could not be
undone once anything depended on it.

So [HRResearchStudy](StructureDefinition-hr-research-study.html) is one profile,
and each country is one instance of it. `region` carries the country, `site`
carries that country's sites, `recruitment.targetNumber` carries its target, and
`version` carries the protocol version those numbers came from.

### The limit of the claim

The protocols diverge substantially in the material still in preparation. One
collects anthropometry, lifestyle history and laboratory investigations the other
does not. The two specify different blood pressure procedures: one times three
readings around the retinal imaging, the other takes a triplicate after a rest
period and uses the mean of the last two.

Whether that is instance data or a structural difference is a question for the
measurement profiles. It is stated here rather than discovered later, because the
architecture rests on the answer being the former.

### The sponsor is not the party funding it

Both protocols are **investigator-sponsored**. The sponsor is a local clinician
or a university department. The pharmaceutical collaborator supplies the
dipsticks and the retinal cameras, funds the statistical analysis, and receives
the exported data — but does not hold sponsor obligations under good clinical
practice.

Recording a single "sponsor" would misstate who carries those obligations, and
which party a monitor or an inspector should be addressing.

`associatedParty` therefore requires an explicit role on every party:

| Role | Held by |
| --- | --- |
| `sponsor-investigator` | the local clinician or institution sponsoring the protocol |
| `funding-source`, `collaborator` | the pharmaceutical partner |
| `irb` | the approving research ethics committee |

Where a party is a named individual rather than an institution,
`associatedParty.name` may carry the name without a `party` reference, so that a
person outside the study team does not need a `Practitioner` resource created for
them.

### Protocol version, not just protocol

`version` is required at `1..1`.

Protocols are amended during conduct, and an amendment can change eligibility,
procedures or endpoints. Which version was in force when a participant was
enrolled determines which rules their record should be judged against. That is
not recoverable from an enrolment date once the amendment history is gone, and it
is the first thing asked when a deviation is queried.

The same reasoning applies to the consent form version on
[HRConsent](StructureDefinition-hr-consent.html). They are separate versions of
separate documents and both have to be recorded.

### Status means two different things

`ResearchStudy.status` is bound in the base resource to *publication status* —
`draft`, `active`, `retired`, `unknown`. That describes the maturity of the
resource, not the state of the study.

Whether recruitment is open, closed or suspended is `progressStatus`. The two are
easy to conflate and mean entirely different things to a reader deciding whether
a site can still enrol.

### Enrolment requires consent

[HRResearchSubject](StructureDefinition-hr-research-subject.html) requires
`consent` at `1..*`, where the base resource makes it optional.

Enrolment without a recorded consent is precisely the finding a monitor is
looking for. A reference that may legitimately be absent cannot distinguish a
participant who was never consented from one whose consent was recorded somewhere
this resource does not point at.

There is one reference per permission, because permissions are recorded as
separate resources. A participant who joined the study but refused image
retention has two references here — one permitting, one denying.

### Screen failure is data, not absence

Both protocols define screen failures as participants who consent and are then
not entered into the study. That is an outcome with a count attached to it, and
it is reported.

`progress.subjectState` carries it: `screening`, `eligible`, `ineligible`,
`on-study`, `off-study`, `withdrawn`. Recording the state and the date it was
reached is what distinguishes a screen failure from a withdrawal, and both from an
enrolment still in progress. None of those three is an empty record.

### Cases and controls, not arms

`actualComparisonGroup` is used; `assignedComparisonGroup` is not.

These are observational studies with a case group and a control group defined by
previously documented kidney function. A participant's group is a fact about
them, established before they were approached — not an allocation made by the
study. Recording it as an assignment would misdescribe the design and invite an
analysis the design does not support.

### On maturity

Both resources are **FMM 0**, the lowest maturity in FHIR. This is known and
accepted rather than overlooked.

There is no alternative resource for enrolment onto a protocol. Expressing it as
a bare `Encounter` would lose the link between a participant, the protocol version
they were enrolled under, and the consent that permitted it — which is the entire
content of the resource. The risk of an FMM 0 resource changing is smaller than
the cost of not recording the relationship at all.
