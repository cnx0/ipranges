#!/bin/bash

# https://www.hetzner.com/community/questions/19247/list-of-hetzners-ip-ranges

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS24940' > /tmp/hetzner.txt || echo 'failed'
# Hetzner Cloud announces from dedicated ASNs not registered under AS24940:
get_routes 'AS213230' >> /tmp/hetzner.txt || echo 'failed'
get_routes 'AS212317' >> /tmp/hetzner.txt || echo 'failed'
# IRR as-set as a safety net for ASNs not listed above
get_as_set 'AS-HETZNER' >> /tmp/hetzner.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/hetzner.txt > /tmp/hetzner-ipv4.txt

# save ipv6
grep ':' /tmp/hetzner.txt > /tmp/hetzner-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/hetzner-ipv4.txt > hetzner/ipv4.txt
sort -u /tmp/hetzner-ipv6.txt > hetzner/ipv6.txt
