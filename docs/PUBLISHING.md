# Publishing

## The canonical is an identity, not a location

```
https://fhir.savannahghi.org/ig/healthy-route
```

It is stamped into every generated resource and into any instance that declares
`meta.profile`. It must never change. Validators resolve it out of the FHIR
package cache, **not** by dereferencing the URL — so nothing breaks while it
does not resolve.

Making it resolve is about trust and tooling, not correctness.

## Two namespaces, one owned domain

| Namespace | Used for | Stability |
|---|---|---|
| `https://fhir.savannahghi.org/ig/...` | IG canonicals | Change = regenerate the IG |
| `https://fhir.savannahghi.org/sid/...` | Identifier systems | Change = invalidate data already in AstraZeneca's bucket |

The `sid` namespace is the more dangerous of the two. `optimalhealth-participant`
ends up inside `Patient.identifier.system` on every exported record.

## Why not GitHub Pages

Pages serves a repo at `<domain>/<repo-name>/`. Pointing `fhir.savannahghi.org`
at `savannahghi.github.io` would serve this IG at `/healthy-route-ig/`, not at
`/ig/healthy-route/` — bending the canonical to fit the hosting.

It also couples the permanent identity of the spec to a hosting provider. Owning
the DNS is what decouples them: move hosts, repoint the record, canonical
unchanged.

## Target layout

```
fhir.savannahghi.org/
├── index.html                        namespace landing page
├── ig/
│   ├── healthy-route/                current release
│   │   ├── 0.1.0/                    pinned versions, kept forever
│   │   └── history.html
│   └── optimalhealth-core/           future sibling
└── sid/
    └── index.html                    what the identifier systems mean
```

Versioned paths are kept indefinitely. Someone validating three-year-old data
needs the profile as it was then.

## Phasing

### Phase 1 — now, repo private
Nothing needs to resolve. CI publishes the built site as a downloadable
artifact; reviewers get a zip. **No DNS required.**

### Phase 2 — before external review
Put a single static landing page at `fhir.savannahghi.org` explaining the
namespace. Costs nothing, and an AstraZeneca reviewer pasting the canonical into
a browser gets an explanation instead of a 404.

### Phase 3 — profile agreed
S3 + CloudFront serving the real IG. CI syncs on tagged releases.

```
DNS:  fhir  CNAME  <distribution>.cloudfront.net
```

Set `S3_BUCKET`, `CLOUDFRONT_DISTRIBUTION_ID` and AWS OIDC role as repo secrets;
the publish job in `.github/workflows/ig.yml` activates automatically once they
exist.

### Phase 4 — public
Flip the repo public. The HL7 auto-builder at build.fhir.org picks it up, and
the IG becomes citable in the AstraZeneca profile review.
