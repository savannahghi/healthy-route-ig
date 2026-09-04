#!/usr/bin/env node
//
// Fails the build on any validation error the guide has not explicitly accepted.
//
// Reads output/qa-eslintcompact.txt rather than output/qa.json. The JSON report
// carries a single err count, and that count excludes broken links: a build with
// six dead links in its rendered pages reports err = 1 and a gate reading it
// announces success. The compact report lists every message the publisher
// produced, at every severity, one per line, which is the only output that
// describes the whole build.
//
// Errors are matched against input/qa-allowed-errors.txt. An error whose message
// contains an entry there is reported as accepted, with its recorded reason;
// every other error fails the build. The allow-list is for defects outside this
// repository. An error that can be fixed here is fixed here.
//
// The gate fails closed. A missing report, an unparseable one, a report with no
// messages at all, or an allow-list entry with no recorded reason all stop the
// build rather than being read as nothing to report.
//
const fs = require('fs');
const path = require('path');

const REPORT = path.join('output', 'qa-eslintcompact.txt');
const ALLOWED = path.join('input', 'qa-allowed-errors.txt');

function fail(message) {
  console.error(`QA gate failed: ${message}`);
  process.exit(1);
}

// --- the allow-list, and the rule that every entry carries a reason ----------

function readAllowList(file) {
  if (!fs.existsSync(file)) {
    fail(`${file} not found. The gate cannot tell an accepted error from a new one.`);
  }
  const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
  const entries = [];
  let reason = [];

  for (const [index, raw] of lines.entries()) {
    const line = raw.trim();
    if (line.startsWith('#')) {
      reason.push(line.replace(/^#\s?/, ''));
      continue;
    }
    if (line === '') {
      reason = [];
      continue;
    }
    if (reason.length === 0) {
      fail(
        `${file} line ${index + 1} has no preceding comment. ` +
          `Every accepted error must record why it is accepted.`
      );
    }
    entries.push({ text: line, reason: reason.join(' ') });
    reason = [];
  }
  return entries;
}

// --- the report --------------------------------------------------------------

if (!fs.existsSync(REPORT)) {
  fail(`${REPORT} not found. The IG Publisher did not complete.`);
}

const lines = fs.readFileSync(REPORT, 'utf8').split(/\r?\n/);

// Message lines look like:
//   <file>: line 1, col 36455, Error - <message> (INVALID)
//   Generic: line 0, col 0, Error - <message> (NOTFOUND)
const MESSAGE = /^(.*?):\s*line\s+\d+,\s*col\s+\d+,\s*(Error|Warning|Info|Information)\s+-\s+(.*)$/;

const messages = [];
for (const line of lines) {
  const match = MESSAGE.exec(line);
  if (match) {
    messages.push({ file: match[1], severity: match[2], text: match[3] });
  }
}

if (messages.length === 0) {
  fail(
    `${REPORT} contains no messages. A build that validated nothing is not a ` +
      `build that found nothing.`
  );
}

const allowList = readAllowList(ALLOWED);
const errors = messages.filter((m) => m.severity === 'Error');
const warnings = messages.filter((m) => m.severity === 'Warning').length;
const info = messages.filter((m) => m.severity === 'Info' || m.severity === 'Information').length;

const accepted = [];
const unaccepted = [];
for (const error of errors) {
  const entry = allowList.find((a) => error.text.includes(a.text));
  (entry ? accepted : unaccepted).push({ ...error, entry });
}

// --- report ------------------------------------------------------------------

console.log(
  `${messages.length} messages: ${errors.length} error(s), ${warnings} warning(s), ${info} informational.`
);

if (accepted.length > 0) {
  const byEntry = new Map();
  for (const a of accepted) {
    const key = a.entry.text;
    byEntry.set(key, (byEntry.get(key) ?? 0) + 1);
  }
  console.log(`\n${accepted.length} error(s) accepted by ${ALLOWED}:`);
  for (const [text, count] of byEntry) {
    const entry = allowList.find((a) => a.text === text);
    console.log(`  ${count}x  ${text}`);
    console.log(`        reason: ${entry.reason.slice(0, 160)}`);
  }
}

const unused = allowList.filter((a) => !accepted.some((x) => x.entry.text === a.text));
if (unused.length > 0) {
  console.log(`\n${unused.length} allow-list entr(ies) matched nothing and can be removed:`);
  for (const u of unused) console.log(`  ${u.text}`);
}

if (unaccepted.length > 0) {
  console.error(`\n${unaccepted.length} error(s) not accepted:\n`);
  for (const e of unaccepted) {
    console.error(`  ${e.file}`);
    console.error(`    ${e.text}\n`);
  }
  console.error(
    `Fix them, or add the message to ${ALLOWED} with a comment recording why ` +
      `it cannot be fixed here.\n`
  );
  process.exit(1);
}

console.log('\nQA gate passed.');
