// Examples for the study and participation profiles.
//
// Two study instances of one profile, differing only in instance data. This is
// the whole argument for keeping country variance out of the profiles: the
// countries differ in region, sites, targets and sponsor, and in nothing that a
// StructureDefinition would express.
//
// Names, identifiers and site counts are invented. The real ones belong to
// unpublished protocols and this repository is public.

Instance: ExampleStudyCountryA
InstanceOf: HRResearchStudy
Usage: #example
Title: "Example study, country A"
Description: "One country's approved protocol, sponsored by a local clinician, with a pharmaceutical collaborator funding the analysis and receiving the exported data."
* identifier[0].system = "https://example.org/sid/protocol"
* identifier[0].value = "HR-A-001"
* title = "Validation of a retinal image algorithm for prediction of reduced kidney function, country A"
* version = "1.0"
* status = #active
* primaryPurposeType = $prim-purp-type#diagnostic
* studyDesign.text = "Non-interventional, cross-sectional"
* region = $iso3166#GH
* period.start = "2026-03-01"
* period.end = "2026-08-31"
* site[0] = Reference(ExampleStudySite)
* associatedParty[0].role = $party-role#sponsor-investigator "Sponsor-investigator"
* associatedParty[0].name = "Example local sponsor"
* associatedParty[1].role = $party-role#funding-source "Funding source"
* associatedParty[1].name = "Example pharmaceutical collaborator"
* associatedParty[2].role = $party-role#irb "Institutional Review Board"
* associatedParty[2].name = "Example research ethics committee"
* recruitment.targetNumber = 500
* objective[0].name = "Primary"
* objective[0].description = "Validate the performance of a machine-learning algorithm predicting reduced kidney function from digital retinal images, in the population in which it is intended to be used."

Instance: ExampleStudyCountryB
InstanceOf: HRResearchStudy
Usage: #example
Title: "Example study, country B"
Description: "A second country's protocol. Structurally identical to country A and different in every value that matters: region, sponsor, sites and the split between cases and controls."
* identifier[0].system = "https://example.org/sid/protocol"
* identifier[0].value = "HR-B-001"
* title = "Validation of a retinal image algorithm for prediction of reduced kidney function, country B"
* version = "1.0"
* status = #active
* primaryPurposeType = $prim-purp-type#diagnostic
* studyDesign.text = "Non-interventional, cross-sectional"
* region = $iso3166#UG
* period.start = "2026-04-01"
* period.end = "2026-09-30"
* site[0] = Reference(ExampleStudySite)
* associatedParty[0].role = $party-role#sponsor-investigator "Sponsor-investigator"
* associatedParty[0].name = "Example sponsoring university department"
* associatedParty[1].role = $party-role#funding-source "Funding source"
* associatedParty[1].name = "Example pharmaceutical collaborator"
* recruitment.targetNumber = 500
* objective[0].name = "Primary"
* objective[0].description = "Validate the performance of a machine-learning algorithm predicting reduced kidney function from digital retinal images, in the population in which it is intended to be used."

Instance: ExampleParticipationScreenFailure
InstanceOf: HRResearchSubject
Usage: #example
Title: "Example participation ending in screen failure"
Description: "A participant who consented and was then found ineligible. This is a recorded outcome with a count attached to it, not an absence of data, and it is distinguishable here from a withdrawal and from an enrolment still in progress."
* status = #active
* study = Reference(ExampleStudyCountryA)
* subject = Reference(ExampleParticipant)
* consent[0] = Reference(ExampleConsentParticipation)
* period.start = "2026-04-14"
* period.end = "2026-04-14"
* progress[0].subjectState = $subject-state#screening
* progress[0].startDate = "2026-04-14"
* progress[1].subjectState = $subject-state#ineligible
* progress[1].startDate = "2026-04-14"
