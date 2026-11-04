#!/bin/bash

# https://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html

set -euo pipefail
set -x


# get from public ranges
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://ip-ranges.amazonaws.com/ip-ranges.json > /tmp/amazon.json


# save ipv4
jq '.prefixes[] | [.ip_prefix][] | select(. != null)' -r /tmp/amazon.json > /tmp/amazon-ipv4.txt

# save ipv6
jq '.ipv6_prefixes[] | [.ipv6_prefix][] | select(. != null)' -r /tmp/amazon.json > /tmp/amazon-ipv6.txt


# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/amazon-ipv4.txt > amazon/ipv4.txt
sort -u /tmp/amazon-ipv6.txt > amazon/ipv6.txt
