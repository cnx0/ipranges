#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-huggingface.txt > /tmp/huggingface.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-huggingface.txt >> /tmp/huggingface.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/huggingface.txt > /tmp/huggingface-ipv4.txt || echo 'failed'

# save ipv6
grep ':' /tmp/huggingface.txt > /tmp/huggingface-ipv6.txt || echo 'failed'

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/huggingface-ipv4.txt > huggingface/ipv4.txt || echo 'failed'
sort -u /tmp/huggingface-ipv6.txt > huggingface/ipv6.txt || echo 'failed'
