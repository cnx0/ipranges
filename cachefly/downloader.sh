#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

#get_maintained_inetnum 'YAHOO-MNT' | grep "/" > /tmp/cachefly.txt || echo "failed"

python utils/arin-org.py CL-1923 >> /tmp/cachefly.txt

# save ipv4
grep -v ':' /tmp/cachefly.txt > /tmp/cachefly-ipv4.txt || echo "failed"
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/cachefly-ipv4.txt > cachefly/ipv4.txt || echo "failed"

# save ipv6
grep ':' /tmp/cachefly.txt > /tmp/cachefly-ipv6.txt || echo "failed"
sort -u /tmp/cachefly-ipv6.txt > cachefly/ipv6.txt || echo "failed"
