#!/usr/bin/env python3
"""Merge a list of IP networks into the smallest equivalent set of CIDRs.

Reads CIDRs from --source, writes the merged set to stdout (sorted).

Central guards that used to be scattered (or missing) across downloaders:
- default routes (0.0.0.0/0, ::/0) are dropped — one stray /0 would otherwise
  collapse an entire merged list into a single entry;
- invalid lines are dropped, but counted: if they exceed MAX_INVALID_FRACTION
  of the input, the script exits non-zero so the failure is visible in CI
  instead of silently shrinking a list.
"""
import argparse
import sys
import netaddr

MAX_INVALID_FRACTION = 0.05


def main():
    parser = argparse.ArgumentParser(description='Merge IP addresses into the smallest possible list of CIDRs.')
    parser.add_argument('--source', nargs='?', type=argparse.FileType('r'), required=True, help='Source file path')
    args = parser.parse_args()

    source_name = getattr(args.source, 'name', '<stdin>')
    networks = []
    total = 0
    invalid = 0
    dropped_default = 0

    for line in args.source:
        line = line.strip()
        if not line:
            continue
        total += 1
        try:
            net = netaddr.IPNetwork(line)
        except (netaddr.AddrFormatError, ValueError):
            invalid += 1
            print(f"merge: invalid line dropped: {line!r}", file=sys.stderr)
            continue
        if net.prefixlen == 0:
            dropped_default += 1
            continue
        networks.append(net)

    if dropped_default:
        print(f"merge: dropped {dropped_default} default route(s) from {source_name}", file=sys.stderr)
    if total and invalid / total > MAX_INVALID_FRACTION:
        # hard failure: print nothing to stdout so a redirect/pipe never
        # captures a partial list that then gets committed
        print(f"merge: ERROR: {invalid}/{total} invalid lines in {source_name} "
              f"(> {MAX_INVALID_FRACTION:.0%}), refusing to emit a list", file=sys.stderr)
        sys.exit(1)
    if invalid:
        print(f"merge: dropped {invalid}/{total} invalid lines from {source_name}", file=sys.stderr)

    for net in sorted(netaddr.cidr_merge(networks)):
        print(net)


if __name__ == '__main__':
    main()
