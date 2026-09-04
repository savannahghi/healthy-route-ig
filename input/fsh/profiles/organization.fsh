// Healthy Route — Sites and people
//
// HROrganization  A hospital running the study, or a party to it.
// HRLocation      A clinic within a hospital, where participants are approached.
// HRPractitioner  A member of the study team.
//
// None of the three carries the tenant extension, and the omission is
// deliberate. The extension records which site partition a record belongs to;
// these resources describe the partitions rather than sitting inside one. A
// site's tenant is the identity of its HROrganization, a location's is reached
// through managingOrganization, and a practitioner's through the site that
// registered them. Placing the extension here as well would state the same fact
// twice and allow the two statements to disagree.

Profile: HROrganization
Parent: Organization
Id: hr-organization
Title: "Healthy Route Organization"
Description: "A hospital running the study, or another party to it."
* ^status = #draft
* ^experimental = false
* ^purpose = "Names the parties. A study site is the custodian of the paper records, the holder of the data partition, and the party a participant's permission is granted to; the sponsor is none of those and is a different organisation entirely. Consent, documents and the study itself all reference an organisation, and until they can reference a profiled one they reference whatever a server happens to hold."

* identifier 1..* MS
* identifier ^requirements = "A study site is a real facility with an existing identifier in a national registry, and monitoring correspondence names it by that identifier rather than by the name it is called locally. An organisation known only by a name recorded free-text cannot be matched to the facility named on an approval letter."

* active 1..1 MS
* active ^comment = "Required rather than optional. A site that has closed to recruitment still owns its records, so it is deactivated rather than deleted, and a consumer that cannot distinguish the two will offer a closed site as somewhere to enrol."

* name 1..1 MS

* type MS
* type ^short = "What kind of party this is"
* type ^comment = "Distinguishes a study site from the sponsor and from other parties. The role a party plays in a particular study is recorded on that study rather than here, because an organisation may be a site for one study and nothing at all to another."

* partOf MS
* partOf only Reference(HROrganization)
* partOf ^comment = "A recruiting clinic sits within a hospital, and the hospital is what holds the approval. Where a site is a department of a larger institution, that institution is named here."

* contact MS


Profile: HRLocation
Parent: Location
Id: hr-location
Title: "Healthy Route Location"
Description: "A clinic within a study site, where participants are approached."
* ^status = #draft
* ^experimental = false
* ^purpose = "Records where a participant was approached, which the protocols make a property of the recruitment rather than an incidental detail. Both protocols recruit from the general out-patient, hypertension, diabetes and renal clinics of their sites, and a cohort drawn mostly from a renal clinic is not the same cohort as one drawn mostly from general out-patients even when both come from the same hospital."

* status 1..1 MS
* name 1..1 MS

* mode 1..1 MS
* mode = #instance
* mode ^comment = "Fixed. Every location in this guide is a specific clinic that exists, never a class of clinic described in the abstract, and the distinction matters because a reference to a kind of place cannot be the place a participant was actually seen."

* type MS
* type ^short = "Kind of clinic"
* type ^requirements = "The clinic a participant was recruited from is a source of spectrum variation that has to be available at analysis. Where recruitment is unbalanced across clinic types, the prevalence of disease in the cohort differs from the prevalence in the population the algorithm is intended for, and the resulting predictive values move with it."

* managingOrganization 1..1 MS
* managingOrganization only Reference(HROrganization)
* managingOrganization ^requirements = "Required rather than optional, because this reference is how a location resolves to a site tenant. A location with no managing organisation belongs to no partition."

* partOf MS
* partOf only Reference(HRLocation)

* address MS
* address ^comment = "The address of a facility, not of a participant. It is not subject to the export constraints that apply to participant addresses, because it identifies an institution rather than a person."


Profile: HRPractitioner
Parent: Practitioner
Id: hr-practitioner
Title: "Healthy Route Practitioner"
Description: "A member of the study team."
* ^status = #draft
* ^experimental = false
* ^purpose = "Identifies the people who take consent, capture images and review results, to the standard good clinical practice requires of a delegation log. Study staff are data subjects in their own right, so this profile records what is needed to establish that a named, authorised person performed an act, and prohibits the rest."

* identifier 1..* MS
* identifier ^short = "Professional registration or staff number"
* identifier ^requirements = "A name alone does not establish that the person who took consent was authorised to do so. A registration number is what connects an entry in this record to an entry on the delegation log and to a professional register that can be checked independently."

* active 1..1 MS
* active ^comment = "Staff turnover during a study is ordinary. A practitioner who leaves is deactivated rather than deleted, because acts they performed while active remain attributed to them and a dangling reference is not an improvement on a record of someone who has left."

* name 1..1 MS
* name.family 1..1 MS

* qualification MS
* qualification ^short = "Training and credentials"
* qualification ^requirements = "Both protocols require study team members to be trained in the procedures they perform, and specify that retinal image capture is done by a member of the team who has undergone training. Whether a given person was trained for a given procedure is the question a monitor asks, and it is unanswerable from a name."

* telecom MS

* birthDate 0..0
* birthDate ^comment = "Not required to establish that an authorised person performed an act. Study staff are data subjects, and the profile records what the delegation log needs rather than what the resource permits."

* address 0..0
* photo 0..0
* deceased[x] 0..0
