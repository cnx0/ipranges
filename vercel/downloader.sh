#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

python utils/arin-org.py ZEITI >> /tmp/vercel.txt
#curl -s https://api.vercel.com/public-ip-list| jq -r '.addresses[], .ipv6_addresses[]' >> /tmp/vercel.txt

# save ipv4
grep -v ':' /tmp/vercel.txt > /tmp/vercel-ipv4.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/vercel-ipv4.txt > vercel/ipv4.txt
