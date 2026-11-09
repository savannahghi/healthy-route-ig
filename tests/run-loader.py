"""Checks the loader against a store that keeps tags the way HAPI does.

HAPI keeps a resource's tags when the resource is replaced, so the loader has to
delete a tag the guide drops. Each case loads one resource into a store that
already holds it, and says which tags the store must hold afterwards and whether
the load must succeed.

    python3 -I tests/run-loader.py
"""
import copy
import importlib.util
import os
import sys

_spec = importlib.util.spec_from_file_location(
    "load_package", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts", "load-package.py"))
loader = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(loader)

STUDY = "https://fhir.optimalhealth.org/sid/optimalhealth-study"
SIGNOFF = "https://fhir.optimalhealth.org/ig/healthy-route/CodeSystem/hr-signoff"
OTHER = "http://example.org/someone-else"


def tag(system, code):
    return {"system": system, "code": code}


def form(*tags):
    r = {"resourceType": "Questionnaire", "id": "hr-diet-activity-ug", "status": "draft"}
    if tags:
        r["meta"] = {"tag": list(tags)}
    return r


class Store:
    """One resource, held the way HAPI holds it: a PUT replaces the content and adds tags, never removes them."""

    def __init__(self, held, refuse=(), minimal=False):
        self.held, self.refuse, self.minimal, self.sent = copy.deepcopy(held), refuse, minimal, []

    def call(self, method, path, body=None):
        self.sent.append(method)
        if method in self.refuse:
            return 422, {"resourceType": "OperationOutcome", "issue": [{"severity": "error", "diagnostics": "refused"}]}
        if method == "PUT":
            tags = (self.held or {}).get("meta", {}).get("tag", [])
            new = copy.deepcopy(body)
            for t in tags:
                if (t["system"], t["code"]) not in {(n["system"], n["code"]) for n in new.get("meta", {}).get("tag", [])}:
                    new.setdefault("meta", {}).setdefault("tag", []).append(t)
            self.held = new
            return 200, ({} if self.minimal else copy.deepcopy(new))
        if method == "GET":
            return 200, copy.deepcopy(self.held)
        if method == "POST" and path.endswith("/$meta-delete"):
            gone = {(t["system"], t["code"]) for t in body["parameter"][0]["valueMeta"]["tag"]}
            meta = self.held.get("meta", {})
            meta["tag"] = [t for t in meta.get("tag", []) if (t["system"], t["code"]) not in gone]
            return 200, {"resourceType": "Parameters"}
        return 404, {}

    def tags(self):
        return sorted((t["system"], t["code"]) for t in (self.held or {}).get("meta", {}).get("tag", []))


# Every case's package also holds a form that uses both of the guide's tag
# systems, as the real package does, so the loader knows them.
OTHER_FORM = {"resourceType": "Questionnaire", "id": "hr-medications-ug",
              "meta": {"tag": [tag(STUDY, "HR-UG"), tag(SIGNOFF, "optional")]}}

CASES = [
    {"name": "happy case: a retired form loses the study and sign-off tags the guide dropped",
     "held": form(tag(STUDY, "HR-UG"), tag(SIGNOFF, "optional")), "load": form(),
     "want": [], "ok": True},
    {"name": "happy case: a form keeps the tags the guide still gives it",
     "held": form(tag(STUDY, "HR-UG"), tag(SIGNOFF, "optional")),
     "load": form(tag(STUDY, "HR-UG"), tag(SIGNOFF, "optional")),
     "want": [(SIGNOFF, "optional"), (STUDY, "HR-UG")], "ok": True},
    {"name": "happy case: a form no longer optional loses only that tag",
     "held": form(tag(STUDY, "HR-UG"), tag(SIGNOFF, "optional")), "load": form(tag(STUDY, "HR-UG")),
     "want": [(STUDY, "HR-UG")], "ok": True},
    {"name": "happy case: a tag in another system stays",
     "held": form(tag(STUDY, "HR-UG"), tag(OTHER, "kept")), "load": form(),
     "want": [(OTHER, "kept")], "ok": True},
    {"name": "happy case: a tag under the guide's domain goes even when no resource uses its system",
     "held": form(tag("https://fhir.optimalhealth.org/sid/retired-system", "x")), "load": form(),
     "want": [], "ok": True},
    {"name": "happy case: a store that answers a PUT without the resource is read back",
     "held": form(tag(STUDY, "HR-UG")), "load": form(), "minimal": True,
     "want": [], "ok": True},
    {"name": "happy case: a resource with no tags needs no further call",
     "held": form(), "load": form(), "want": [], "ok": True, "sent": ["PUT"]},
    {"name": "sad case: a store refusing $meta-delete fails the load",
     "held": form(tag(STUDY, "HR-UG")), "load": form(), "refuse": ("POST",),
     "want": [(STUDY, "HR-UG")], "ok": False},
    {"name": "sad case: a refused PUT is not followed by $meta-delete",
     "held": form(tag(STUDY, "HR-UG")), "load": form(), "refuse": ("PUT",),
     "want": [(STUDY, "HR-UG")], "ok": False, "sent": ["PUT"]},
]


def main():
    failed = 0
    for c in CASES:
        store = Store(c["held"], refuse=c.get("refuse", ()), minimal=c.get("minimal", False))
        other = Store(OTHER_FORM)

        def call(method, path, body=None):
            return (other if "hr-medications-ug" in path else store).call(method, path, body)

        results = loader.load(call, [c["load"], OTHER_FORM])
        loaded = loader.ok(results[0][1])
        wrong = []
        if store.tags() != sorted(c["want"]):
            wrong.append(f"tags {store.tags()}, want {sorted(c['want'])}")
        if loaded != c["ok"]:
            wrong.append(f"load ok {loaded}, want {c['ok']}")
        if "sent" in c and store.sent != c["sent"]:
            wrong.append(f"sent {store.sent}, want {c['sent']}")
        if wrong:
            failed += 1
            print(f"FAIL {c['name']}: " + "; ".join(wrong))
        else:
            print(f"ok   {c['name']}")
    print(f"{len(CASES) - failed} of {len(CASES)} cases pass")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
