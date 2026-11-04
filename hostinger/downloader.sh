#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'MNT-HOSTINGER' | grep -v 'route-set' | grep "/" > /tmp/hostinger.txt || echo 'failed'
get_routes 'AS47583' >> /tmp/hostinger.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/hostinger.txt > /tmp/hostinger-ipv4.txt

# save ipv6
grep ':' /tmp/hostinger.txt > /tmp/hostinger-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/hostinger-ipv4.txt > hostinger/ipv4.txt
sort -u /tmp/hostinger-ipv6.txt > hostinger/ipv6.txt
