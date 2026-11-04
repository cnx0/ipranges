#!/bin/bash

# https://www.workplace.com/resources/tech/it-configuration/domain-whitelisting
# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=facebook&commit=Search
# https://github.com/SecOps-Institute/FacebookIPLists/blob/master/facebook_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'MELBICOM-MNT' > /tmp/kinopub.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/kinopub.txt > /tmp/kinopub-ipv4.txt

# save ipv6
grep ':' /tmp/kinopub.txt > /tmp/kinopub-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/kinopub-ipv4.txt > kinopub/ipv4.txt
sort -u /tmp/kinopub-ipv6.txt > kinopub/ipv6.txt
