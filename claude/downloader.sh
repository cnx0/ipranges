#!/bin/bash

set -euo pipefail
set -x

get_routes() {
    whois -h riswhois.ripe.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
}

get_routes 'AS399358' > /tmp/claude.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/claude.txt > /tmp/claude-ipv4.txt

# save ipv6
grep ':' /tmp/claude.txt > /tmp/claude-ipv6.txt


# sort & uniq
sort -h /tmp/claude-ipv4.txt | uniq > claude/ipv4.txt
sort -h /tmp/claude-ipv6.txt | uniq > claude/ipv6.txt
