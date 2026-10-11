// Healthy Route — Samples
//
// Blood and urine are drawn for the laboratory on a day that may fall up to 28
// days after consent. The specimen records when, and the results reference it,
// so that the sampling day is recorded once and read from the same place by the
// laboratory report and by the check on the 28-day window.

Profile: HRSpecimen
Parent: Specimen
Id: hr-specimen
Title: "Healthy Route Sample"
Description: "A blood or urine sample drawn from a participant for the study's laboratory investigations."
* ^status = #draft
* ^experimental = false
* ^purpose = "Carries the collection time the laboratory results refer to. The protocols give the samples their own window after consent, and a result cannot be checked against that window unless the collection time is recorded apart from the result's own time of issue."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status MS

* type 1..1 MS
* type ^short = "Blood or urine"

* subject 1..1 MS
* subject only Reference(HRPatient)

* collection 1..1 MS
* collection.collected[x] 1..1 MS
* collection.collected[x] ^short = "When the sample was drawn"
* collection.collector MS
* collection.collector only Reference(HRPractitioner)

* receivedTime MS
* note MS
