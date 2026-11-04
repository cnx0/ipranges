#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS399358' > /tmp/claude.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/claude.txt > /tmp/claude-ipv4.txt

# save ipv6
grep ':' /tmp/claude.txt > /tmp/claude-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/claude-ipv4.txt > claude/ipv4.txt
sort -u /tmp/claude-ipv6.txt > claude/ipv6.txt
