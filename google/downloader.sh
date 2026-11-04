#!/bin/bash

# https://support.google.com/a/answer/60764
# https://cloud.google.com/compute/docs/faq#find_ip_range
# From: https://github.com/pierrocknroll/googlecloud-iprange/blob/master/list.sh
# From: https://gist.github.com/jeffmccune/e7d635116f25bc7e12b2a19efbafcdf8
# From: https://gist.github.com/n0531m/f3714f6ad6ef738a3b0a

set -euo pipefail
set -x

# shared IRR helpers (get_as_set used below)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"



# get from public ranges
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://www.gstatic.com/ipranges/goog.txt > /tmp/goog.txt
#curl -s https://www.gstatic.com/ipranges/cloud.json > /tmp/cloud.json

# Public GoogleBot IP ranges
# From: https://developers.google.com/search/docs/advanced/crawling/verifying-googlebot
# (-L: the old /search/apis/ipranges/ path now 301-redirects to /static/crawling/ipranges/)
curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors https://developers.google.com/search/apis/ipranges/googlebot.json > /tmp/googlebot.json

# get from netblocks
# dig is wrapped: a flaky UDP query to 8.8.8.8 must not abort the whole
# downloader under set -e; retries smooth out transient packet loss
dig_txt() {
  dig +time=5 +tries=2 TXT "$1" +short @8.8.8.8 2>/dev/null || true
}

: > /tmp/google-netblocks.txt
txt="$(dig_txt _netblocks.google.com)"
idx=2
while [[ -n "${txt}" ]]; do
  echo "${txt}" | tr '[:space:]+' "\n" | grep ':' | cut -d: -f2- >> /tmp/google-netblocks.txt || true
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

#get_dns_spf "_cloud-netblocks.googleusercontent.com" >> /tmp/google-netblocks.txt
get_dns_spf "_spf.google.com" >> /tmp/google-netblocks.txt || true

# IRR as-set as a safety net for announcements not covered above
get_as_set 'AS-GOOGLE' >> /tmp/google-netblocks.txt || echo 'failed'


# save ipv4 (|| true: an empty supplementary file must not abort the run)
grep -v ':' /tmp/goog.txt > /tmp/google-ipv4.txt || true
#jq '.prefixes[] | [.ipv4Prefix][] | select(. != null)' -r /tmp/cloud.json >> /tmp/google-ipv4.txt
jq '.prefixes[] | [.ipv4Prefix][] | select(. != null)' -r /tmp/googlebot.json >> /tmp/google-ipv4.txt
grep -v ':' /tmp/google-netblocks.txt >> /tmp/google-ipv4.txt || true
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/resolve-google.txt >> /tmp/google-ipv4.txt || echo 'failed'
curl -fsS --retry 3 --retry-delay 5 --retry-all-errors https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-google.txt >> /tmp/google-ipv4.txt || echo 'failed'

# save ipv6
grep ':' /tmp/goog.txt > /tmp/google-ipv6.txt || true
#jq '.prefixes[] | [.ipv6Prefix][] | select(. != null)' -r /tmp/cloud.json >> /tmp/google-ipv6.txt
jq '.prefixes[] | [.ipv6Prefix][] | select(. != null)' -r /tmp/googlebot.json >> /tmp/google-ipv6.txt
grep ':' /tmp/google-netblocks.txt >> /tmp/google-ipv6.txt || true

# the primary sources (goog.txt, googlebot.json) are fetched with curl -f above,
# so an empty result here means real degradation: abort and keep the old list
if [ ! -s /tmp/google-ipv4.txt ]; then
  echo "google: collected no ipv4 ranges, keeping previous list" >&2
  exit 1
fi


# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/google-ipv4.txt > google/ipv4.txt
sort -u /tmp/google-ipv6.txt > google/ipv6.txt
