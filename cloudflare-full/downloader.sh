#!/bin/bash

# cloudflare-full: everything AS13335 announces, not just the published
# cloudflare.com/ips-* lists.
#
# Why this exists next to the plain `cloudflare` list:
# - The official lists lag reality: e.g. 104.28.0.0-104.31.255.255 (incl.
#   104.29.x, used by Discord voice RTC) is announced by AS13335 but absent
#   from ips-v4.
# - WARNING: announced space includes customer BYOIP (Cloudflare announces
#   Enterprise customers' own prefixes, e.g. 8.6.112.0/24 belongs to
#   LPL Financial). This list is a superset of "Cloudflare the product" —
#   use it when completeness matters more than precision.

set -euo pipefail
set -x

# shared IRR helpers
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils"
source "$LIB_DIR/lib-irr.sh"

# Stage in /tmp first so a failed fetch can't truncate the committed list.
# (file names are prefixed with the service dir: downloaders run in parallel)
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://www.cloudflare.com/ips-v4 > /tmp/cloudflare-full-ipv4.txt
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://www.cloudflare.com/ips-v6 > /tmp/cloudflare-full-ipv6.txt

# BGP view: what AS13335 actually announces right now (RIPEstat announced-
# prefixes: fast, stable, one REST call). IRR mirrors are the fallback —
# their 60k+ stale route objects are slow and flaky for this ASN.
bgp="$(get_announced_prefixes 'AS13335')"
if [ -z "$bgp" ]; then
  echo "cloudflare-full: RIPEstat empty, falling back to IRR mirrors" >&2
  bgp="$(get_routes 'AS13335')"
fi
# RPKI-filter when the snapshot is available (the get_routes path already
# filters internally; apply it to the RIPEstat result here)
if [ -n "$bgp" ] && [ -s "$IRR_RPKI_ROAS" ]; then
  bgp="$(printf '%s\n' "$bgp" | python3 "$IRR_LIB_DIR/rpki-rov.py" AS13335 "$IRR_RPKI_ROAS" || printf '%s\n' "$bgp")"
fi
printf '%s\n' "$bgp" > /tmp/cloudflare-full-bgp.txt

# collapse the thousands of more-specifics so the raw list stays compact;
# on merge failure fall back to the uncollapsed data
if [ -s /tmp/cloudflare-full-bgp.txt ]; then
  python3 "$LIB_DIR/merge.py" --source=/tmp/cloudflare-full-bgp.txt > /tmp/cloudflare-full-bgp-collapsed.txt \
    || cp /tmp/cloudflare-full-bgp.txt /tmp/cloudflare-full-bgp-collapsed.txt
else
  : > /tmp/cloudflare-full-bgp-collapsed.txt
fi

# guarantee trailing newlines so concatenation can't glue lines together
echo >> /tmp/cloudflare-full-ipv4.txt
echo >> /tmp/cloudflare-full-ipv6.txt
echo >> /tmp/cloudflare-full-bgp-collapsed.txt

cat /tmp/cloudflare-full-ipv4.txt /tmp/cloudflare-full-ipv6.txt /tmp/cloudflare-full-bgp-collapsed.txt > /tmp/cloudflare-full-all.txt

# split families, sort & uniq
grep -v ':' /tmp/cloudflare-full-all.txt | sed '/^$/d' | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u > cloudflare-full/ipv4.txt || true
grep ':' /tmp/cloudflare-full-all.txt | sed '/^$/d' | sort -u > cloudflare-full/ipv6.txt || true
