#!/bin/bash

# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=twitter&commit=Search
# https://github.com/SecOps-Institute/TwitterIPLists/blob/master/twitter_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS13414' > /tmp/twitter.txt || echo 'failed'
get_routes 'AS35995' >> /tmp/twitter.txt || echo 'failed'
get_routes 'AS54888' >> /tmp/twitter.txt || echo 'failed'
get_routes 'AS63179' >> /tmp/twitter.txt || echo 'failed'

python utils/arin-org.py TWITT >> /tmp/twitter.txt
# IRR as-set as a safety net for announcements not covered above
get_as_set 'AS-TWITTER' >> /tmp/twitter.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/twitter.txt > /tmp/twitter-ipv4.txt

# save ipv6
grep ':' /tmp/twitter.txt > /tmp/twitter-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/twitter-ipv4.txt > twitter/ipv4.txt
sort -u /tmp/twitter-ipv6.txt > twitter/ipv6.txt
