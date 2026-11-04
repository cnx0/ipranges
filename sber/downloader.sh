#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'SBRF-mnt' > /tmp/sber.txt || echo 'failed'
get_maintained 'PVBSBRF-MNT-RIPE' >> /tmp/sber.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/sber.txt > /tmp/sber-ipv4.txt

# save ipv6
grep ':' /tmp/sber.txt > /tmp/sber-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/sber-ipv4.txt > sber/ipv4.txt
sort -u /tmp/sber-ipv6.txt > sber/ipv6.txt
