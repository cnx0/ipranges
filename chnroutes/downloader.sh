#!/bin/bash

# China routes (all CN IP space announced in BGP).
# Source: misakaio/chnroutes2 — daily dump from an RRC collector in China,
# pre-aggregated (~3.9k prefixes). IPv4 only.

set -euo pipefail
set -x

curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors \
  https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt \
  | grep -v '^#' | sed '/^$/d' > /tmp/chnroutes.txt

if [ ! -s /tmp/chnroutes.txt ]; then
  echo "chnroutes: downloaded list is empty, keeping previous list" >&2
  exit 1
fi

# save ipv4
grep -v ':' /tmp/chnroutes.txt > /tmp/chnroutes-ipv4.txt || true

# save ipv6 (currently none upstream, kept for symmetry)
grep ':' /tmp/chnroutes.txt > /tmp/chnroutes-ipv6.txt || true

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/chnroutes-ipv4.txt > chnroutes/ipv4.txt
sort -u /tmp/chnroutes-ipv6.txt > chnroutes/ipv6.txt
