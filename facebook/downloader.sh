#!/bin/bash

# https://www.workplace.com/resources/tech/it-configuration/domain-whitelisting
# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=facebook&commit=Search
# https://github.com/SecOps-Institute/FacebookIPLists/blob/master/facebook_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS32934' > /tmp/facebook.txt || echo 'failed'
get_routes 'AS54115' >> /tmp/facebook.txt || echo 'failed'
get_routes 'AS63293' >> /tmp/facebook.txt || echo 'failed'
get_routes 'AS149642' >> /tmp/facebook.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-facebook.txt >> /tmp/facebook.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-facebook.txt >> /tmp/facebook.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/facebook.txt | rg '[0-9]+' > /tmp/facebook-ipv4.txt

# save ipv6
grep ':' /tmp/facebook.txt |rg '[0-9]+' > /tmp/facebook-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/facebook-ipv4.txt > facebook/ipv4.txt
sort -u /tmp/facebook-ipv6.txt > facebook/ipv6.txt
