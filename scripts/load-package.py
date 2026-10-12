"""Loads the guide's conformance resources from a built package into a FHIR store.

The study service reads the visit forms, the maps that turn a filled form into
records, the answer lists and the profiles from its own FHIR store. This script
puts them there. It reads the package the IG Publisher builds and PUTs every
CodeSystem, ValueSet, ConceptMap, StructureDefinition, SearchParameter,
StructureMap and Questionnaire in it under the id the package gives it.

It takes the package rather than fsh-generated/ because only the publisher fills
in each profile's snapshot, which validation needs, and compiles the maps under
input/maps, which SUSHI does not touch. The canonical URL is the guide's own and
is never rewritten for a server.

A PUT under a fixed id makes a second run safe: HAPI keeps an unchanged resource
as it is, version and all, and replaces one that changed. The examples and the
ImplementationGuide resource are not loaded; the study service needs neither.

After loading it checks two things the study service relies on:

- every value set drawn only from codes the guide itself defines expands to at
  least one code, so the forms' answer lists are not empty;
- no other resource in the store has one of the guide's canonical URLs, because
  the store finds a form's map by that URL and would pick one of the two.

    HAPI_FHIR_BASE_URL=https://.../fhir OIDC_TOKEN_URL=https://.../token \\
    OIDC_CLIENT_ID=... OIDC_CLIENT_SECRET=... \\
      python3 -I scripts/load-package.py output/package.tgz

It signs in with the OIDC client credentials grant and fetches a new token
before the old one expires. It exits 1 when the package holds nothing to load,
when any resource is refused, or when either check fails.

tests/run-on-hapi.py loads through the same functions, so there is one loader.
"""
import json
import os
import sys
import tarfile
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter

# A value set expands from code systems that must already be there, and a
# questionnaire names the map that extracts it, so the map goes first.
LOAD_ORDER = ("CodeSystem", "ValueSet", "ConceptMap", "StructureDefinition",
              "SearchParameter", "StructureMap", "Questionnaire")


class Package:
    """The resources in a built package, sorted into what is loaded and what is not."""

    def __init__(self, path):
        self.path = path
        self.canonical = None
        self.conformance, self.examples, self.skipped = [], [], Counter()
        with tarfile.open(path) as tf:
            for m in tf.getmembers():
                if m.name == "package/package.json":
                    self.canonical = json.load(tf.extractfile(m)).get("canonical")
                    continue
                if (not m.isfile() or not m.name.endswith(".json") or m.name.endswith("package.json")
                        or "/." in m.name or "/other/" in m.name or "/openapi/" in m.name):
                    continue
                r = json.load(tf.extractfile(m))
                if not isinstance(r, dict) or "resourceType" not in r or "id" not in r:
                    continue
                if "/example/" in m.name:
                    self.examples.append(r)
                elif r["resourceType"] in LOAD_ORDER:
                    self.conformance.append(r)
                else:
                    self.skipped[r["resourceType"]] += 1
        self.conformance.sort(key=lambda r: LOAD_ORDER.index(r["resourceType"]))


def issues(oo, levels=("error", "fatal")):
    """The (where, what) of each error in an OperationOutcome."""
    out = []
    for i in (oo or {}).get("issue", []):
        if i.get("severity") in levels:
            out.append(((i.get("expression") or i.get("location") or ["?"])[0],
                        (i.get("diagnostics") or i.get("details", {}).get("text") or "")[:220]))
    return out


def ok(status):
    return 200 <= status < 300


def load(call, resources, verbose=False):
    """PUTs each resource under its own id, in the order given.

    call(method, path, body) sends one request to the store and returns its
    HTTP status and parsed body. Returns (resource, status, body) per resource.
    """
    # A profile without a snapshot loads without complaint and then fails every
    # resource that claims it, since the store validates against the snapshot.
    bare = [r["id"] for r in resources
            if r["resourceType"] == "StructureDefinition" and not r.get("snapshot", {}).get("element")]
    if bare:
        raise SystemExit("These StructureDefinitions have no snapshot, so nothing was loaded: "
                         + ", ".join(bare) + ". Load the package the IG Publisher built, not fsh-generated/.")
    results = []
    for r in resources:
        s, body = call("PUT", f"/{r['resourceType']}/{r['id']}", r)
        results.append((r, s, body))
        if not ok(s):
            print("  LOAD FAIL", r["resourceType"], r["id"], s, issues(body)[:2] or body)
        elif verbose:
            print(f"  {r['resourceType']}/{r['id']}: HTTP {s}")
    return results


def expand(call, valueset, tries=12, pause=5):
    """Expands a value set by its URL, asking again while the store is still indexing its codes."""
    path = "/ValueSet/$expand?url=" + urllib.parse.quote(valueset["url"], safe="")
    for attempt in range(tries):
        s, body = call("GET", path)
        if s == 200 and body.get("expansion", {}).get("contains"):
            break
        if attempt < tries - 1:
            time.sleep(pause)
    return s, body


def codes(status, body):
    return len(body.get("expansion", {}).get("contains", [])) if status == 200 else 0


def guide_only(valueset, systems):
    """Whether every code in the value set is listed in it or comes from one of the guide's code systems."""
    include = valueset.get("compose", {}).get("include", [])
    return bool(include) and all(i.get("concept") or (i.get("system") in systems and not i.get("valueSet"))
                                 for i in include)


def rivals(call, resources):
    """Other resources in the store that carry one of these resources' canonical URLs."""
    found = []
    for r in resources:
        if not r.get("url"):
            continue
        s, bundle = call("GET", f"/{r['resourceType']}?_elements=url&url=" + urllib.parse.quote(r["url"], safe=""))
        if s != 200:
            found.append((r, f"the search for it failed with HTTP {s}"))
            continue
        for e in bundle.get("entry", []):
            other = e.get("resource", {})
            if other.get("resourceType") == r["resourceType"] and other.get("id") != r["id"]:
                found.append((r, f"also held as {other['resourceType']}/{other.get('id')}"))
    return found


class Client:
    """Talks to the store with a client credentials token it renews before the token expires."""

    def __init__(self, base, token_url, client_id, client_secret):
        self.base = base.rstrip("/")
        self.token_url, self.client_id, self.client_secret = token_url, client_id, client_secret
        self.token, self.expires_at = None, 0.0

    def sign_in(self):
        form = urllib.parse.urlencode({"grant_type": "client_credentials", "client_id": self.client_id,
                                       "client_secret": self.client_secret}).encode()
        req = urllib.request.Request(self.token_url, data=form, headers={"User-Agent": "healthy-route-ig-loader"})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                answer = json.load(r)
        except urllib.error.HTTPError as e:
            raise SystemExit(f"The token endpoint refused the client: HTTP {e.code} {e.read().decode('utf8', 'ignore')[:300]}")
        except urllib.error.URLError as e:
            raise SystemExit(f"Could not reach the token endpoint: {e.reason}")
        if not answer.get("access_token"):
            raise SystemExit("The token endpoint answered without an access token: "
                             + str(answer.get("error_description") or answer.get("error") or "no reason given"))
        lifetime = int(answer.get("expires_in") or 300)
        # Renew a minute early, or halfway through a token shorter than two minutes.
        self.token, self.expires_at = answer["access_token"], time.time() + max(lifetime - 60, lifetime / 2)

    def call(self, method, path, body=None):
        renewed = False
        for attempt in range(4):
            if self.token is None or time.time() >= self.expires_at:
                self.sign_in()
            req = urllib.request.Request(
                self.base + path, method=method, data=None if body is None else json.dumps(body).encode(),
                headers={"Authorization": "Bearer " + self.token, "Content-Type": "application/fhir+json",
                         "Accept": "application/fhir+json", "User-Agent": "healthy-route-ig-loader"})
            try:
                with urllib.request.urlopen(req, timeout=180) as r:
                    return r.status, parse(r.read())
            except urllib.error.HTTPError as e:
                text = e.read()
                if e.code == 401 and not renewed:
                    self.token, renewed = None, True
                    continue
                # Every request this client makes is a PUT or a GET, so sending it again is safe.
                if e.code in (502, 503, 504) and attempt < 3:
                    time.sleep(5 * (attempt + 1))
                    continue
                return e.code, parse(text)
            # OSError covers a refused connection, a reset and a read that timed out.
            except OSError as e:
                if attempt < 3:
                    time.sleep(5 * (attempt + 1))
                    continue
                raise SystemExit(f"Could not reach the FHIR store: {getattr(e, 'reason', e)}")
        raise SystemExit(f"The FHIR store kept refusing {method} {path}; gave up after four tries.")


def parse(raw):
    try:
        return json.loads(raw.decode("utf8")) if raw else {}
    except ValueError:
        return {"raw": raw.decode("utf8", "ignore")[:500]}


def main(argv):
    if len(argv) != 2:
        raise SystemExit("usage: python3 -I scripts/load-package.py output/package.tgz")
    # So a CI log shows each line as it happens and the closing error after them.
    sys.stdout.reconfigure(line_buffering=True)
    names = ("HAPI_FHIR_BASE_URL", "OIDC_TOKEN_URL", "OIDC_CLIENT_ID", "OIDC_CLIENT_SECRET")
    missing = [n for n in names if not os.environ.get(n)]
    if missing:
        raise SystemExit("Not set: " + ", ".join(missing) + ". The loader needs all four.")
    client = Client(*(os.environ[n] for n in names))

    pkg = Package(argv[1])
    if not pkg.conformance:
        raise SystemExit(f"{argv[1]} holds no conformance resources, so there is nothing to load.")
    print(f"Loading {len(pkg.conformance)} resources from {argv[1]} (canonical {pkg.canonical})")
    results = load(client.call, pkg.conformance, verbose=True)

    failed = [(r, s) for r, s, _ in results if not ok(s)]
    print(f"\nLoaded {len(results) - len(failed)} of {len(results)}:")
    for rtype in LOAD_ORDER:
        mine = [s for r, s, _ in results if r["resourceType"] == rtype]
        if mine:
            print(f"  {rtype:20} {sum(1 for s in mine if ok(s)):3}   new {mine.count(201)}, already there {mine.count(200)}")
    print("Not loaded: " + ", ".join([f"{len(pkg.examples)} examples"] + [f"{n} {t}" for t, n in sorted(pkg.skipped.items())]))
    if failed:
        raise SystemExit(f"{len(failed)} resources were refused; see LOAD FAIL above.")

    print("\nValue sets:")
    systems = {r["url"] for r in pkg.conformance if r["resourceType"] == "CodeSystem"}
    empty = []
    for vs in [r for r in pkg.conformance if r["resourceType"] == "ValueSet"]:
        needed = guide_only(vs, systems)
        # A store still indexing new codes catches up within the first value set's
        # wait. One that has not by then will not, so the rest are asked twice.
        s, body = expand(client.call, vs, tries=(2 if empty else 12) if needed else 1)
        n = codes(s, body)
        print(f"  {vs['id']:28} HTTP {s}  {n} codes" + ("" if n or needed else "  (draws on codes the store may not hold)"))
        if needed and not n:
            empty.append(vs["id"])

    print("\nOther resources with the guide's canonical URLs:")
    clashes = rivals(client.call, pkg.conformance)
    for r, other in clashes:
        print(f"  {r['resourceType']}/{r['id']} ({r['url']}): {other}")
    if not clashes:
        print("  none")

    problems = []
    if empty:
        problems.append(f"{len(empty)} value sets expand to no codes although the guide defines every code in them "
                        f"({', '.join(empty)}). The store's terminology index is likely empty; on HAPI, PUT each "
                        "CodeSystem back with a changed field, then each ValueSet, to index the codes again.")
    if clashes:
        problems.append(f"{len(clashes)} canonical URLs are not held by the loaded resource alone. The store "
                        "resolves a form's map and answer lists by URL, so delete the other copies listed above.")
    if problems:
        raise SystemExit("\n".join(problems))
    print("\nDone.")


if __name__ == "__main__":
    main(sys.argv)
