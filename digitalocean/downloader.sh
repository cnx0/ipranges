#!/bin/bash

# https://docs.digitalocean.com/products/platform/
# From: https://github.com/nccgroup/cloud_ip_ranges

set -euo pipefail
set -x


# get from public ranges
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://www.digitalocean.com/geo/google.csv | cut -d, -f1  > /tmp/digitalocean.txt

# save ipv4
grep -v ':' /tmp/digitalocean.txt > /tmp/digitalocean-ipv4.txt

# save ipv6
grep ':' /tmp/digitalocean.txt > /tmp/digitalocean-ipv6.txt


# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/digitalocean-ipv4.txt > digitalocean/ipv4.txt
sort -u /tmp/digitalocean-ipv6.txt > digitalocean/ipv6.txt
