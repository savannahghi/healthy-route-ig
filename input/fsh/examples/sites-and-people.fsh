// Examples for the site and staff profiles.
//
// The data is invented. Naming the study's real sites would place the site list
// of an unpublished protocol in a public repository, and an example exists to
// show the shape of a resource rather than to record a fact.

Instance: ExampleStudySite
InstanceOf: HROrganization
Usage: #example
Title: "Example study site"
Description: "A teaching hospital acting as a study site, holding its own data partition and the paper records of its participants."
* identifier[0].system = "https://example.org/sid/national-facility-register"
* identifier[0].value = "HF-0001"
* active = true
* name = "Example Teaching Hospital"
* type = $organization-type#prov "Healthcare Provider"

Instance: ExampleRenalClinic
InstanceOf: HRLocation
Usage: #example
Title: "Example renal clinic"
Description: "The nephrology clinic of the example site. Participants approached here are drawn from a population with a higher prevalence of chronic kidney disease than the site as a whole."
* status = #active
* name = "Renal Clinic"
* mode = #instance
* type = $v3-RoleCode#NEPH "Nephrology clinic"
* managingOrganization = Reference(ExampleStudySite)

Instance: ExampleGeneralOutpatientClinic
InstanceOf: HRLocation
Usage: #example
Title: "Example general out-patient clinic"
Description: "The general out-patient clinic of the example site, recorded separately from the renal clinic because the two recruit from populations with different disease prevalence."
* status = #active
* name = "General Out-patient Clinic"
* mode = #instance
* type = $v3-RoleCode#GIM "General internal medicine clinic"
* managingOrganization = Reference(ExampleStudySite)

Instance: ExampleStudyNurse
InstanceOf: HRPractitioner
Usage: #example
Title: "Example study team member"
Description: "A nurse on the delegation log, trained to take consent and to capture retinal images."
* identifier[0].system = "https://example.org/sid/nursing-council-register"
* identifier[0].value = "NC-44921"
* active = true
* name[0].family = "Achieng"
* name[0].given[0] = "Wanjiru"
* qualification[0].code.text = "Registered nurse"
* qualification[0].period.start = "2019-03-01"
