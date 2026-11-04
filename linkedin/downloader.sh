#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

# LinkedIn is a Microsoft subsidiary but announces its own ASNs and address space,
# distinct from the microsoft/ list. Only these three are actually routed; LinkedIn's
# other registered ASNs (AS20049, AS20366, LYNDA-COM, ...) announce nothing today.
get_routes 'AS14413' > /tmp/linkedin.txt || echo 'failed'   # largest (108.174.0.0/20, 144.2.x)
get_routes 'AS13443' >> /tmp/linkedin.txt || echo 'failed'  # main LinkedIn block
get_routes 'AS40793' >> /tmp/linkedin.txt || echo 'failed'  # 108.174.5-7.0/24

# save ipv4
grep -v ':' /tmp/linkedin.txt > /tmp/linkedin-ipv4.txt

# save ipv6
grep ':' /tmp/linkedin.txt > /tmp/linkedin-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/linkedin-ipv4.txt > linkedin/ipv4.txt
sort -u /tmp/linkedin-ipv6.txt > linkedin/ipv6.txt
