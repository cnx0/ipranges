#!/usr/bin/env python3
"""Resolve an ARIN organization handle to its registered networks via Whois-RWS.

Usage: arin-org.py <org-handle>

Prints one CIDR per line on stdout. Diagnostics go to stderr, and any failure
exits non-zero — callers redirect stdout into IP lists, so error text must
never leak there (previously an HTTP error was printed to stdout with exit 0
and ended up inside the service's raw list).
"""
import sys
import time
import xml.etree.ElementTree as ET

import netaddr
import requests

BASE_URL = "https://whois.arin.net/rest"
HEADERS = {"Accept": "application/xml"}
RETRIES = 3
TIMEOUT = 30


def fetch(org_handle):
    url = f"{BASE_URL}/org/{org_handle}/nets"
    last_err = "unknown error"
    for attempt in range(1, RETRIES + 1):
        try:
            response = requests.get(url, headers=HEADERS, timeout=TIMEOUT)
        except requests.RequestException as exc:
            last_err = str(exc)
        else:
            if response.status_code == 200:
                return response.text
            last_err = f"HTTP {response.status_code}"
        if attempt < RETRIES:
            time.sleep(2 ** attempt)
    print(f"arin-org: failed to fetch {org_handle}: {last_err}", file=sys.stderr)
    sys.exit(1)


def main():
    if len(sys.argv) != 2:
        print("Usage: arin-org.py <org-handle>", file=sys.stderr)
        sys.exit(2)

    org_handle = sys.argv[1]
    xml_data = fetch(org_handle)

    try:
        root = ET.fromstring(xml_data)
    except ET.ParseError as exc:
        print(f"arin-org: malformed XML for {org_handle}: {exc}", file=sys.stderr)
        sys.exit(1)

    # netRef elements carry startAddress/endAddress attributes (not namespaced).
    cidrs = []
    for elem in root.iter():
        start, end = elem.get("startAddress"), elem.get("endAddress")
        if not (start and end):
            continue
        ip_range = netaddr.IPRange(netaddr.IPAddress(start), netaddr.IPAddress(end))
        cidrs.extend(str(cidr) for cidr in ip_range.cidrs())

    if not cidrs:
        print(f"arin-org: no networks found for {org_handle}", file=sys.stderr)
        sys.exit(1)

    print("\n".join(cidrs))


if __name__ == "__main__":
    main()
