#!/bin/bash


# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=pia&commit=Search
# https://github.com/SecOps-Institute/TwitterIPLists/blob/master/pia_asn_list.lst

set -euo pipefail
set -x



curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/Lars-/PIA-servers/refs/heads/master/export.csv| grep "\."|awk -F','  '{print $1}'| sort -u >/tmp/pia.txt


# save ipv4
grep -v ':' /tmp/pia.txt > /tmp/pia-ipv4.txt



# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/pia-ipv4.txt > pia/ipv4.txt
