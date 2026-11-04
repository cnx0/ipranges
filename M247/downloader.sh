#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS9009' > /tmp/M247.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/M247.txt > /tmp/M247-ipv4.txt

# save ipv6
grep ':' /tmp/M247.txt > /tmp/M247-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/M247-ipv4.txt > M247/ipv4.txt
sort -u /tmp/M247-ipv6.txt > M247/ipv6.txt
