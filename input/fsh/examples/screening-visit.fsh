// A complete screening visit for one participant.
//
// Every resource here links to the ones around it, so the set can be walked
// from the encounter outwards. It follows the sequence both protocols specify:
// interview, three blood pressures, urine dipstick, samples for the laboratory,
// then retinal photography of both eyes.
//
// The participant is ExampleParticipant, consented in ExampleConsentParticipation.
// Data is invented.

Instance: ExampleScreeningVisit
InstanceOf: HREncounter
Usage: #example
Title: "Example screening visit"
Description: "The single cross-sectional visit at which everything is collected. The clinic is recorded because disease prevalence differs between clinics, and predictive values move with prevalence."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #completed
* type[0] = HREncounterTypeCS#visit
* class = $v3-ActCode#AMB "ambulatory"
* subject = Reference(ExampleParticipant)
* actualPeriod.start = "2026-04-14T09:05:00+03:00"
* actualPeriod.end = "2026-04-14T11:20:00+03:00"
* serviceProvider = Reference(ExampleStudySite)
* location[0].location = Reference(ExampleRenalClinic)
* participant[0].actor = Reference(ExampleStudyNurse)

Instance: ExampleSamplesEncounter
InstanceOf: HREncounter
Usage: #example
Title: "Example visit part: samples"
Description: "The day the blood and urine were drawn, as a part of the visit with its own date. Here it is the visit day; the protocols allow it up to 28 days after consent."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #completed
* type[0] = HREncounterTypeCS#samples
* class = $v3-ActCode#AMB "ambulatory"
* subject = Reference(ExampleParticipant)
* partOf = Reference(ExampleScreeningVisit)
* actualPeriod.start = "2026-04-14T10:05:00+03:00"
* actualPeriod.end = "2026-04-14T10:15:00+03:00"
* serviceProvider = Reference(ExampleStudySite)

Instance: ExampleImagingEncounter
InstanceOf: HREncounter
Usage: #example
Title: "Example visit part: imaging"
Description: "The day the retina was photographed, as a part of the visit with its own date."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #completed
* type[0] = HREncounterTypeCS#imaging
* class = $v3-ActCode#AMB "ambulatory"
* subject = Reference(ExampleParticipant)
* partOf = Reference(ExampleScreeningVisit)
* actualPeriod.start = "2026-04-14T10:50:00+03:00"
* actualPeriod.end = "2026-04-14T11:10:00+03:00"
* serviceProvider = Reference(ExampleStudySite)


// --- Blood pressure: three readings, then the derived value -----------------

Instance: ExampleBloodPressure1
InstanceOf: HRBloodPressure
Usage: #example
Title: "Blood pressure, first reading"
Description: "The first of three readings. Timing matters: one protocol positions its readings relative to the retinal photography."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[VSCat] = $obs-category#vital-signs
* code = $loinc#85354-9 "Blood pressure panel with all children optional"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* effectiveDateTime = "2026-04-14T09:20:00+03:00"
* performer[0] = Reference(ExampleStudyNurse)
* component[SystolicBP].code = $loinc#8480-6 "Systolic blood pressure"
* component[SystolicBP].valueQuantity = 148 'mm[Hg]' "mmHg"
* component[DiastolicBP].code = $loinc#8462-4 "Diastolic blood pressure"
* component[DiastolicBP].valueQuantity = 94 'mm[Hg]' "mmHg"
* extension[sequence].valueInteger = 1
* extension[device].valueCodeableConcept = HRBloodPressureDeviceCS#omron-m6 "Omron M6"

Instance: ExampleBloodPressure2
InstanceOf: HRBloodPressure
Usage: #example
Title: "Blood pressure, second reading"
Description: "The second reading. One protocol discards the first and takes the mean of readings two and three."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[VSCat] = $obs-category#vital-signs
* code = $loinc#85354-9 "Blood pressure panel with all children optional"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* effectiveDateTime = "2026-04-14T09:26:00+03:00"
* performer[0] = Reference(ExampleStudyNurse)
* component[SystolicBP].code = $loinc#8480-6 "Systolic blood pressure"
* component[SystolicBP].valueQuantity = 142 'mm[Hg]' "mmHg"
* component[DiastolicBP].code = $loinc#8462-4 "Diastolic blood pressure"
* component[DiastolicBP].valueQuantity = 90 'mm[Hg]' "mmHg"
* extension[sequence].valueInteger = 2
* extension[device].valueCodeableConcept = HRBloodPressureDeviceCS#omron-m6 "Omron M6"
* extension[position].valueCodeableConcept = HRBloodPressurePositionCS#before-capture "Before retinal capture"

Instance: ExampleBloodPressure3
InstanceOf: HRBloodPressure
Usage: #example
Title: "Blood pressure, third reading"
Description: "The third reading."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[VSCat] = $obs-category#vital-signs
* code = $loinc#85354-9 "Blood pressure panel with all children optional"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* effectiveDateTime = "2026-04-14T09:32:00+03:00"
* performer[0] = Reference(ExampleStudyNurse)
* component[SystolicBP].code = $loinc#8480-6 "Systolic blood pressure"
* component[SystolicBP].valueQuantity = 138 'mm[Hg]' "mmHg"
* component[DiastolicBP].code = $loinc#8462-4 "Diastolic blood pressure"
* component[DiastolicBP].valueQuantity = 88 'mm[Hg]' "mmHg"
* extension[sequence].valueInteger = 3
* extension[device].valueCodeableConcept = HRBloodPressureDeviceCS#omron-m6 "Omron M6"

Instance: ExampleBloodPressureMean
InstanceOf: HRBloodPressure
Usage: #example
Title: "Blood pressure, derived value"
Description: "The value carried forward to analysis, with derivedFrom naming the readings it used. Here it is the mean of the second and third, which is one protocol's rule; the other averages all three. The rule belongs to the study, and what is recorded here is which readings were actually used, so the calculation can be checked rather than trusted."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[VSCat] = $obs-category#vital-signs
* code = $loinc#85354-9 "Blood pressure panel with all children optional"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* effectiveDateTime = "2026-04-14T09:32:00+03:00"
* derivedFrom[0] = Reference(ExampleBloodPressure2)
* derivedFrom[1] = Reference(ExampleBloodPressure3)
* component[SystolicBP].code = $loinc#8480-6 "Systolic blood pressure"
* component[SystolicBP].valueQuantity = 140 'mm[Hg]' "mmHg"
* component[DiastolicBP].code = $loinc#8462-4 "Diastolic blood pressure"
* component[DiastolicBP].valueQuantity = 89 'mm[Hg]' "mmHg"


// --- Urine dipstick ---------------------------------------------------------

Instance: ExampleUrineDipstick
InstanceOf: HRObservation
Usage: #example
Title: "Urine dipstick protein"
Description: "A coded ordinal result on the scale printed on the data collection tool. In one protocol this gates eligibility; in the other it is the comparator the algorithm is measured against, and is recorded for every participant regardless of the result."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#laboratory
* code = $loinc#20454-5 "Protein [Presence] in Urine by Test strip"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* specimen = Reference(ExampleUrineSample)
* effectiveDateTime = "2026-04-14T09:45:00+03:00"
* performer[0] = Reference(ExampleStudyNurse)
* valueCodeableConcept = HRDipstickProteinCS#trace "Trace"


// --- Samples ----------------------------------------------------------------

Instance: ExampleBloodSample
InstanceOf: HRSpecimen
Usage: #example
Title: "Blood sample"
Description: "The venous blood the creatinine and HbA1c were measured on. Its collection time is what the 28-day window is checked against, and what the results refer to."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #available
* type = $v2-0487#BLD "Whole blood"
* subject = Reference(ExampleParticipant)
* collection.collectedDateTime = "2026-04-14T10:08:00+03:00"
* collection.collector = Reference(ExampleStudyNurse)

Instance: ExampleUrineSample
InstanceOf: HRSpecimen
Usage: #example
Title: "Urine sample"
Description: "The spot urine the dipstick and the albumin-to-creatinine ratio were measured on."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #available
* type = $v2-0487#UR "Urine"
* subject = Reference(ExampleParticipant)
* collection.collectedDateTime = "2026-04-14T09:40:00+03:00"
* collection.collector = Reference(ExampleStudyNurse)


// --- Laboratory: the request, the results, the report -----------------------

Instance: ExampleLabRequest
InstanceOf: HRServiceRequest
Usage: #example
Title: "Request for laboratory investigations"
Description: "One order covering the blood and urine investigations the protocol specifies. authoredOn carries its own timestamp so that ordering before consent is detectable."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #completed
* intent = #order
* category[0] = $obs-category#laboratory
* code.concept.text = "Serum creatinine, HbA1c and urine albumin-to-creatinine ratio"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleScreeningVisit)
* authoredOn = "2026-04-14T09:50:00+03:00"
* requester = Reference(ExampleStudyNurse)
* performer[0] = Reference(ExampleStudySite)

Instance: ExampleCreatinine
InstanceOf: HRObservation
Usage: #example
Title: "Serum creatinine"
Description: "The measured value the eGFR is calculated from."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#laboratory
* code = $loinc#2160-0 "Creatinine [Mass/volume] in Serum or Plasma"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleSamplesEncounter)
* specimen = Reference(ExampleBloodSample)
* effectiveDateTime = "2026-04-14T10:10:00+03:00"
* performer[0] = Reference(ExampleStudySite)
* valueQuantity = 122 'umol/L' "µmol/L"

Instance: ExampleEgfr
InstanceOf: HRObservation
Usage: #example
Title: "eGFR by CKD-EPI 2021"
Description: "A calculated value, not a measured one. derivedFrom names the creatinine it was computed from and method names the equation, because neither is recoverable from the number. LOINC 98979-8 is the 2021 revision with the race coefficient removed; 62238-1 is the generic CKD-EPI code and would understate what was done."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#laboratory
* code = $loinc#98979-8 "Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI 2021)/1.73 sq M"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleSamplesEncounter)
* effectiveDateTime = "2026-04-14T10:10:00+03:00"
* performer[0] = Reference(ExampleStudySite)
* valueQuantity = 47 'mL/min/{1.73_m2}' "mL/min/1.73m2"
* derivedFrom[0] = Reference(ExampleCreatinine)
* method.text = "CKD-EPI 2021 creatinine equation, without race coefficient"

Instance: ExampleHba1c
InstanceOf: HRObservation
Usage: #example
Title: "HbA1c"
Description: "The protocols define type 2 diabetes as HbA1c above 6.5% or on the basis of clinical history."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#laboratory
* code = $loinc#4548-4 "Hemoglobin A1c/Hemoglobin.total in Blood"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleSamplesEncounter)
* specimen = Reference(ExampleBloodSample)
* effectiveDateTime = "2026-04-14T10:10:00+03:00"
* performer[0] = Reference(ExampleStudySite)
* valueQuantity = 7.1 '%' "%"

Instance: ExampleUacr
InstanceOf: HRObservation
Usage: #example
Title: "Urine albumin-to-creatinine ratio"
Description: "Measured for risk stratification. One protocol states explicitly that it is not used for exclusion."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#laboratory
* code = $loinc#9318-7 "Albumin/Creatinine [Mass Ratio] in Urine"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleSamplesEncounter)
* specimen = Reference(ExampleUrineSample)
* effectiveDateTime = "2026-04-14T10:10:00+03:00"
* performer[0] = Reference(ExampleStudySite)
* valueQuantity = 68 'mg/g' "mg/g"

Instance: ExampleLabReport
InstanceOf: HRDiagnosticReport
Usage: #example
Title: "Laboratory report"
Description: "What the laboratory returned, gathering the four results it issued together. issued is separate from effective: the interval between a sample being drawn and a result being released is what a site is asked about once the participant has left."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #final
* category[0] = $obs-category#laboratory
* code.text = "Healthy Route screening laboratory panel"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleSamplesEncounter)
* specimen[0] = Reference(ExampleBloodSample)
* specimen[1] = Reference(ExampleUrineSample)
* effectiveDateTime = "2026-04-14T10:10:00+03:00"
* issued = "2026-04-16T14:02:00+03:00"
* performer[0] = Reference(ExampleStudySite)
* basedOn[0] = Reference(ExampleLabRequest)
* result[0] = Reference(ExampleCreatinine)
* result[1] = Reference(ExampleEgfr)
* result[2] = Reference(ExampleHba1c)
* result[3] = Reference(ExampleUacr)


// --- Retinal imaging --------------------------------------------------------

Instance: ExampleRetinalImaging
InstanceOf: HRImagingStudy
Usage: #example
Title: "Retinal photography, both eyes"
Description: "The material the algorithm under validation consumes. One series per eye, each carrying its own laterality, because a prediction attributed to the wrong eye is not detectable after the fact."
* extension[tenant].valueIdentifier.system = "https://example.org/sid/tenant"
* extension[tenant].valueIdentifier.value = "site-a"
* status = #available
* modality[0] = $dcm#OP "Ophthalmic Photography"
* subject = Reference(ExampleParticipant)
* encounter = Reference(ExampleImagingEncounter)
* started = "2026-04-14T10:55:00+03:00"
* location = Reference(ExampleRenalClinic)
* referrer = Reference(ExampleStudyNurse)
* numberOfSeries = 2
* numberOfInstances = 2
* series[0].uid = "2.25.140000000000000000000000000000001"
* series[0].number = 1
* series[0].modality = $dcm#OP "Ophthalmic Photography"
* series[0].laterality = HREyeCS#right "Right eye"
* series[0].description = "Right eye, 45 degree primary field"
* series[0].numberOfInstances = 1
* series[0].started = "2026-04-14T10:55:00+03:00"
* series[1].uid = "2.25.140000000000000000000000000000002"
* series[1].number = 2
* series[1].modality = $dcm#OP "Ophthalmic Photography"
* series[1].laterality = HREyeCS#left "Left eye"
* series[1].description = "Left eye, 45 degree primary field"
* series[1].numberOfInstances = 1
* series[1].started = "2026-04-14T10:58:00+03:00"
