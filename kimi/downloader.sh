#!/bin/bash

# Kimi (Moonshot AI). The service sits behind Chinese anti-DDoS scrubbing
# proxies (Volcengine volcddos.com, Alibaba aliyunddos*.com), so there is no
# ASN to pull: collect the IPs the service domains currently resolve to.
# NOTE: these are shared scrubbing-center addresses and the set is GSLB-
# dependent; the chnroutes service covers the same space more broadly.

set -euo pipefail
set -x

domains="
kimi.com
www.kimi.com
kimi.ai
www.kimi.ai
moonshot.cn
www.moonshot.cn
api.moonshot.cn
platform.moonshot.cn
kimi.moonshot.cn
"

: > /tmp/kimi.txt
for d in $domains; do
  # strict IP-shaped output only: dig prints intermediate CNAMEs too
  dig +time=5 +tries=2 +short A "$d" @8.8.8.8 2>/dev/null \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' >> /tmp/kimi.txt || true
  dig +time=5 +tries=2 +short AAAA "$d" @8.8.8.8 2>/dev/null \
    | grep -E '^[0-9a-fA-F:]+$' >> /tmp/kimi.txt || true
done

if [ ! -s /tmp/kimi.txt ]; then
  echo "kimi: DNS resolution returned nothing, keeping previous list" >&2
  exit 1
fi

# save ipv4 (bare IPs -> /32)
grep -v ':' /tmp/kimi.txt | sed 's|$|/32|' > /tmp/kimi-ipv4.txt || true

# save ipv6 (bare IPs -> /128)
grep ':' /tmp/kimi.txt | sed 's|$|/128|' > /tmp/kimi-ipv6.txt || true

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/kimi-ipv4.txt > kimi/ipv4.txt
sort -u /tmp/kimi-ipv6.txt > kimi/ipv6.txt
