#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

#python utils/arin-org.py ZEITI >> /tmp/constant.txt
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://geofeed.constant.com/ | cut -d',' -f1 > /tmp/constant.txt

# save ipv4
grep -v ':' /tmp/constant.txt > /tmp/constant-ipv4.txt

# save ipv6
grep ':' /tmp/constant.txt > /tmp/constant-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/constant-ipv4.txt > constant/ipv4.txt
sort -u /tmp/constant-ipv6.txt > constant/ipv6.txt
