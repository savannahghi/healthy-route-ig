#!/usr/bin/env bash
#
# Downloads a pinned release of the HL7 FHIR IG Publisher.
#
# The publisher version and the template version in ig.ini are pinned together.
# Pinning one and floating the other allows them to drift until the template
# requests a page fragment that the publisher does not generate, which surfaces
# as a Jekyll "could not locate the included file" failure after validation has
# already succeeded.
#
set -euo pipefail

VERSION="${IG_PUBLISHER_VERSION:-2.3.4}"
JAR="publisher.jar"
PART="${JAR}.part"
URL="https://github.com/HL7/fhir-ig-publisher/releases/download/${VERSION}/publisher.jar"

# An interrupted download leaves a file that exists but is unusable. Testing the
# archive rather than testing for the file's presence prevents a single network
# failure from leaving a permanently unusable working copy.
if [ -f "$JAR" ] && unzip -qt "$JAR" >/dev/null 2>&1; then
  echo "publisher.jar is present and valid. Remove it to force a re-download."
  exit 0
fi

if [ -f "$JAR" ]; then
  echo "publisher.jar failed its integrity check; replacing it."
  rm -f "$JAR"
fi

echo "Downloading IG Publisher ${VERSION} (approximately 230 MB)."
curl --fail --location \
     --retry 5 --retry-delay 5 --retry-all-errors \
     --continue-at - \
     --output "$PART" "$URL"

if ! unzip -qt "$PART" >/dev/null 2>&1; then
  echo "The downloaded file failed its integrity check." >&2
  rm -f "$PART"
  exit 1
fi

mv "$PART" "$JAR"
echo "IG Publisher ${VERSION} ready."
