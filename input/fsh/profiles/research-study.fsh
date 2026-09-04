// Healthy Route — Study and participation
//
// HRResearchStudy    A country's approved protocol, as a resource.
// HRResearchSubject  One participant's enrolment onto one of them.
//
// This is where the countries differ, and it is the only place they differ.
// The participating countries run separate protocols with separate approvals,
// separate sponsors, separate site lists and different case and control
// targets. None of that is a difference of structure, and none of it belongs in
// a profile. A country-specific profile would make every downstream consumer
// branch on country, and could not be undone once written.
//
// Both resources are FMM 0. The maturity is known and accepted: there is no
// alternative resource for enrolment onto a protocol, and expressing it as a
// bare Encounter would lose the link between a participant, the protocol they
// were enrolled onto and the consent that permitted it.

Profile: HRResearchStudy
Parent: ResearchStudy
Id: hr-research-study
Title: "Healthy Route Study"
Description: "A country's approved protocol, and the parties, sites and targets it names."
* ^status = #draft
* ^experimental = false
* ^purpose = "Carries the variation between participating countries as instance data. A consumer reading this resource can establish which protocol version a participant was enrolled under, who sponsored it, which sites recruited for it and what it set out to measure, without holding a copy of the protocol document."

* identifier 1..* MS
* identifier ^short = "Protocol number"

* title 1..1 MS

* version 1..1 MS
* version ^short = "Protocol version"
* version ^requirements = "Protocols are amended during conduct, and an amendment can change eligibility, procedures or endpoints. Which version was in force when a participant was enrolled determines which rules their record should be judged against, and it is not recoverable from an enrolment date alone once the amendment history is lost."

* status 1..1 MS
* status ^comment = "Bound in the base resource to publication status, which describes the maturity of the resource rather than the state of the study. Whether recruitment is open, closed or suspended is carried in progressStatus."

* primaryPurposeType MS
* studyDesign MS
* studyDesign ^comment = "Non-interventional and cross-sectional for every country in this study. Recorded rather than assumed, because the analysis a consumer may legitimately perform on the data depends on it."

* region 1..* MS
* region ^short = "Country the protocol was approved for"
* region ^requirements = "One protocol per country, each with its own ethics approval. This is the field that distinguishes them, and it is deliberately the only structural difference between countries in this guide."

* period MS
* period ^short = "Recruitment period"

* site 1..* MS
* site only Reference(HROrganization or HRLocation)
* site ^requirements = "Site count differs between countries and site identity determines which participants a monitor's findings apply to. A study whose sites are known only from the protocol document cannot answer which of them a given participant came from."

* associatedParty 1..* MS
* associatedParty.role 1..1 MS
* associatedParty.party MS
* associatedParty.party only Reference(HRPractitioner or HROrganization)
* associatedParty ^requirements = "The sponsor of these protocols is not the party funding them. Both are investigator-sponsored: the sponsor is a local clinician or university, while the pharmaceutical collaborator supplies equipment, funds the analysis and receives the exported data. Recording one party as the sponsor would misstate who holds sponsor obligations under good clinical practice."
* associatedParty ^comment = "sponsor-investigator for the local sponsor, funding-source and collaborator for the pharmaceutical partner, irb for the approving ethics committee. Where a party is a named individual rather than an institution, name may be used without a party reference so that a person outside the study team need not be given a Practitioner resource."

* progressStatus MS
* progressStatus ^short = "Whether recruitment is open"

* recruitment 1..1 MS
* recruitment.targetNumber 1..1 MS
* recruitment.targetNumber ^requirements = "Recruitment targets differ between countries, as does the split between cases and controls. The target is what an interim enrolment count is judged against, and a study reporting progress without one is reporting a number with no denominator."
* recruitment.actualNumber MS

* objective MS
* outcomeMeasure MS
* outcomeMeasure ^comment = "The endpoints, primary and secondary. Held here so that a consumer can establish what the study set out to measure without inferring it from the observations that happen to have been collected."

* protocol MS
* protocol ^comment = "The procedure as a computable plan, where one exists. No PlanDefinition is profiled in this guide yet, so this currently references the base resource."

* description MS


Profile: HRResearchSubject
Parent: ResearchSubject
Id: hr-research-subject
Title: "Healthy Route Study Participation"
Description: "One participant's enrolment onto one country's protocol, and the consent that permitted it."
* ^status = #draft
* ^experimental = false
* ^purpose = "Joins a participant to a protocol and to the permission that allowed them to be enrolled. It is the resource that answers whether a given person was in the study at a given time, which is distinct from whether the study holds data about them."

* identifier MS
* identifier ^short = "Enrolment identifier, where the site issues one separately"
* identifier ^comment = "Distinct from the participant identifier on HRPatient, which is retained across rescreening. A participant screened twice has one participant identifier and, if the site issues enrolment identifiers, two of those."

* status 1..1 MS

* study 1..1 MS
* study only Reference(HRResearchStudy)

* subject 1..1 MS
* subject only Reference(HRPatient)
* subject ^comment = "Constrained to Patient. The base resource also admits Group, Specimen, Device, Medication, Substance and BiologicallyDerivedProduct, none of which is enrolled onto a protocol in this study."

* consent 1..* MS
* consent only Reference(HRConsent)
* consent ^requirements = "Required, where the base resource makes it optional. Enrolment without a recorded consent is the finding a monitor is looking for, and a reference that may legitimately be absent cannot distinguish a participant who was never consented from one whose consent was recorded elsewhere."
* consent ^comment = "One reference per permission granted or refused, because permissions are recorded as separate resources. A participant who consented to the study but refused image retention has two references here, one permitting and one denying."

* period MS
* period ^short = "Period of participation"

* progress MS
* progress.subjectState MS
* progress ^short = "Screening, enrolment and withdrawal"
* progress ^requirements = "Screen failure is a defined outcome in both protocols, not an absence of data: a participant who consents and is then found ineligible has been screened, and the count of them is reported. Recording the state and the date it was reached is what allows a screen failure to be distinguished from a withdrawal and from an enrolment still in progress."

* actualComparisonGroup MS
* actualComparisonGroup ^short = "Case or control"
* actualComparisonGroup ^comment = "These are observational studies with a case and a control group defined by previously documented kidney function, not trials with assigned arms. The group a participant falls into is a fact about them rather than an allocation, so actualComparisonGroup is used and assignedComparisonGroup is not."
