#!/bin/bash

# https://www.workplace.com/resources/tech/it-configuration/domain-whitelisting
# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=facebook&commit=Search
# https://github.com/SecOps-Institute/FacebookIPLists/blob/master/facebook_asn_list.lst

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

python utils/arin-org.py AL-3 > /tmp/alibaba.txt
whois -h whois.apnic.net "TAOBAO"| rg inetnum|sort -u|awk '{print $2" "$4}'|python utils/ipcalc.py >>/tmp/alibaba.txt
whois -h whois.apnic.net "TAOBAO"| grep inet6num| awk '{print $2}' >> /tmp/alibaba.txt

# The ARIN AL-3 org + APNIC TAOBAO handle above cover only part of Alibaba. Add the
# announced Alibaba Cloud / Aliyun footprint registered elsewhere: AS37963 (mainland
# Aliyun, the biggest block), the non-AL-3 half of AS45102 (Alibaba US), Taobao's tail
# (AS24429), and the Singapore cloud ASNs (AS134963, AS203513).
for asn in AS37963 AS45102 AS24429 AS134963 AS203513; do
    get_routes "$asn" >> /tmp/alibaba.txt || echo "failed: $asn"
done

# drop any default route an origin query might surface; a /0 would swallow the merged list.
grep -vE '^(0\.0\.0\.0|::)/0$' /tmp/alibaba.txt > /tmp/alibaba-clean.txt

# save ipv4
grep -v ':' /tmp/alibaba-clean.txt > /tmp/alibaba-ipv4.txt

# save ipv6
grep ':' /tmp/alibaba-clean.txt > /tmp/alibaba-ipv6.txt

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/alibaba-ipv4.txt > alibaba/ipv4.txt
sort -u /tmp/alibaba-ipv6.txt > alibaba/ipv6.txt
