#!/usr/bin/env python3
"""Filter RPKI-INVALID prefixes for a given origin ASN.

Usage: rpki-rov.py <ASN> [roas.json] < prefixes.txt

Reads CIDRs on stdin, prints those that are RPKI-VALID or RPKI-UNKNOWN for the
given origin ASN, and drops RPKI-INVALID ones (a covering ROA exists, but it
belongs to a different ASN or its maxLength is exceeded). The ROA snapshot is
expected in the format published at https://rpki.cloudflare.com/rpki.json
({"roas": [{"prefix", "maxLength", "asn"}, ...]}).
"""
import ipaddress
import json
import sys


def parse_asn(value):
    return int(str(value).upper().removeprefix("AS"))


def load_roas(path):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    # canonical prefix string -> list of (max_length, asn)
    roa_map = {}
    for roa in data.get("roas", []):
        try:
            net = ipaddress.ip_network(roa["prefix"])
            max_length = int(roa.get("maxLength", net.prefixlen))
            asn = parse_asn(roa["asn"])
        except (KeyError, ValueError):
            continue
        roa_map.setdefault(str(net), []).append((max_length, asn))
    return roa_map


def main():
    if len(sys.argv) < 2:
        print("Usage: rpki-rov.py <ASN> [roas.json]", file=sys.stderr)
        sys.exit(2)

    asn = parse_asn(sys.argv[1])
    roa_map = load_roas(sys.argv[2] if len(sys.argv) > 2 else "/tmp/rpki.json")

    kept, dropped = 0, 0
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            net = ipaddress.ip_network(line)
        except ValueError:
            print(line)  # not ours to judge; merge.py validates later
            continue

        valid, covering = False, False
        cursor = net
        while True:
            for max_length, roa_asn in roa_map.get(str(cursor), []):
                covering = True
                if roa_asn == asn and net.prefixlen <= max_length:
                    valid = True
            if cursor.prefixlen == 0:
                break
            cursor = cursor.supernet()

        if valid or not covering:
            print(line)
            kept += 1
        else:
            dropped += 1
            print(f"rpki-rov: RPKI-INVALID dropped: {line} (AS{asn})", file=sys.stderr)

    if dropped:
        print(f"rpki-rov: dropped {dropped} RPKI-INVALID prefix(es) for AS{asn}, kept {kept}",
              file=sys.stderr)


if __name__ == "__main__":
    main()
