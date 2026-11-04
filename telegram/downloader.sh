#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'MNT-TELEGRAM' | grep -v 'route-set' | grep "/" > /tmp/telegram.txt || echo 'failed'
get_routes 'AS62041' >> /tmp/telegram.txt || echo 'failed'
get_routes 'AS59930' >> /tmp/telegram.txt || echo 'failed'
get_routes 'AS44907' >> /tmp/telegram.txt || echo 'failed'
get_routes 'AS211157' >> /tmp/telegram.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/telegram.txt > /tmp/telegram-ipv4.txt

# save ipv6
grep ':' /tmp/telegram.txt > /tmp/telegram-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/telegram-ipv4.txt > telegram/ipv4.txt
sort -u /tmp/telegram-ipv6.txt > telegram/ipv6.txt
