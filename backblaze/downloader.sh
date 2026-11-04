#!/bin/bash

# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=backblaze&commit=Search
# https://github.com/SecOps-Institute/TwitterIPLists/blob/master/backblaze_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS40401' > /tmp/backblaze.txt || echo 'failed'

python utils/arin-org.py BACKB-7 >> /tmp/backblaze.txt

curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-backblaze.txt >> /tmp/backblaze.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-backblaze.txt >> /tmp/backblaze.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/backblaze.txt > /tmp/backblaze-ipv4.txt

# save ipv6
grep ':' /tmp/backblaze.txt > /tmp/backblaze-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/backblaze-ipv4.txt > backblaze/ipv4.txt
sort -u /tmp/backblaze-ipv6.txt > backblaze/ipv6.txt
