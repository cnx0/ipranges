#!/bin/bash

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

#government
get_maintained 'TFGS-MNT' > /tmp/rugov.txt || echo 'failed'
get_maintained 'INFR-MNT' >> /tmp/rugov.txt || echo 'failed'
get_maintained 'ROSNIIROS-MNT' >> /tmp/rugov.txt || echo 'failed'
#mchs
get_maintained 'mnt-ru-servguru-1' >> /tmp/rugov.txt || echo 'failed'
#mos
get_routes AS62268 >> /tmp/rugov.txt || echo 'failed'
get_routes AS8901 >> /tmp/rugov.txt || echo 'failed'
#mil
get_routes AS33972 >> /tmp/rugov.txt || echo 'failed'
#minzdrav
get_routes AS199148 >> /tmp/rugov.txt || echo 'failed'
#economy
get_routes AS12389 >> /tmp/rugov.txt || echo 'failed'
#digital
get_maintained 'SERVICEPIPE-MNT' >> /tmp/rugov.txt || echo 'failed'
#mvd,transport.mos.ru
get_routes AS209030 >> /tmp/rugov.txt || echo 'failed'
#fsb
get_routes AS8342 >> /tmp/rugov.txt || echo 'failed'
#vgtrk
get_maintained 'VGTRK-MNT' >> /tmp/rugov.txt || echo 'failed'
#fss
get_maintained 'FSS-MNT' >> /tmp/rugov.txt || echo 'failed'
#fsin+
get_maintained 'RUWEB-MNT-RIPE' >> /tmp/rugov.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/rugov.txt | grep -v "0.0.0.0" > /tmp/rugov-ipv4.txt

# save ipv6
grep ':' /tmp/rugov.txt > /tmp/rugov-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/rugov-ipv4.txt > rugov/ipv4.txt
sort -u /tmp/rugov-ipv6.txt > rugov/ipv6.txt
