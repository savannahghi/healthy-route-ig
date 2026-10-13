"""Runs the forms through a real FHIR store, which the offline replay cannot stand in for.

tests/run-maps.sh replays the maps with the validator's engine, which works on an
untyped element model. The FHIR store runs the same maps on HAPI's typed model,
where a stored response's id reads QuestionnaireResponse/<id>/_history/<n> and a
resource id only accepts an id value. Both broke the maps once and neither showed
offline. So this script loads a built package into a HAPI R5 server that carries
the SIL $extract provider, expands every value set, and for every example
response: stores it, validates it against its Questionnaire, runs $extract on the
server, commits the Bundle, saves it again to prove a re-save reuses the ids, and
validates every committed resource against the profile it declares.

The conformance resources go in through scripts/load-package.py, the loader the
deployment workflow runs, so a store this script passes on is loaded the way a
deployed one is.

It writes to the server it is pointed at: conformance resources, the guide's
examples and the extracted resources. Point it at a local stack or a store kept
for testing, never one holding real records.

    FHIR_BASE=http://localhost:8190/fhir TOKEN_URL=... CLIENT_ID=... USERNAME=... PASSWORD=... \
      python3 tests/run-on-hapi.py output/package.tgz

The hapi-fhir-interceptors repository's docker compose stack is a ready server:
it listens on 8190 and its Keycloak realm issues tokens on 8181.
"""
import glob, importlib.util, json, os, sys, time, urllib.parse, urllib.request, urllib.error

_spec = importlib.util.spec_from_file_location(
    "load_package", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts", "load-package.py"))
loader = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(loader)
issues = loader.issues

BASE = os.environ.get("FHIR_BASE", "http://localhost:8190/fhir")
PKG = sys.argv[1]
IGURL = "https://fhir.optimalhealth.org/ig/healthy-route"

def token():
    fields = {"client_id": os.environ.get("CLIENT_ID", "fhir-test-client")}
    if os.environ.get("CLIENT_SECRET"):
        fields.update(grant_type="client_credentials", client_secret=os.environ["CLIENT_SECRET"])
    else:
        fields.update(grant_type="password", username=os.environ.get("USERNAME", "testuser"), password=os.environ.get("PASSWORD", "password"))
    url = os.environ.get("TOKEN_URL", "http://localhost:8181/realms/fhir/protocol/openid-connect/token")
    with urllib.request.urlopen(url, urllib.parse.urlencode(fields).encode(), timeout=30) as r:
        return json.load(r)["access_token"]

TOK = None
def call(method, path, body=None, ok=(200, 201)):
    global TOK
    for attempt in range(2):
        req = urllib.request.Request(BASE + path, method=method, data=None if body is None else json.dumps(body).encode(),
                                     headers={"Authorization": "Bearer " + TOK, "Content-Type": "application/fhir+json", "Accept": "application/fhir+json"})
        try:
            with urllib.request.urlopen(req, timeout=180) as r:
                return r.status, json.load(r)
        except urllib.error.HTTPError as e:
            text = e.read().decode("utf8", "ignore")
            if e.code == 401 and attempt == 0:
                TOK = token(); continue
            try: return e.code, json.loads(text)
            except Exception: return e.code, {"raw": text[:500]}

# terminology noise: code systems this local server does not hold
NOISE = ("loinc.org", "id.who.int/icd", "unitsofmeasure", "hr-medicine", "terminology.hl7.org/CodeSystem/v2-0487", "v2-0074",
         "dicom.nema.org", "could not be validated", "Unknown code system", "not found and could not", "A definition for CodeSystem",
         "None of the codings provided are in the value set", "unable to find", "Unable to provide support for code system")

FILTERED = []
def real(errs):
    kept = [e for e in errs if not any(n.lower() in e[1].lower() for n in NOISE)]
    FILTERED.extend(e for e in errs if e not in kept)
    return kept

# --- wait for the server -----------------------------------------------------
for _ in range(60):
    try:
        TOK = token(); break
    except Exception:
        time.sleep(5)
for _ in range(90):
    try:
        s, _ = call("GET", "/metadata")
        if s == 200: break
    except Exception: pass
    time.sleep(5)
else:
    sys.exit("HAPI did not come up")
print("HAPI is up")

# --- load the package ---------------------------------------------------------
pkg = loader.Package(PKG)
conf, examples = pkg.conformance, pkg.examples
failed = sum(1 for _, s, _ in loader.load(call, conf) if not loader.ok(s))
print(f"loaded {len(conf) - failed}/{len(conf)} conformance resources")

# maps compiled from a working tree, loaded over the package's copies
if len(sys.argv) > 2:
    for f in sorted(glob.glob(os.path.join(sys.argv[2], "*.json"))):
        m = json.load(open(f)); m["id"] = m.get("id") or os.path.basename(f)[:-5]
        s, body = call("PUT", f"/StructureMap/{m['id']}", m)
        print(f"  map {m['id']} from {sys.argv[2]}: HTTP {s}", "" if s in (200, 201) else issues(body)[:2])

qrs = [r for r in examples if r["resourceType"] == "QuestionnaireResponse"]
others = [r for r in examples if r["resourceType"] != "QuestionnaireResponse"]
bundle = {"resourceType": "Bundle", "type": "transaction", "entry": [
    {"fullUrl": f"{r['resourceType']}/{r['id']}", "resource": r, "request": {"method": "PUT", "url": f"{r['resourceType']}/{r['id']}"}} for r in others]}
s, body = call("POST", "", bundle)
print(f"loaded the guide's {len(others)} example instances: HTTP {s}", "" if s == 200 else issues(body)[:3])

# --- value sets ------------------------------------------------------------------
print("\n== value set expansion ==")
time.sleep(10)
for r in sorted([c for c in conf if c["resourceType"] == "ValueSet"], key=lambda r: r["id"]):
    s, body = loader.expand(call, r)
    n = len(body.get("expansion", {}).get("contains", [])) if s == 200 else None
    shown = ", ".join(c.get("display") or c["code"] for c in body.get("expansion", {}).get("contains", [])[:4]) if s == 200 else issues(body)[:1]
    print(f"  {r['id']:28} HTTP {s}  {n} codes  {shown}")

# --- the forms ------------------------------------------------------------------------
print("\n== forms: validate, extract, commit, re-save, validate the results ==")
summary = []
for qr in sorted(qrs, key=lambda r: r["id"]):
    qid = qr["id"]; row = {"qr": qid}
    s, body = call("PUT", f"/QuestionnaireResponse/{qid}", qr)
    row["store"] = s
    s, body = call("POST", "/QuestionnaireResponse/$validate", qr)
    row["qr_errors"] = real(issues(body))
    s, ext = call("GET", f"/QuestionnaireResponse/{qid}/$extract")
    if s != 200 or ext.get("resourceType") != "Bundle":
        row["extract"] = f"HTTP {s}: {issues(ext)[:2] or ext}"; summary.append(row); continue
    row["entries"] = len(ext.get("entry", []))
    s, resp = call("POST", "", ext)
    row["commit"] = s
    if s != 200:
        row["commit_errors"] = issues(resp)[:3]; summary.append(row); continue
    locs = [e["response"]["location"].split("/_history")[0] for e in resp.get("entry", [])]
    # a second save of the same response
    s2, ext2 = call("GET", f"/QuestionnaireResponse/{qid}/$extract")
    s3, resp2 = call("POST", "", ext2)
    locs2 = [e["response"]["location"].split("/_history")[0] for e in resp2.get("entry", [])]
    derived = lambda ls: sorted(l for l in ls if l.split("/")[1].startswith(qid))
    row["resave_same_ids"] = derived(locs) == derived(locs2) and len(derived(locs)) > 0
    row["fresh_ids"] = len(locs2) - len(derived(locs2))
    errs = []
    for loc in locs:
        s, res = call("GET", "/" + loc)
        prof = (res.get("meta", {}).get("profile") or [None])[0]
        q = "?profile=" + urllib.parse.quote(prof, safe="") if prof else ""
        s, oo = call("POST", f"/{res['resourceType']}/$validate{q}", res)
        for e in real(issues(oo)):
            errs.append((loc, e))
    row["resource_errors"] = errs
    summary.append(row)

for row in summary:
    print(f"\n{row['qr']}: stored HTTP {row.get('store')}, extract {row.get('extract', 'ok')}, {row.get('entries', '-')} entries, commit HTTP {row.get('commit', '-')}, re-save reuses ids: {row.get('resave_same_ids', '-')}, fresh ids on re-save: {row.get('fresh_ids', '-')}")
    for e in row.get("qr_errors", []): print("   response vs Questionnaire:", e)
    for e in row.get("commit_errors", []): print("   commit:", e)
    for loc, e in row.get("resource_errors", []): print("   ", loc, "->", e)
from collections import Counter
print("\nterminology messages set aside (code systems this server does not hold):")
for (msg, n) in Counter(e[1][:150] for e in FILTERED).most_common(12): print(f"  {n:3}x {msg}")
failures = sum(1 for r in summary if r.get("extract") or r.get("commit") != 200 or r.get("qr_errors") or r.get("resource_errors") or not r.get("resave_same_ids"))
print(f"\n{len(summary) - failures}/{len(summary)} forms clean")
sys.exit(1 if failures else 0)
