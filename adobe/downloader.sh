#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS15224' > /tmp/adobe.txt || echo 'failed'
get_routes 'ADOBES-Z' >> /tmp/adobe.txt || echo 'failed'

python utils/arin-org.py AS >> /tmp/adobe.txt

curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-adobe.txt >> /tmp/adobe.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-adobe.txt >> /tmp/adobe.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/adobe.txt > /tmp/adobe-ipv4.txt

# save ipv6
grep ':' /tmp/adobe.txt > /tmp/adobe-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/adobe-ipv4.txt > adobe/ipv4.txt
sort -u /tmp/adobe-ipv6.txt > adobe/ipv6.txt
