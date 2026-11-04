#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained_inetnum 'YAHOO-MNT' | grep "/" > /tmp/yahoo.txt || echo "failed"

# YAHOO-MNT is RIPE-only (EMEA). Yahoo's main US footprint announces under ARIN ASNs:
for asn in AS10310 AS26101 AS36646; do
    get_routes "$asn" >> /tmp/yahoo.txt || echo "failed: $asn"
done

# save ipv4
grep -v ':' /tmp/yahoo.txt > /tmp/yahoo-ipv4.txt || echo "failed"
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/yahoo-ipv4.txt > yahoo/ipv4.txt || echo "failed"

# save ipv6
grep ':' /tmp/yahoo.txt > /tmp/yahoo-ipv6.txt || echo "failed"
sort -u /tmp/yahoo-ipv6.txt > yahoo/ipv6.txt || echo "failed"
