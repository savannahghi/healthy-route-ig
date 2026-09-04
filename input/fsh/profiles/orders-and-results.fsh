// Healthy Route — Orders, reports and imaging
//
// HRServiceRequest    A request for a laboratory investigation.
// HRDiagnosticReport  What the laboratory returned.
// HRImagingStudy      The retinal photographs.
//
// The three sit on either side of work done outside the study team. A request
// leaves the site, a report comes back, and the individual results the report
// gathers are HRObservation resources. The imaging is the exception: it is
// performed at the site on the study's own device, and its output is the
// material the algorithm under validation actually consumes.

Profile: HRServiceRequest
Parent: ServiceRequest
Id: hr-service-request
Title: "Healthy Route Investigation Request"
Description: "A request for a laboratory investigation arising from the screening visit."
* ^status = #draft
* ^experimental = false
* ^purpose = "Records that an investigation was asked for, by whom and when. A result with no request behind it cannot be distinguished from a result belonging to another episode of the participant's care, and the protocols draw study samples during a routine clinical visit where both are present."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS

* intent 1..1 MS
* intent = #order
* intent ^comment = "Fixed. Every request in this study is an order placed by the study team; none is a proposal or a plan awaiting authorisation."

* category MS

* code 1..1 MS
* code ^short = "Investigation requested"

* subject 1..1 MS
* subject only Reference(HRPatient)

* encounter 1..1 MS
* encounter only Reference(HREncounter)

* authoredOn 1..1 MS
* authoredOn ^requirements = "Ordering before consent is a protocol deviation. Establishing that requires the order to carry its own timestamp rather than inheriting one from the result that came back."

* requester 1..1 MS
* requester only Reference(HRPractitioner)
* requester ^comment = "The individual, for the same reason consent records one: an organisation cannot be on a delegation log."

* performer MS
* performer only Reference(HROrganization or HRPractitioner)
* performer ^short = "Laboratory or team member who will do it"

* specimen MS
* specimen ^comment = "References the base Specimen resource. This guide does not yet profile it."

* reason MS
* note MS


Profile: HRDiagnosticReport
Parent: DiagnosticReport
Id: hr-diagnostic-report
Title: "Healthy Route Laboratory Report"
Description: "What a laboratory returned for one participant, gathering the individual results."
* ^status = #draft
* ^experimental = false
* ^purpose = "Gathers results that were reported together and records who reported them. The individual values are HRObservation resources and are usable on their own; this resource is what ties them to a single issuing laboratory and a single point in time, which is what a query for the laboratory record has to return."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS

* code 1..1 MS
* code ^short = "Kind of report"

* subject 1..1 MS
* subject only Reference(HRPatient)

* encounter 1..1 MS
* encounter only Reference(HREncounter)

* effective[x] MS
* effective[x] ^short = "When the samples were taken"

* issued MS
* issued ^short = "When the laboratory released the report"
* issued ^comment = "Distinct from effective[x]. The interval between a sample being drawn and a result being released is what a site is asked about when a participant has already left."

* performer MS
* performer only Reference(HROrganization or HRPractitioner)

* result MS
* result only Reference(HRObservation)
* result ^requirements = "The values themselves. Constrained to this guide's profile so that a report cannot gather observations that carry no tenant and no encounter."

* basedOn MS
* basedOn only Reference(HRServiceRequest)

* specimen MS
* specimen ^comment = "References the base Specimen resource. This guide does not yet profile it."

* conclusion MS
* presentedForm MS
* presentedForm ^short = "The report as issued"
* presentedForm ^comment = "The laboratory's own document, where one is returned. Held as an attachment here rather than as a DocumentReference, because it has no life independent of this report."


Profile: HRImagingStudy
Parent: ImagingStudy
Id: hr-imaging-study
Title: "Healthy Route Retinal Imaging"
Description: "The retinal photographs taken from one participant, one series per eye."
* ^status = #draft
* ^experimental = false
* ^purpose = "Describes the images the algorithm under validation consumes. This resource is metadata: it records which eye, when, on what device and by whom, and points at where the pixel data is held. It is the only resource in the guide whose subject matter is the study's actual input rather than its comparator."

* extension contains HRTenant named tenant 1..1 MS
* extension[tenant] ^short = "Owning site tenant"

* status 1..1 MS

* modality 1..* MS
* modality ^comment = "Ophthalmic photography. Recorded rather than assumed, because a consumer selecting images to send for prediction must not have to infer the modality from the description."

* subject 1..1 MS
* subject only Reference(HRPatient)

* encounter 1..1 MS
* encounter only Reference(HREncounter)

* started 1..1 MS
* started ^requirements = "One country times its blood pressure readings relative to this moment. The interval between the two is meaningless unless both carry a time."

* location MS
* location only Reference(HRLocation)

* referrer MS
* referrer only Reference(HRPractitioner)

* series 1..* MS
* series ^requirements = "The protocols photograph both eyes, so a conforming study ordinarily carries two series. One is permitted because a capture can fail on the day, and a study recording a single usable eye is a truthful record where a study asserting two would not be."
* series.uid 1..1 MS
* series.modality 1..1 MS
* series.laterality 1..1 MS
* series.laterality ^requirements = "Which eye. Required, where the base resource makes it optional. A prediction attributed to the wrong eye is not detectable after the fact, and laterality is the only thing distinguishing two otherwise identical series."
* series.started MS
* series.bodySite MS
* series.performer MS
* series.instance MS
* series.numberOfInstances MS
* series.description MS

* numberOfSeries MS
* numberOfInstances MS
* note MS
