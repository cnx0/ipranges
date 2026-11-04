#!/bin/bash
set -euo pipefail
set -x


curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://download.microsoft.com/download/B/2/A/B2AB28E1-DAE1-44E8-A867-4987FE089EBE/msft-public-ips.csv | cut -d',' -f1|awk 'NR > 1'  > /tmp/microsoft.txt

cat /tmp/microsoft.txt | grep -v ":" > /tmp/microsoft-ipv4.txt
cat /tmp/microsoft.txt | grep ":" > /tmp/microsoft-ipv6.txt

sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/microsoft-ipv4.txt > microsoft/ipv4.txt
sort -u /tmp/microsoft-ipv6.txt > microsoft/ipv6.txt

