#!/bin/bash

# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=tiktok&commit=Search
# https://github.com/SecOps-Institute/TwitterIPLists/blob/master/tiktok_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS138699' > /tmp/tiktok.txt || echo 'failed'

python utils/arin-org.py BYTED >> /tmp/tiktok.txt
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-tiktok.txt >> /tmp/tiktok.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-tiktok.txt >> /tmp/tiktok.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/tiktok.txt > /tmp/tiktok-ipv4.txt

# save ipv6
grep ':' /tmp/tiktok.txt > /tmp/tiktok-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/tiktok-ipv4.txt > tiktok/ipv4.txt
sort -u /tmp/tiktok-ipv6.txt > tiktok/ipv6.txt
