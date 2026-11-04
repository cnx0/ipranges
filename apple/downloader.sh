#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained_inetnum 'APPLE-MNT' | grep "/" > /tmp/apple.txt || echo "failed"
python utils/arin-org.py APPLEC-1-Z >> /tmp/apple.txt
# IRR as-set as a safety net for announcements not covered above
get_as_set 'AS-APPLE' >> /tmp/apple.txt || echo 'failed'

# APPLEC-1-Z + APPLE-MNT give Apple's v4 (incl. 17.0.0.0/8) but no IPv6; Apple's
# announced IPv6 (~hundreds of route6 prefixes) lives on its origin ASNs.
get_routes 'AS714' >> /tmp/apple.txt || echo "failed"
get_routes 'AS6185' >> /tmp/apple.txt || echo "failed"

# drop any default route an origin query might surface; apple/ipv6 is first-populated
# here, so CI's sanity floor has no prior baseline to catch a stray /0.
grep -vE '^(0\.0\.0\.0|::)/0$' /tmp/apple.txt > /tmp/apple-clean.txt || echo "failed"

# save ipv4
grep -v ':' /tmp/apple-clean.txt > /tmp/apple-ipv4.txt || echo "failed"
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/apple-ipv4.txt > apple/ipv4.txt || echo "failed"

# save ipv6
grep ':' /tmp/apple-clean.txt > /tmp/apple-ipv6.txt || echo "failed"
sort -u /tmp/apple-ipv6.txt > apple/ipv6.txt || echo "failed"
