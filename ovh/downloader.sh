#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

# OVH SAS owns exactly two announced ASNs (verified against RIPE org ORG-OS3-RIPE):
# AS16276 carries OVH's main global + North American space, AS35540 (OVH-TELECOM) adds
# two extra /16s. (The previous MNT-TELEGRAM maintainer line here was a copy-paste bug.)
get_routes 'AS16276' > /tmp/ovh.txt || echo 'failed'
get_routes 'AS35540' >> /tmp/ovh.txt || echo 'failed'
# IRR as-set as a safety net for ASNs not listed above
get_as_set 'AS-OVH' >> /tmp/ovh.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/ovh.txt > /tmp/ovh-ipv4.txt

# save ipv6
grep ':' /tmp/ovh.txt > /tmp/ovh-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/ovh-ipv4.txt > ovh/ipv4.txt
sort -u /tmp/ovh-ipv6.txt > ovh/ipv6.txt
