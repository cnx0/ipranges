#!/bin/bash

# Discord's web/app/CDN frontends (discord.gg, cdn.discordapp.com) sit behind
# Cloudflare and are already covered by the cloudflare list. This list targets
# Discord's own infrastructure — the voice/media servers:
#   - AS49544 (i3D.net): Discord's voice backbone, announces the 66.22.x.x
#     voice ranges (Discord owns i3D.net since 2022)
#   - lir-us-discord1-1-MNT: Discord's own RIPE maintainer, holds the
#     66.22.192.0/18 allocation and any route objects they register

set -euo pipefail
set -x

# shared IRR helpers: get_routes / get_maintained / get_maintained_inetnum
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"

get_routes 'AS49544' > /tmp/discord.txt || echo 'failed'
get_maintained_inetnum 'lir-us-discord1-1-MNT' >> /tmp/discord.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/discord.txt > /tmp/discord-ipv4.txt

# save ipv6
grep ':' /tmp/discord.txt > /tmp/discord-ipv6.txt


# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u /tmp/discord-ipv4.txt > discord/ipv4.txt
sort -u /tmp/discord-ipv6.txt > discord/ipv6.txt
