#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'OZONRU-MNT' > /tmp/ozonru.txt || echo 'failed'

nslookup ozon.ru| tail -n +4 | grep Address| awk '{print $2}' >> /tmp/ozonru.txt

# save ipv4
grep -v ':' /tmp/ozonru.txt > /tmp/ozonru-ipv4.txt

# save ipv6
grep ':' /tmp/ozonru.txt > /tmp/ozonru-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/ozonru-ipv4.txt > ozonru/ipv4.txt
sort -u /tmp/ozonru-ipv6.txt > ozonru/ipv6.txt
