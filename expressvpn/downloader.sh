#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

# LogicWeb
get_routes 'AS64286' > /tmp/expressvpn.txt || echo 'failed'
# IPXO Limited
get_routes 'AS206092' >> /tmp/expressvpn.txt || echo 'failed'
# Latitude.sh
get_routes 'AS262287' >> /tmp/expressvpn.txt || echo 'failed'
# Angani Limited
get_routes 'AS37684' >> /tmp/expressvpn.txt || echo 'failed'

curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-expressvpn.txt >> /tmp/expressvpn.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/expressvpn.txt > /tmp/expressvpn-ipv4.txt

# save ipv6
grep ':' /tmp/expressvpn.txt > /tmp/expressvpn-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/expressvpn-ipv4.txt > expressvpn/ipv4.txt
sort -u /tmp/expressvpn-ipv6.txt > expressvpn/ipv6.txt
