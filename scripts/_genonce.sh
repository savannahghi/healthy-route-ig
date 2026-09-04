#!/usr/bin/env bash
set -euo pipefail

[ -f publisher.jar ] || bash scripts/_updatePublisher.sh

# preferIPv4Stack is not a performance setting. The publisher refuses to fetch
# from an address it does not recognise as public, and on a network that hands
# back a NAT64-translated address for tx.fhir.org it rejects its own terminology
# server before reading any of the guide. The failure appears as
# "Refusing to fetch from non-public address 64:ff9b::..." during initialisation,
# which reads as a content error and is not one.
java -Xmx4g -Djava.net.preferIPv4Stack=true -jar publisher.jar publisher -ig . "$@"
