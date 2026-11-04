# shellcheck shell=bash
# Shared IRR (Internet Routing Registry) helpers for service downloaders.
#
# Usage from a downloader (works regardless of the caller's CWD):
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/lib-irr.sh"
#
# Every mirror is queried independently, and every query is wrapped in
# `timeout` + `|| true`: a mirror that is down, times out, or simply has no
# object for the query never aborts the calling downloader (which runs under
# `set -euo pipefail`) and never hides the results of the other mirrors.

IRR_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mirrors answering "-i origin" (route/route6 objects by origin ASN).
# riswhois.ripe.net additionally reflects globally observed BGP announcements.
IRR_ORIGIN_SERVERS="riswhois.ripe.net whois.radb.net rr.ntt.net whois.rogerstelecom.net whois.bgp.net.br"

# Mirrors answering "-i mnt-by" (objects by maintainer handle).
# riswhois does not index maintainer handles, so whois.ripe.net is used instead.
IRR_MNT_SERVERS="whois.ripe.net whois.radb.net rr.ntt.net whois.rogerstelecom.net whois.bgp.net.br"

# Per-query timeout (seconds); override via environment if a mirror is slow.
WHOIS_TIMEOUT="${WHOIS_TIMEOUT:-30}"

# Path to an RPKI ROA snapshot (https://rpki.cloudflare.com/rpki.json format).
# When the file exists and is non-empty, get_routes drops RPKI-INVALID prefixes.
IRR_RPKI_ROAS="${IRR_RPKI_ROAS:-/tmp/rpki.json}"

_irr_query() {
    local server="$1" query="$2"
    timeout "$WHOIS_TIMEOUT" whois -h "$server" -- "$query" 2>/dev/null \
        | rg '^route' | awk '{print $2}' \
        || true
}

# get_announced_prefixes ASxxxxx — RIPEstat REST API fallback, no raw whois.
get_announced_prefixes() {
    local asn="$1"
    curl -fsS --retry 3 --retry-delay 5 --retry-all-errors \
        "https://stat.ripe.net/data/announced-prefixes/data.json?resource=$asn" 2>/dev/null \
        | jq -r '.data.prefixes[].prefix' 2>/dev/null \
        || true
}

# get_routes ASxxxxx — route/route6 objects by origin ASN from all origin mirrors.
# Falls back to RIPEstat announced-prefixes when every IRR mirror returns
# nothing (mirror outage or an ASN registered only via BGP visibility), and
# drops RPKI-INVALID prefixes when a ROA snapshot is available.
get_routes() {
    local asn="$1" server routes
    routes=""
    for server in $IRR_ORIGIN_SERVERS; do
        routes+="$(_irr_query "$server" "-i origin $asn")"$'\n'
    done
    routes="$(printf '%s\n' "$routes" | sed '/^$/d')"
    if [ -z "$routes" ]; then
        echo "lib-irr: all IRR mirrors empty for $asn, falling back to RIPEstat" >&2
        routes="$(get_announced_prefixes "$asn")"
    fi
    if [ -n "$routes" ] && [ -s "$IRR_RPKI_ROAS" ]; then
        printf '%s\n' "$routes" | python3 "$IRR_LIB_DIR/rpki-rov.py" "$asn" "$IRR_RPKI_ROAS" \
            || printf '%s\n' "$routes"
    else
        [ -n "$routes" ] && printf '%s\n' "$routes"
    fi
}

# get_as_set AS-EXAMPLE — expand an IRR as-set (recursively, incl. members'
# route objects) via bgpq4. Tries several IRRD mirrors; needs bgpq4 installed.
get_as_set() {
    local asset="$1" server out
    if ! command -v bgpq4 >/dev/null 2>&1; then
        echo "lib-irr: bgpq4 not installed, skipping as-set $asset" >&2
        return 0
    fi
    for server in rr.ntt.net whois.radb.net whois.ripe.net; do
        out="$({ timeout 90 bgpq4 -4 -h "$server" -A -F '%n/%l\n' "$asset"
                 timeout 90 bgpq4 -6 -h "$server" -A -F '%n/%l\n' "$asset"
              } 2>/dev/null)" || true
        out="$(printf '%s\n' "$out" | sed '/^$/d')"
        if [ -n "$out" ]; then
            printf '%s\n' "$out"
            return 0
        fi
    done
    echo "lib-irr: bgpq4 returned nothing for $asset on all mirrors" >&2
    return 0
}

# get_maintained MNT-XXX — route/route6 objects by maintainer handle.
get_maintained() {
    local mnt="$1" server
    for server in $IRR_MNT_SERVERS; do
        _irr_query "$server" "-i mnt-by $mnt"
    done
}

# get_maintained_inetnum MNT-XXX — same routes as get_maintained, plus RIPE
# `inetnum:` ranges (start–end) expanded into CIDRs. Used for regional networks
# whose RIPE allocations are registered as inetnum rather than route objects.
get_maintained_inetnum() {
    local mnt="$1" server ripe_tmp
    ripe_tmp="$(mktemp)"
    for server in $IRR_MNT_SERVERS; do
        if [ "$server" = "whois.ripe.net" ]; then
            # keep the full RIPE response: inetnum ranges are parsed from it below
            timeout "$WHOIS_TIMEOUT" whois -h "$server" -- "-i mnt-by $mnt" 2>/dev/null > "$ripe_tmp" || true
            rg '^route' "$ripe_tmp" | awk '{print $2}' || true
        else
            _irr_query "$server" "-i mnt-by $mnt"
        fi
    done
    # "inetnum:  1.2.3.0 - 1.2.3.255" -> fields 2 and 4 -> CIDRs
    rg '^inetnum' "$ripe_tmp" | sort -u | awk '{print $2" "$4}' \
        | python3 "$IRR_LIB_DIR/ipcalc.py" || true
    rm -f "$ripe_tmp"
}
