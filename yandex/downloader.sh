#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'YANDEX-MNT' > /tmp/yandex.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/yandex.txt > /tmp/yandex-ipv4.txt

# save ipv6
grep ':' /tmp/yandex.txt > /tmp/yandex-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/yandex-ipv4.txt > yandex/ipv4.txt
sort -u /tmp/yandex-ipv6.txt > yandex/ipv6.txt
