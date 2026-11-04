#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained_inetnum 'mnt-ru-yandexcloud-1' > /tmp/yandexcloud.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/yandexcloud.txt > /tmp/yandexcloud-ipv4.txt

# save ipv6
grep ':' /tmp/yandexcloud.txt > /tmp/yandexcloud-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/yandexcloud-ipv4.txt > yandexcloud/ipv4.txt
sort -u /tmp/yandexcloud-ipv6.txt > yandexcloud/ipv6.txt
