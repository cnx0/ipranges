#!/bin/bash

# Smallish hostings popular with vpn providers and known vpn providers server locations' ips

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_maintained 'DATACAMP-MNT' > /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'GLOBALAXS-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'CLOUVIDER-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'HYDRA-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'ALTUSHOST-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'UKSERVERS-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'NUXTCLOUD-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'MAINT-GSLNETWORKS-AU' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'CYBERZONEHUB-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'MAINT-OWL-VU' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'MNT-HOSTINGINSIDE' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'MNT-WORLDSTREAM' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'fribourg-mnt' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'de-kiservices-1-mnt' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'mnt-de-itmbuechele-1' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'QWARTA-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'MNT-NFORCE' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'de-buechvps1-1-mnt' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'MAINT-HOSTROYALETECHNOLOGIES-IN' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'OVH-MNT' >> /tmp/vpnhosts.txt || echo 'failed'
get_maintained 'ESAB-MNT' >> /tmp/vpnhosts.txt || echo 'failed'

# CDN77
get_routes 'AS60068' >> /tmp/vpnhosts.txt || echo 'failed'
# Logicweb
get_routes 'AS64286' >> /tmp/vpnhosts.txt || echo 'failed'
# IPXO
get_routes 'AS206092' >> /tmp/vpnhosts.txt || echo 'failed'
# OVH
get_routes 'AS16276' >> /tmp/vpnhosts.txt || echo 'failed'
# ESAB
get_routes 'AS39351' >> /tmp/vpnhosts.txt || echo 'failed'

# known ips from https://github.com/Zomboided/service.vpn.manager.providers
cat vpnhosts-knownips.txt >> /tmp/vpnhosts.txt || echo 'failed'

curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-vpnhosts.txt >> /tmp/vpnhosts.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-vpnhosts.txt https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-vpnhosts.txt -s|cut -d'.' -f1,2,3|sort -u|awk '{print $0".0/24"}' >>/tmp/vpnhosts.txt

# save ipv4
grep -v ':' /tmp/vpnhosts.txt|rg '\.' > /tmp/vpnhosts-ipv4.txt

# save ipv6
grep ':' /tmp/vpnhosts.txt > /tmp/vpnhosts-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/vpnhosts-ipv4.txt > vpnhosts/ipv4.txt
sort -u /tmp/vpnhosts-ipv6.txt > vpnhosts/ipv6.txt
