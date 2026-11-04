#!/bin/bash

# Qrator Labs (DDoS mitigation).
# NOTE: MNT-QRATOR no longer holds any route objects (checked 2026-11: zero
# routes on all IRR mirrors; the legacy ranges are now announced by HLL LLC /
# AS51115, i.e. not Qrator anymore). The live Qrator network is AS197068.

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS197068' > /tmp/qrator.txt || true

# an empty result means every IRR source failed: abort so the previously
# committed list is kept instead of being wiped
if [ ! -s /tmp/qrator.txt ]; then
  echo "qrator: collected no routes for AS197068, keeping previous list" >&2
  exit 1
fi

# save ipv4
grep -v ':' /tmp/qrator.txt > /tmp/qrator-ipv4.txt || true

# save ipv6
grep ':' /tmp/qrator.txt > /tmp/qrator-ipv6.txt || true

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/qrator-ipv4.txt > qrator/ipv4.txt
sort -u /tmp/qrator-ipv6.txt > qrator/ipv6.txt
