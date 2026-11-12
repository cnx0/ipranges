#!/bin/bash

# Tencent (incl. Tencent Cloud). Source: the AS-TENCENT IRR as-set
# (members: AS132203:AS-TENCENT), expanded recursively via bgpq4.
# Fallback: per-ASN route objects of the main Tencent ASNs.

set -euo pipefail
set -x

# shared IRR helpers: get_as_set / get_routes
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_as_set 'AS-TENCENT' > /tmp/tencent.txt || true

if [ ! -s /tmp/tencent.txt ]; then
  echo "tencent: as-set expansion empty, falling back to per-ASN routes" >&2
  for asn in AS132203 AS45090 AS136958 AS139341; do
    get_routes "$asn"
  done > /tmp/tencent.txt || true
fi

if [ ! -s /tmp/tencent.txt ]; then
  echo "tencent: collected no routes, keeping previous list" >&2
  exit 1
fi

# save ipv4
grep -v ':' /tmp/tencent.txt > /tmp/tencent-ipv4.txt || true

# save ipv6
grep ':' /tmp/tencent.txt > /tmp/tencent-ipv6.txt || true

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/tencent-ipv4.txt > tencent/ipv4.txt
sort -u /tmp/tencent-ipv6.txt > tencent/ipv6.txt
