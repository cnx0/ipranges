#!/bin/bash

# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=nordvpn&commit=Search
# https://github.com/SecOps-Institute/TwitterIPLists/blob/master/nordvpn_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS136787' > /tmp/nordvpn.txt || echo 'failed'

curl -fsS --retry 3 --retry-delay 5 --retry-all-errors "https://api.nordvpn.com/v1/servers?limit=16383"| jq .[].ips[].ip.ip|tr -d '"'| sort -u >>/tmp/nordvpn.txt

# save ipv4
grep -v ':' /tmp/nordvpn.txt > /tmp/nordvpn-ipv4.txt

# save ipv6
grep ':' /tmp/nordvpn.txt > /tmp/nordvpn-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/nordvpn-ipv4.txt > nordvpn/ipv4.txt
sort -u /tmp/nordvpn-ipv6.txt > nordvpn/ipv6.txt
