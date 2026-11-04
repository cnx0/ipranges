#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'RAMBLER-MNT' > /tmp/rambler.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/rambler.txt > /tmp/rambler-ipv4.txt

# save ipv6
grep ':' /tmp/rambler.txt > /tmp/rambler-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/rambler-ipv4.txt > rambler/ipv4.txt
sort -u /tmp/rambler-ipv6.txt > rambler/ipv6.txt
