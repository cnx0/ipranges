#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained_inetnum 'MNT-AVITO' > /tmp/avito.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/avito.txt > /tmp/avito-ipv4.txt

# save ipv6
grep ':' /tmp/avito.txt > /tmp/avito-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/avito-ipv4.txt > avito/ipv4.txt
sort -u /tmp/avito-ipv6.txt > avito/ipv6.txt
