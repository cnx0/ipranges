#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained_inetnum 'MNT-CLOUDMTS' > /tmp/mtscloud.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/mtscloud.txt > /tmp/mtscloud-ipv4.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/mtscloud-ipv4.txt > mtscloud/ipv4.txt
