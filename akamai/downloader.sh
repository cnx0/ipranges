#!/usr/bin/env bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

python utils/arin-org.py AKAMAI > /tmp/akamai.txt
get_routes 'AS12222' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS16625' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS16702' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS17204' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS18680' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS18717' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS20189' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS20940' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS22207' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS22452' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS23454' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS23455' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS26008' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS30675' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS33047' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS35993' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS35994' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS36183' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS393560' >> /tmp/akamai.txt || echo 'failed'
# additional Akamai-owned ASNs (incl. APNIC/RIPE-side and the Prolexic/Asavie blocks)
get_routes 'AS24319' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS34164' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS21342' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS200005' >> /tmp/akamai.txt || echo 'failed'
get_routes 'AS32787' >> /tmp/akamai.txt || echo 'failed'
# IRR as-set as a safety net for ASNs not listed above
get_as_set 'AS-AKAMAI' >> /tmp/akamai.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/akamai.txt > /tmp/akamai-ipv4.txt

# save ipv6
grep ':' /tmp/akamai.txt > /tmp/akamai-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/akamai-ipv4.txt > akamai/ipv4.txt
sort -u /tmp/akamai-ipv6.txt > akamai/ipv6.txt
