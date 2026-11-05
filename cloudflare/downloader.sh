#!/bin/bash


set -euo pipefail
set -x

# shared IRR helpers
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils"
source "$LIB_DIR/lib-irr.sh"

# Stage in /tmp first so a failed fetch can't truncate the committed list.
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://www.cloudflare.com/ips-v4 > /tmp/cloudflare-ipv4.txt
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://www.cloudflare.com/ips-v6 > /tmp/cloudflare-ipv6.txt

# Cloudflare announces more than their published ips-v4/ips-v6 lists:
# e.g. the 104.28.0.0-104.31.255.255 space (incl. 104.29.x) carries Discord
# voice RTC and other Cloudflare products, yet is absent from the official
# lists. Add what AS13335 actually announces: RIPEstat BGP view first
# (fast, stable), IRR mirrors as fallback (their 60k+ stale route objects
# are slow and flaky for this ASN).
bgp="$(get_announced_prefixes 'AS13335')"
if [ -z "$bgp" ]; then
  echo "cloudflare: RIPEstat empty, falling back to IRR mirrors" >&2
  bgp="$(get_routes 'AS13335')"
fi
# RPKI-filter when the snapshot is available (the get_routes path already
# filters internally; apply it to the RIPEstat result here)
if [ -n "$bgp" ] && [ -s "$IRR_RPKI_ROAS" ]; then
  bgp="$(printf '%s\n' "$bgp" | python3 "$IRR_LIB_DIR/rpki-rov.py" AS13335 "$IRR_RPKI_ROAS" || printf '%s\n' "$bgp")"
fi
printf '%s\n' "$bgp" > /tmp/cloudflare-bgp.txt

# collapse the thousands of more-specifics so the raw list stays compact;
# on merge failure fall back to the uncollapsed data
if [ -s /tmp/cloudflare-bgp.txt ]; then
  python3 "$LIB_DIR/merge.py" --source=/tmp/cloudflare-bgp.txt > /tmp/cloudflare-bgp-collapsed.txt \
    || cp /tmp/cloudflare-bgp.txt /tmp/cloudflare-bgp-collapsed.txt
else
  : > /tmp/cloudflare-bgp-collapsed.txt
fi

# guarantee trailing newlines so concatenation can't glue lines together
echo >> /tmp/cloudflare-ipv4.txt
echo >> /tmp/cloudflare-ipv6.txt
echo >> /tmp/cloudflare-bgp-collapsed.txt

cat /tmp/cloudflare-ipv4.txt /tmp/cloudflare-ipv6.txt /tmp/cloudflare-bgp-collapsed.txt > /tmp/cloudflare-all.txt

# split families, sort & uniq
grep -v ':' /tmp/cloudflare-all.txt | sed '/^$/d' | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u > cloudflare/ipv4.txt || true
grep ':' /tmp/cloudflare-all.txt | sed '/^$/d' | sort -u > cloudflare/ipv6.txt || true
