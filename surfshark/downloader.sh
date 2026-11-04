#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

# Cyberzone S.A. 
get_routes 'AS209854' > /tmp/surfshark.txt || echo 'failed'

curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-surfshark.txt >> /tmp/surfshark.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/surfshark.txt > /tmp/surfshark-ipv4.txt

# save ipv6
grep ':' /tmp/surfshark.txt > /tmp/surfshark-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/surfshark-ipv4.txt > surfshark/ipv4.txt
sort -u /tmp/surfshark-ipv6.txt > surfshark/ipv6.txt
