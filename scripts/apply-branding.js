#!/usr/bin/env node
//
// Adds the OptimalHealth stylesheet to every page the IG Publisher generates.
//
// The publisher renders pages from fhir.base.template, which is a root template
// carrying no template.xml and so is not structured to be extended. Forking it
// would place its entire contents under version control here and require
// re-synchronisation on each upstream release. Appending one stylesheet link
// after the build leaves the template untouched and keeps the brand rules in a
// single reviewable file.
//
// The link is inserted last so that its declarations take precedence over the
// template's own stylesheets without relying on selector specificity alone.
//
const fs = require('fs');
const path = require('path');

const OUTPUT = 'output';
const STYLESHEET = 'optimalhealth.css';
const LINK = `<link href="${STYLESHEET}" rel="stylesheet"/>`;

if (!fs.existsSync(OUTPUT)) {
  console.error(`Branding failed: ${OUTPUT} not found. Run the IG Publisher first.`);
  process.exit(1);
}

if (!fs.existsSync(path.join(OUTPUT, STYLESHEET))) {
  console.error(`Branding failed: ${STYLESHEET} was not copied to ${OUTPUT}.`);
  console.error(`It is expected at input/images/${STYLESHEET}.`);
  process.exit(1);
}

const pages = fs.readdirSync(OUTPUT).filter((f) => f.endsWith('.html'));
let branded = 0;
let skipped = 0;

for (const page of pages) {
  const file = path.join(OUTPUT, page);
  const html = fs.readFileSync(file, 'utf8');

  if (html.includes(LINK)) { skipped += 1; continue; }
  if (!html.includes('</head>')) { skipped += 1; continue; }

  fs.writeFileSync(file, html.replace('</head>', `${LINK}\n</head>`), 'utf8');
  branded += 1;
}

console.log(`Branding applied to ${branded} page(s); ${skipped} skipped.`);

if (branded === 0) {
  console.error('Branding failed: no pages were modified.');
  process.exit(1);
}
