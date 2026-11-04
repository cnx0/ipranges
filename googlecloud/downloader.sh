#!/bin/bash

# https://support.google.com/a/answer/60764
# https://cloud.google.com/compute/docs/faq#find_ip_range
# From: https://github.com/pierrocknroll/googlecloud-iprange/blob/master/list.sh
# From: https://gist.github.com/jeffmccune/e7d635116f25bc7e12b2a19efbafcdf8
# From: https://gist.github.com/n0531m/f3714f6ad6ef738a3b0a

set -euo pipefail
set -x



# get from public ranges
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://www.gstatic.com/ipranges/cloud.json > /tmp/googlecloud.json

# get from netblocks
# dig is wrapped: a flaky UDP query to 8.8.8.8 must not abort the whole
# downloader under set -e; retries smooth out transient packet loss
dig_txt() {
  dig +time=5 +tries=2 TXT "$1" +short @8.8.8.8 2>/dev/null || true
}

: > /tmp/googlecloud-netblocks.txt
txt="$(dig_txt _netblocks.google.com)"
idx=2
while [[ -n "${txt}" ]]; do
  echo "${txt}" | tr '[:space:]+' "\n" | grep ':' | cut -d: -f2- >> /tmp/googlecloud-netblocks.txt || true
  txt="$(dig_txt _netblocks${idx}.google.com)"
  ((idx++))
done

# get from other netblocks
get_dns_spf() {
   dig +time=5 +tries=2 @8.8.8.8 +short txt "$1" 2>/dev/null |
   tr ' ' '\n' |
   while read entry; do
      case "$entry" in
             ip4:*) echo "${entry#*:}" ;;
             ip6:*) echo "${entry#*:}" ;;
         include:*) get_dns_spf "${entry#*:}" || true ;;
      esac
   done
}

get_dns_spf "_cloud-netblocks.googleusercontent.com" >> /tmp/googlecloud-netblocks.txt || true


# save ipv4 (|| true: an empty supplementary file must not abort the run)
jq '.prefixes[] | [.ipv4Prefix][] | select(. != null)' -r /tmp/googlecloud.json > /tmp/googlecloud-ipv4.txt
grep -v ':' /tmp/googlecloud-netblocks.txt >> /tmp/googlecloud-ipv4.txt || true

# save ipv6
jq '.prefixes[] | [.ipv6Prefix][] | select(. != null)' -r /tmp/googlecloud.json > /tmp/googlecloud-ipv6.txt
grep ':' /tmp/googlecloud-netblocks.txt >> /tmp/googlecloud-ipv6.txt || true

# the primary source (cloud.json) is fetched with curl -f above, so an empty
# result here means real degradation: abort and keep the old list
if [ ! -s /tmp/googlecloud-ipv4.txt ]; then
  echo "googlecloud: collected no ipv4 ranges, keeping previous list" >&2
  exit 1
fi


# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/googlecloud-ipv4.txt > googlecloud/ipv4.txt
sort -u /tmp/googlecloud-ipv6.txt > googlecloud/ipv6.txt
