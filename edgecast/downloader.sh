#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS14153' > /tmp/edgecast.txt || echo 'failed'
get_routes 'AS15133' >> /tmp/edgecast.txt || echo 'failed'
get_routes 'AS14210' >> /tmp/edgecast.txt || echo 'failed'
python utils/arin-org.py OH-207 >> /tmp/edgecast.txt
python utils/arin-org.py EDGEC-25 >> /tmp/edgecast.txt

# save ipv4
grep -v ':' /tmp/edgecast.txt > /tmp/edgecast-ipv4.txt

# save ipv6
grep ':' /tmp/edgecast.txt > /tmp/edgecast-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/edgecast-ipv4.txt > edgecast/ipv4.txt
sort -u /tmp/edgecast-ipv6.txt > edgecast/ipv6.txt
