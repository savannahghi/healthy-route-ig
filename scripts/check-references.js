#!/usr/bin/env node
//
// Fails the build when a profile references a base resource for which this
// guide defines a profile.
//
// Two defects of this shape reached main before this check existed. HRConsent
// referenced DocumentReference while HRDocumentReference was being written in
// the same change, and both HRConsent and HRDocumentReference required an
// Organization and a Practitioner at a cardinality of 1..1 while no profile
// described either. Neither is a syntax error, so SUSHI compiles them; neither
// is a validation error, so the IG Publisher passes them. Both were found by a
// person reading the source and asking what the reference resolved to.
//
// The rule is narrow on purpose. Referencing a base resource is only reported
// when this guide defines a profile of that resource, because that is the case
// where the reference is demonstrably weaker than it could be. A reference to a
// resource the guide does not profile is reported as a note, since it may be
// deliberate and there is nothing yet to point at instead.
//
const fs = require('fs');
const path = require('path');

// Reads the publisher's output rather than SUSHI's.
//
// SUSHI emits differentials only, and a differential records nothing at all
// when an author constrains an element to the single type its base already
// allows. Consent.policyText is that case: restricted to DocumentReference by
// the base resource, so `only Reference(DocumentReference)` produces an element
// with no type at all and a check reading the differential cannot see it. The
// publisher resolves snapshots, and the effective target is visible there.
//
// The check therefore requires a completed build, and fails when it has not
// run. A check that quietly examines less than it claims to is the defect it
// exists to prevent.
const DIR = 'output';
const BASE = 'http://hl7.org/fhir/StructureDefinition/';

if (!fs.existsSync(DIR)) {
  console.error(
    `Reference check failed: ${DIR} not found. The IG Publisher did not complete.`
  );
  process.exit(1);
}

const definitions = fs
  .readdirSync(DIR)
  .filter((f) => /^StructureDefinition-[^.]+\.json$/.test(f))
  .map((f) => JSON.parse(fs.readFileSync(path.join(DIR, f), 'utf8')))
  .filter((sd) => sd.resourceType === 'StructureDefinition');

if (definitions.length === 0) {
  console.error(`Reference check failed: no StructureDefinitions found in ${DIR}.`);
  process.exit(1);
}

const withSnapshots = definitions.filter((sd) => sd.snapshot?.element?.length).length;
if (withSnapshots !== definitions.length) {
  console.error(
    `Reference check failed: ${definitions.length - withSnapshots} of ` +
      `${definitions.length} definitions have no snapshot, so their effective ` +
      `reference targets cannot be resolved.`
  );
  process.exit(1);
}

// Resource types this guide profiles, and the profiles that do so.
const profiledTypes = new Map();
for (const sd of definitions) {
  if (sd.derivation !== 'constraint' || sd.type === 'Extension') continue;
  if (!profiledTypes.has(sd.type)) profiledTypes.set(sd.type, []);
  profiledTypes.get(sd.type).push(sd.id);
}

const violations = [];
const notes = [];

// Resolved against the snapshot rather than the differential.
//
// An author who constrains an element to the one type its base already allows
// produces no differential entry at all: SUSHI has nothing to record. That is
// exactly the shape of the Consent.policyText defect, where the base restricts
// the element to DocumentReference and the guide's own profile of it was not
// used. Reading the snapshot sees the effective target either way.
//
// Only elements the author actually touched are examined, so an inherited
// reference nobody has constrained is not reported. Prohibited elements are
// skipped: a target on an element with a maximum of zero cannot be populated.
for (const sd of definitions) {
  if (sd.type === 'Extension') continue;

  const snapshot = new Map(
    (sd.snapshot?.element ?? []).map((element) => [element.id, element])
  );

  for (const differential of sd.differential?.element ?? []) {
    const element = snapshot.get(differential.id);
    if (!element) continue;
    if (element.max === '0') continue;

    const targets = new Set();
    for (const type of element.type ?? []) {
      if (type.code !== 'Reference' && type.code !== 'CodeableReference') continue;
      for (const target of type.targetProfile ?? []) targets.add(target);
    }
    if (targets.size === 0) continue;

    // An element may name several targets, some local and some base. Each is
    // judged on its own: a base target is exempt only where a local profile of
    // that same resource type sits alongside it, which is redundant rather than
    // wrong. Exempting the whole element as soon as any local profile appeared
    // would hide an unprofiled target behind a profiled sibling.
    const covered = new Set(
      [...targets]
        .filter((t) => !t.startsWith(BASE))
        .map((t) => definitions.find((d) => d.url === t.split('|')[0])?.type)
        .filter(Boolean)
    );

    for (const target of targets) {
      if (!target.startsWith(BASE)) continue;
      // Canonicals may carry a version suffix, as PlanDefinition|5.0.0 does.
      const resource = target.slice(BASE.length).split('|')[0];
      if (covered.has(resource)) continue;
      const where = `${sd.id}: ${element.id}`;
      if (profiledTypes.has(resource)) {
        violations.push(
          `${where} -> ${resource}, but this guide profiles it as ` +
            profiledTypes.get(resource).join(', ')
        );
      } else {
        notes.push(`${where} -> ${resource} (not profiled by this guide)`);
      }
    }
  }
}

for (const note of notes) console.log(`  note: ${note}`);

if (violations.length > 0) {
  console.error('\nReference check failed. A profile exists for these targets:\n');
  for (const v of violations) console.error(`  ${v}`);
  console.error(
    '\nEither point the reference at the profile, or state in the element ' +
      'comment why the base resource is intended.\n'
  );
  process.exit(1);
}

console.log(
  `Reference check passed. ${definitions.length} definitions, ` +
    `${profiledTypes.size} profiled resource types, ${notes.length} unprofiled target(s).`
);
