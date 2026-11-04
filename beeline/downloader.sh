#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

#get_maintained_inetnum 'MNT-CLOUDMTS' > /tmp/beeline.txt || echo 'failed'
get_maintained_inetnum 'BEE-MNT' > /tmp/beeline.txt || echo 'failed'

# BEE-MNT alone covers very little of Beeline/VimpelCom. The core announces under these
# origins (its route objects are split across RU-CORBINA-MNT / AS3216-MNT / SOVINTEL-MNT
# maintainers, so a single-maintainer query misses most of it).
for asn in AS3216 AS16345; do
    get_routes "$asn" >> /tmp/beeline.txt || echo "failed: $asn"
done

# drop any default route an origin query might surface; a /0 would swallow the merged list.
grep -vE '^(0\.0\.0\.0|::)/0$' /tmp/beeline.txt > /tmp/beeline-clean.txt

# save ipv4
grep -v ':' /tmp/beeline-clean.txt > /tmp/beeline-ipv4.txt

# save ipv6
grep ':' /tmp/beeline-clean.txt > /tmp/beeline-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/beeline-ipv4.txt > beeline/ipv4.txt
sort -u /tmp/beeline-ipv6.txt > beeline/ipv6.txt
