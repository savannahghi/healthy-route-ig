#!/usr/bin/env bash
#
# Replays every example response through its map with the same R5 engine the
# study's FHIR store runs, and compares the Bundle with the one checked in.
#
# The maps are read from input/maps and nothing else. Loading the built package as
# well would let a stale compiled copy of a map, under the same url, win over the
# source being tested.
#
# A map is only as good as the Bundle it produces, and the publisher checks
# nothing beyond the map's syntax. So each form has an example response under
# input/examples and the Bundle it must produce under tests/expected, and this
# script fails when they differ. Change a map, regenerate the Bundle, read the
# diff, commit both.
#
# Usage: tests/run-maps.sh [--update]   (--update rewrites tests/expected)
#
set -euo pipefail
cd "$(dirname "$0")/.."

VALIDATOR=${VALIDATOR:-input-cache/validator_cli.jar}
TX=${TX:-https://tx.fhir.org/r5}
UPDATE=${1:-}

[ -f "$VALIDATOR" ] || curl -sSL -o "$VALIDATOR" https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar

mkdir -p tests/actual
failed=0

for example in input/examples/QuestionnaireResponse-*.json; do
  name=$(basename "$example" .json); name=${name#QuestionnaireResponse-}
  form=$(python3 -c "import json,sys; q=json.load(open(sys.argv[1]))['questionnaire']; print(q.rsplit('/',1)[1].split('|')[0])" "$example")
  stem=${form#hr-}; stem=${stem%-ug}; stem=${stem%-gh}
  mapname=HRExtract$(python3 -c "import sys; print(''.join(w.capitalize() for w in sys.argv[1].split('-')))" "$stem")
  url="https://fhir.optimalhealth.org/ig/healthy-route/StructureMap/$mapname"
  actual="tests/actual/$name.json"

  java -Djava.net.preferIPv4Stack=true -jar "$VALIDATOR" transform "$url" -version 5.0 -tx "$TX" -ssrf-protection-enabled=false \
    -ig "input/maps/hr-extract-$stem.fml" -output "$actual" "$example" > "tests/actual/$name.log" 2>&1 \
    || { echo "FAIL $name: the transform did not run"; grep -v '^\s*at ' "tests/actual/$name.log" | grep -i -E 'error|exception' | head -5; failed=1; continue; }

  if [ "$UPDATE" = "--update" ]; then
    python3 tests/normalise.py "$actual" > "tests/expected/$name.json"
    echo "updated $name"
  elif python3 tests/normalise.py "$actual" | diff -u "tests/expected/$name.json" - > "tests/actual/$name.diff"; then
    echo "ok   $name"
  else
    echo "FAIL $name: the Bundle differs from tests/expected/$name.json"; head -40 "tests/actual/$name.diff"; failed=1
  fi
done

exit $failed
