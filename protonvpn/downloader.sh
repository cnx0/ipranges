#!/bin/bash

# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=protonvpn&commit=Search
# https://github.com/SecOps-Institute/TwitterIPLists/blob/master/protonvpn_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS209103' > /tmp/protonvpn.txt || echo 'failed'

# NOTE: api.protonvpn.ch/vpn/logicals now requires auth (401), so this source is
# best-effort; the IRR origin above still produces the list if the API fails.
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://api.protonvpn.ch/vpn/logicals|jq .LogicalServers[].Servers[].EntryIP| tr -d '"'| sort -u >>/tmp/protonvpn.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/protonvpn.txt > /tmp/protonvpn-ipv4.txt

# save ipv6
grep ':' /tmp/protonvpn.txt > /tmp/protonvpn-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/protonvpn-ipv4.txt > protonvpn/ipv4.txt
sort -u /tmp/protonvpn-ipv6.txt > protonvpn/ipv6.txt
