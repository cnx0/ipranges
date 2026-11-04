#!/bin/bash


# https://www.linode.com/community/questions/19247/list-of-linodes-ip-ranges

set -euo pipefail
set -x


# get from public ranges
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://geoip.linode.com/ | grep -v '^#' | cut -d, -f1  > /tmp/linode.txt

# save ipv4
grep -v ':' /tmp/linode.txt > /tmp/linode-ipv4.txt

# save ipv6
grep ':' /tmp/linode.txt > /tmp/linode-ipv6.txt


# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/linode-ipv4.txt > linode/ipv4.txt
sort -u /tmp/linode-ipv6.txt > linode/ipv6.txt
