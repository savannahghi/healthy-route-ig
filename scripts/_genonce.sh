#!/usr/bin/env bash
set -euo pipefail
[ -f publisher.jar ] || bash scripts/_updatePublisher.sh
java -Xmx4g -jar publisher.jar publisher -ig . "$@"
