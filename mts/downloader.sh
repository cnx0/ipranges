#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

#get_maintained_inetnum 'MNT-CLOUDMTS' > /tmp/mts.txt || echo 'failed'
get_maintained_inetnum 'MTU-NOC' > /tmp/mts.txt || echo 'failed'
sleep 10
get_maintained_inetnum 'MGTS-MNT' >> /tmp/mts.txt || echo 'failed'
sleep 10
get_maintained_inetnum 'MGTS-USPD-MNT' >> /tmp/mts.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/mts.txt > /tmp/mts-ipv4.txt

# save ipv6
grep ':' /tmp/mts.txt > /tmp/mts-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/mts-ipv4.txt > mts/ipv4.txt
sort -u /tmp/mts-ipv6.txt > mts/ipv6.txt
