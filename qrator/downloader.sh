#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'MNT-QRATOR' | grep -v 'route-set' | grep "/" > /tmp/qrator.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/qrator.txt > /tmp/qrator-ipv4.txt

# save ipv6
grep ':' /tmp/qrator.txt > /tmp/qrator-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/qrator-ipv4.txt > qrator/ipv4.txt
sort -u /tmp/qrator-ipv6.txt > qrator/ipv6.txt
