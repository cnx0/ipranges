#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

python utils/arin-org.py SKYCA-3 >> /tmp/fastly.txt
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://api.fastly.com/public-ip-list| jq -r '.addresses[], .ipv6_addresses[]' >> /tmp/fastly.txt

# save ipv4
grep -v ':' /tmp/fastly.txt > /tmp/fastly-ipv4.txt

# save ipv6
grep ':' /tmp/fastly.txt > /tmp/fastly-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/fastly-ipv4.txt > fastly/ipv4.txt
sort -u /tmp/fastly-ipv6.txt > fastly/ipv6.txt
