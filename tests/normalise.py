"""Prints a transform's Bundle in a stable form for comparison.

The maps give every resource an id derived from the response, so the only
thing that varies between runs is a fresh uuid for a medicine the catalogue
does not list. Those are masked; everything else is compared as written.
"""
import json
import re
import sys

UUID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}")

text = open(sys.argv[1], encoding="utf8").read()
bundle = json.loads(UUID.sub("<uuid>", text))
bundle.get("entry", []).sort(key=lambda e: (e.get("resource", {}).get("resourceType", ""), e.get("fullUrl", "")))
print(json.dumps(bundle, indent=2, sort_keys=True))
