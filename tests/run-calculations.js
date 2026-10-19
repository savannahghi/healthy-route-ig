#!/usr/bin/env node
//
// Checks every calculated item on the forms by running its expression the way
// the Advantage form renderer runs it, with the same FHIRPath engine at the same
// version (fhirpath 4.11.0, R5 model).
//
// The renderer evaluates the form's variables in order against the response
// being filled, binding each as %name, then each calculated item against the
// response and those variables, and writes the first result into the item:
// rounded for an integer, as a number for a decimal, only a true boolean for a
// boolean. An initial expression is evaluated once when the form opens, with
// the participant as %patient and the visit as %encounter. This script does the
// same, so a formula that passes here gives the same number on the screen.
//
// The cases are one table: the example responses, whose calculated answers must
// be what their typed answers give; the CKD-EPI 2021 test vectors from the
// platform scope; and the edges, where a missing or unusable input must give no
// value rather than a wrong one.
//
// Usage: npx sushi build . && node tests/run-calculations.js
//
'use strict';

const fs = require('fs');
const path = require('path');
const fhirpath = require('fhirpath');
const r5 = require('fhirpath/fhir-context/r5');

const ROOT = path.join(__dirname, '..');
const GENERATED = path.join(ROOT, 'fsh-generated', 'resources');
const EXAMPLES = path.join(ROOT, 'input', 'examples');

const CALCULATED = 'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression';
const INITIAL = 'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-initialExpression';
const VARIABLE = 'http://hl7.org/fhir/StructureDefinition/variable';

// --- the forms and the renderer's evaluation --------------------------------

function form(id) {
  const file = path.join(GENERATED, `Questionnaire-${id}.json`);
  if (!fs.existsSync(file)) {
    throw new Error(`${file} not found. Run npx sushi build . first.`);
  }
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

// Every item carrying an extension of the given kind, at any depth.
function itemsWith(items, url, found = []) {
  for (const item of items || []) {
    const ext = (item.extension || []).find(e => e.url === url);
    if (ext) found.push({ item, expression: ext.valueExpression.expression });
    itemsWith(item.item, url, found);
  }
  return found;
}

function run(root, expression, env) {
  return fhirpath.evaluate(root, expression, env, r5);
}

// The renderer's coercion of a result into the control the item binds.
function coerce(item, raw) {
  if (raw === null || raw === undefined) return null;
  const scalar = typeof raw === 'object' ? (raw.code ?? raw.value ?? null) : raw;
  if (scalar === null || typeof scalar === 'object') return undefined;
  switch (item.type) {
    case 'integer': {
      const n = Number(scalar);
      return Number.isFinite(n) ? Math.round(n) : undefined;
    }
    case 'decimal': {
      const n = Number(scalar);
      return Number.isFinite(n) ? n : undefined;
    }
    case 'boolean':
      return typeof scalar === 'boolean' ? scalar : undefined;
    default:
      return scalar;
  }
}

// What the screen shows in each calculated item for this response.
function calculate(q, qr) {
  const env = { resource: qr };
  for (const v of (q.extension || []).filter(e => e.url === VARIABLE)) {
    const result = run(qr, v.valueExpression.expression, env);
    env[v.valueExpression.name] = result.length === 1 ? result[0] : result;
  }
  const out = {};
  for (const { item, expression } of itemsWith(q.item, CALCULATED)) {
    const result = run(qr, expression, env);
    out[item.linkId] = result.length ? coerce(item, result[0]) : null;
  }
  return out;
}

// What the screen fills in when it opens the form for this participant and visit.
function initial(q, context) {
  const out = {};
  for (const { item, expression } of itemsWith(q.item, INITIAL)) {
    const result = run({}, expression, context);
    out[item.linkId] = result.length ? coerce(item, result[0]) : null;
  }
  return out;
}

// --- building responses -------------------------------------------------------

const ucum = code => ({ system: 'http://unitsofmeasure.org', code, display: code });

// One answer per linkId, typed as the renderer types it. A dotted key inside a
// group, such as bp-reading-2.8480-6, is placed in its group.
function response(answers) {
  const top = [];
  const groups = {};
  for (const [linkId, answer] of Object.entries(answers)) {
    if (answer === null || answer === undefined) continue;
    const entry = { linkId, answer: [answer] };
    const dot = linkId.indexOf('.');
    const group = dot > 0 && linkId.startsWith('bp-') ? linkId.slice(0, dot) : null;
    if (group) {
      if (!groups[group]) {
        groups[group] = { linkId: group, item: [] };
        top.push(groups[group]);
      }
      groups[group].item.push(entry);
    } else {
      top.push(entry);
    }
  }
  return { resourceType: 'QuestionnaireResponse', status: 'in-progress', item: top };
}

const dec = v => (v === null ? null : { valueDecimal: v });
const int = v => (v === null ? null : { valueInteger: v });
const str = v => (v === null ? null : { valueString: v });
const coding = v => (v === null ? null : { valueCoding: v });

function laboratory({ creatinine, unit, age, sex }) {
  return response({
    '2160-0': dec(creatinine),
    '2160-0.unit': unit === null ? null : coding(ucum(unit)),
    'egfr-age': int(age),
    'egfr-sex': str(sex),
  });
}

function vitals({ height, weight, waist, hip, readings }) {
  const answers = { '8302-2': dec(height), '29463-7': dec(weight), '8280-0': dec(waist), 'hip-circumference': dec(hip) };
  readings.forEach((r, i) => {
    if (!r) return;
    answers[`bp-reading-${i + 1}.8480-6`] = dec(r[0]);
    answers[`bp-reading-${i + 1}.8462-4`] = dec(r[1]);
  });
  return response(answers);
}

function diet({ fruit, veg, days, minutes }) {
  return response({ 'fruit-days': int(fruit), 'veg-days': int(veg), 'activity-days': int(days), 'activity-minutes': int(minutes) });
}

// The answers an example response holds, by linkId, at any depth.
function answersOf(items, out = {}) {
  for (const item of items || []) {
    if (item.answer && item.answer.length) {
      const a = item.answer[0];
      out[item.linkId] = a.valueDecimal ?? a.valueInteger ?? a.valueBoolean ?? a.valueString ?? a.valueCoding ?? null;
    }
    answersOf(item.item, out);
  }
  return out;
}

function example(name) {
  return JSON.parse(fs.readFileSync(path.join(EXAMPLES, `QuestionnaireResponse-${name}.json`), 'utf8'));
}

// --- the cases ------------------------------------------------------------------

const participant = { resourceType: 'Patient', gender: 'female', birthDate: '1971-06-02' };
const visitOn = start => ({ resourceType: 'Encounter', actualPeriod: { start } });

const vitalsForm = form('hr-vitals-ug');
const dietForm = form('hr-diet-activity-ug');
const labForm = form('hr-laboratory-ug');

// An example response's calculated answers must be what the form calculates
// from its typed answers, item for item, and every calculated item must be there.
function exampleCase(name, q) {
  const qr = example(name);
  const held = answersOf(qr.item);
  const want = {};
  for (const { item } of itemsWith(q.item, CALCULATED)) want[item.linkId] = held[item.linkId] ?? null;
  return { name: `happy case: the ${name} example holds what its answers calculate to`, form: q, qr, want };
}

const cases = [
  exampleCase('qr-vitals', vitalsForm),
  exampleCase('qr-diet-activity', dietForm),
  exampleCase('qr-laboratory', labForm),
  {
    name: 'happy case: the laboratory example\'s age and sex are what its participant and visit give',
    form: labForm,
    context: { patient: participant, encounter: visitOn('2026-04-14T09:05:00+03:00') },
    want: { 'egfr-age': answersOf(example('qr-laboratory').item)['egfr-age'], 'egfr-sex': 'female' },
  },

  // CKD-EPI 2021 vectors, platform scope v3.0, AC-CAP-09 to AC-CAP-13.
  ...[
    ['AC-CAP-09 female 60, 1.2 mg/dL', 1.2, 'mg/dL', 60, 'female', 51.8],
    ['AC-CAP-10 male 45, 97 umol/L', 97, 'umol/L', 45, 'male', 84.6],
    ['AC-CAP-11 male 50, 1.42 mg/dL', 1.42, 'mg/dL', 50, 'male', 60.2],
    ['AC-CAP-11 male 50, 1.43 mg/dL', 1.43, 'mg/dL', 50, 'male', 59.7],
    ['AC-CAP-12 female 30, 0.6 mg/dL', 0.6, 'mg/dL', 30, 'female', 123.8],
    ['AC-CAP-13 male 25, 1.1 mg/dL', 1.1, 'mg/dL', 25, 'male', 95.5],
    ['AC-CAP-13 male 52, 1.1 mg/dL', 1.1, 'mg/dL', 52, 'male', 80.8],
  ].map(([label, creatinine, unit, age, sex, egfr]) => ({
    name: `happy case: eGFR vector ${label} gives ${egfr}`,
    form: labForm,
    qr: laboratory({ creatinine, unit, age, sex }),
    want: { '98979-8': egfr },
  })),
  {
    name: 'happy case: a creatinine in umol/L is shown in mg/dL as the equation uses it',
    form: labForm,
    qr: laboratory({ creatinine: 97, unit: 'umol/L', age: 45, sex: 'male' }),
    want: { 'creatinine-converted': 1.1 },
  },
  {
    name: 'sad case: no creatinine gives no eGFR and no converted creatinine',
    form: labForm,
    qr: laboratory({ creatinine: null, unit: 'mg/dL', age: 60, sex: 'female' }),
    want: { '98979-8': null, 'creatinine-converted': null },
  },
  {
    name: 'sad case: a creatinine in a unit the equation cannot use gives no eGFR',
    form: labForm,
    qr: laboratory({ creatinine: 1.2, unit: 'mmol/L', age: 60, sex: 'female' }),
    want: { '98979-8': null, 'creatinine-converted': null },
  },
  {
    name: 'sad case: a sex other than female or male gives no eGFR',
    form: labForm,
    qr: laboratory({ creatinine: 1.2, unit: 'mg/dL', age: 60, sex: 'other' }),
    want: { '98979-8': null, 'creatinine-converted': 1.2 },
  },
  {
    name: 'sad case: no age gives no eGFR',
    form: labForm,
    qr: laboratory({ creatinine: 1.2, unit: 'mg/dL', age: null, sex: 'female' }),
    want: { '98979-8': null },
  },
  {
    name: 'happy case: the age is the completed years on the day the visit started',
    form: labForm,
    context: { patient: participant, encounter: visitOn('2026-06-01T09:00:00+03:00') },
    want: { 'egfr-age': 54, 'egfr-sex': 'female' },
  },
  {
    name: 'happy case: a visit on the birthday counts the new year',
    form: labForm,
    context: { patient: participant, encounter: visitOn('2026-06-02T09:00:00+03:00') },
    want: { 'egfr-age': 55 },
  },
  {
    name: 'happy case: a date of birth with only a year counts whole calendar years',
    form: labForm,
    context: { patient: { ...participant, birthDate: '1971' }, encounter: visitOn('2026-04-14T09:05:00+03:00') },
    want: { 'egfr-age': 55 },
  },
  {
    name: 'happy case: with no visit supplied the age is counted to today',
    form: labForm,
    context: { patient: participant, encounter: null },
    want: { 'egfr-age': ageToday(participant.birthDate) },
  },
  {
    name: 'happy case: BMI, waist-to-hip and the mean of readings two and three',
    form: vitalsForm,
    qr: vitals({ height: 170, weight: 80, waist: 90, hip: 100, readings: [[150, 95], [141, 89], [138, 86]] }),
    want: { '39156-5': 27.7, 'waist-hip-ratio': 0.9, 'bp-mean.8480-6': 140, 'bp-mean.8462-4': 88 },
  },
  {
    name: 'happy case: the first reading never moves the mean',
    form: vitalsForm,
    qr: vitals({ height: 170, weight: 80, waist: 90, hip: 100, readings: [[220, 130], [141, 89], [138, 86]] }),
    want: { 'bp-mean.8480-6': 140, 'bp-mean.8462-4': 88 },
  },
  {
    name: 'sad case: no height gives no BMI, no hip no ratio, no third reading no mean',
    form: vitalsForm,
    qr: vitals({ height: null, weight: 80, waist: 90, hip: null, readings: [[150, 95], [141, 89], null] }),
    want: { '39156-5': null, 'waist-hip-ratio': null, 'bp-mean.8480-6': null, 'bp-mean.8462-4': null },
  },
  {
    name: 'happy case: fruit and vegetables both five days, activity at the WHO threshold',
    form: dietForm,
    qr: diet({ fruit: 5, veg: 5, days: 5, minutes: 30 }),
    want: { 'fruit-veg-5plus': true, 'activity-weekly-minutes': 150, 'activity-who-met': true },
  },
  {
    name: 'happy case: no activity is zero minutes and below the recommendation',
    form: dietForm,
    qr: diet({ fruit: 7, veg: 4, days: 0, minutes: 60 }),
    want: { 'fruit-veg-5plus': false, 'activity-weekly-minutes': 0, 'activity-who-met': false },
  },
  {
    name: 'sad case: one count missing settles the answer only when the other is below five',
    form: dietForm,
    qr: diet({ fruit: null, veg: 3, days: 3, minutes: null }),
    want: { 'fruit-veg-5plus': false, 'activity-weekly-minutes': null, 'activity-who-met': null },
  },
  {
    name: 'sad case: one count missing and the other at five or more leaves it unanswered',
    form: dietForm,
    qr: diet({ fruit: null, veg: 6, days: 2, minutes: 20 }),
    want: { 'fruit-veg-5plus': null },
  },
];

function ageToday(birthDate) {
  const now = new Date();
  const [y, m, d] = birthDate.split('-').map(Number);
  const before = now.getMonth() + 1 < m || (now.getMonth() + 1 === m && now.getDate() < d);
  return now.getFullYear() - y - (before ? 1 : 0);
}

// --- running them -------------------------------------------------------------

let failed = 0;

for (const c of cases) {
  let got;
  try {
    got = c.qr ? calculate(c.form, c.qr) : initial(c.form, c.context);
  } catch (err) {
    console.log(`FAIL ${c.name}: the expression did not run: ${err.message}`);
    failed++;
    continue;
  }
  const wrong = Object.entries(c.want).filter(([linkId, want]) => got[linkId] !== want);
  if (wrong.length) {
    failed++;
    console.log(`FAIL ${c.name}`);
    for (const [linkId, want] of wrong) console.log(`       ${linkId}: want ${JSON.stringify(want)}, got ${JSON.stringify(got[linkId])}`);
  } else {
    console.log(`ok   ${c.name}`);
  }
}

console.log(`${cases.length - failed} of ${cases.length} cases pass`);
process.exit(failed ? 1 : 0);
