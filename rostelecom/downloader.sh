#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'ROSTELECOM-MNT' | grep -v 'route-set' | grep "/" > /tmp/rostelecom.txt || echo 'failed'

# Rostelecom absorbed regional operators that announce under their OWN maintainers, so
# the single ROSTELECOM-MNT query above misses them: AS28840 (Tattelecom), AS35807
# (SkyNet SPb), AS42610 (NCNet) — ~3M+ extra addresses.
for asn in AS28840 AS35807 AS42610; do
    get_routes "$asn" >> /tmp/rostelecom.txt || echo "failed: $asn"
done

# drop any default route an origin query might surface; a /0 would swallow the merged list.
grep -vE '^(0\.0\.0\.0|::)/0$' /tmp/rostelecom.txt > /tmp/rostelecom-clean.txt

# save ipv4
grep -v ':' /tmp/rostelecom-clean.txt > /tmp/rostelecom-ipv4.txt

# save ipv6
grep ':' /tmp/rostelecom-clean.txt > /tmp/rostelecom-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/rostelecom-ipv4.txt > rostelecom/ipv4.txt
sort -u /tmp/rostelecom-ipv6.txt > rostelecom/ipv6.txt
