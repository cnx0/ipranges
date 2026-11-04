#!/bin/bash
set -euo pipefail
set -x


curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://mask-api.icloud.com/egress-ip-ranges.csv | cut -d',' -f1  > /tmp/apple-proxy.txt

cat /tmp/apple-proxy.txt | grep -v ":" > /tmp/apple-proxy-ipv4.txt
cat /tmp/apple-proxy.txt | grep ":" > /tmp/apple-proxy-ipv6.txt

sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/apple-proxy-ipv4.txt > apple-proxy/ipv4.txt
sort -u /tmp/apple-proxy-ipv6.txt > apple-proxy/ipv6.txt

