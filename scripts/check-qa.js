#!/usr/bin/env node
//
// Fails the build when the IG Publisher reports validation errors.
//
// Reads output/qa.json rather than parsing output/qa.html. The JSON report
// carries the counts as structured fields; the HTML states them in prose, and a
// gate that pattern-matches prose reports success when its pattern stops
// matching. This gate fails when it cannot determine the count.
//
const fs = require('fs');
const path = require('path');

const REPORT = path.join('output', 'qa.json');
const MAX_ERRORS = Number.parseInt(process.env.MAX_QA_ERRORS ?? '0', 10);

function fail(message) {
  console.error(`QA gate failed: ${message}`);
  process.exit(1);
}

if (!fs.existsSync(REPORT)) {
  fail(`${REPORT} not found. The IG Publisher did not complete.`);
}

let report;
try {
  report = JSON.parse(fs.readFileSync(REPORT, 'utf8'));
} catch (cause) {
  fail(`${REPORT} is not valid JSON: ${cause.message}`);
}

const errors = report.errs;
const warnings = report.warnings;

if (!Number.isInteger(errors)) {
  fail(`${REPORT} does not report an integer error count. Found: ${JSON.stringify(errors)}`);
}

console.log(`Errors ${errors}, warnings ${warnings ?? 'unknown'}. Threshold ${MAX_ERRORS}.`);

if (errors > MAX_ERRORS) {
  fail(`${errors} error(s) exceeds the threshold of ${MAX_ERRORS}. See output/qa.html.`);
}

console.log('QA gate passed.');
