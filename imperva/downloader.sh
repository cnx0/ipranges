#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS19551' > /tmp/imperva.txt || echo 'failed'
get_routes 'AS62571' >> /tmp/imperva.txt || echo 'failed'

# Imperva/Incapsula's official public egress feed (the addresses Incapsula connects to
# customer origins from). No auth required; documented POST endpoint.
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors -X POST https://my.incapsula.com/api/integration/v1/ips | jq -r '.ipRanges[], .ipv6Ranges[]' >> /tmp/imperva.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/imperva.txt > /tmp/imperva-ipv4.txt

# save ipv6
grep ':' /tmp/imperva.txt > /tmp/imperva-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/imperva-ipv4.txt > imperva/ipv4.txt
sort -u /tmp/imperva-ipv6.txt > imperva/ipv6.txt
