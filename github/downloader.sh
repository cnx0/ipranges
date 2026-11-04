#!/bin/bash

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses

set -euo pipefail
set -x


# get from public ranges
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://api.github.com/meta > /tmp/github.json


# get all prefixes without some keys
jq 'del(.["ssh_keys", "verifiable_password_authentication", "ssh_key_fingerprints", "actions", "domains"]) | .[] | .[]' -r /tmp/github.json > /tmp/github-all.txt


# save ipv4
grep -v ':' /tmp/github-all.txt > /tmp/github-ipv4.txt

# save ipv6
grep ':' /tmp/github-all.txt > /tmp/github-ipv6.txt


# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/github-ipv4.txt > github/ipv4.txt
sort -u /tmp/github-ipv6.txt > github/ipv6.txt
