# IPRanges
List all IP ranges of some companies, cloud services, and popular sites. This project is a considerably extended fork of [IPRanges](https://github.com/lord-alfred/ipranges) by [Lord_Alfred](https://t.me/Lord_Alfred).
I maintain this for my personal use on my home router mostly. 

## Included ip address ranges
### Cloud Services and Content Delivery Networks
Amazon (AWS), Alibaba Cloud, Azure (Microsoft), Backblaze, Digital Ocean, Google Cloud, Hetzner, Hostinger, Linode, MTS Cloud, Oracle, OVHcloud, Vultr (Constant), Yandex Cloud, Akamai, CacheFly, Cloudflare, EdgeCast, Fastly, Imperva, Qrator

### Search Engines, Social Media, and Communication Platforms
Bing (Microsoft), Google, Yahoo, Yandex, Facebook, LinkedIn, TikTok, Telegram, Twitter (X.com), Vkontakte, YouTube, Kinopub, Rambler

### E-commerce, Technology Companies, and Online Services
Alibaba, Amazon, Avito, Ozon.ru, Adobe, Apple, Microsoft, Sberbank, Hugging Face, GitHub, Vercel

### Internet Service Providers, VPNs, and Regional Services
Cogent, ExpressVPN, NordVPN, ProtonVPN, Surfshark, PIA, Mullvad, Popular VPN services servers' providers, Apple's iCloud Private Relay, Beeline, Corbina, M247, MTS, Rostelecom, Russian Government sites

## How the lists are built
Each service's `downloader.sh` collects ranges from one or more public sources, then CI merges them into the smallest equivalent set of CIDRs. The sources fall into a few methods:

- **Official vendor feeds** — published JSON/API endpoints where a provider documents its own ranges. Used for Amazon (AWS), Azure, Google / Google Cloud, Bing, Cloudflare, Fastly, GitHub, Oracle, Imperva (Incapsula), Apple iCloud Private Relay, Mullvad, NordVPN, and ProtonVPN.
- **IRR route objects** — `route:`/`route6:` objects harvested by origin ASN from five Internet Routing Registry mirrors (RIPE `riswhois`, RADb, NTT, Rogers, and `bgp.net.br`). RIPE's `riswhois` also reflects globally observed BGP announcements, so a provider's real prefixes surface even when they are not registered in any IRR. Each mirror is queried independently so one being down — or simply having no object for the ASN — never aborts the rest; when every mirror comes back empty, the helper falls back to the RIPEstat `announced-prefixes` API. When an RPKI ROA snapshot is available (fetched in CI), RPKI-INVALID prefixes are dropped (`utils/rpki-rov.py`).
- **IRR as-sets** — recursive as-set expansion via `bgpq4` (`get_as_set` in `utils/lib-irr.sh`), used as a safety net for providers with many ASNs: Apple, Akamai, Google, Twitter, Hetzner, OVH.
- **ARIN organization records** — every network registered to an organization handle, via ARIN Whois-RWS (`utils/arin-org.py`). Used for Apple, Adobe, Akamai, Alibaba, Backblaze, CacheFly, EdgeCast, Fastly, Twitter, Vercel, and others.
- **RIPE/RADb maintainer (`mnt-by`) objects** — every route maintained by a given maintainer handle, used mostly for regional networks: MTS, Rostelecom, Sber, Yandex, VK, Ozon, Avito, Rambler, Qrator, Hostinger, Beeline, Corbina, Kinopub.
- **RFC 8805 geofeeds** — provider-published geolocation feeds (Cogent, Vultr/Constant, DigitalOcean, Linode).
- **inetnum → CIDR conversion** — RIPE `inetnum` ranges expanded into CIDRs by `utils/ipcalc.py`.

After collection, CI compresses each list with `utils/merge.py` (netaddr `cidr_merge`), which also drops stray default routes (`0.0.0.0/0`, `::/0`) centrally and refuses to emit a list when more than 5% of the source lines are unparseable (the previous committed list is kept instead). A sanity-floor guard then reverts any merged list that collapses to empty or loses more than 66% of its entries in a single run, protecting a good list from being wiped by a broken or briefly-unreachable upstream, and flags any list that grows more than 3x in one run for review. If a scheduled run still has failing downloaders, CI opens (or comments on) a "Downloader failures" issue so a degrading source gets noticed.

## Repository Structure
	.
	├── ipv4-services.txt         # index of every populated ipv4_merged.txt
	├── ipv6-services.txt         # index of every populated ipv6_merged.txt
	├── [service_name]/
	│   ├── downloader.sh
	│   ├── ipv4.txt
	│   ├── ipv6.txt
	│   ├── ipv4_merged.txt
	│   └── ipv6_merged.txt
	├── utils/
	│   ├── merge.py              # collapse a list into the smallest CIDR set
	│   ├── arin-org.py           # ARIN org handle → its registered networks
	│   ├── ipcalc.py             # IP range → CIDRs
	│   └── lib-irr.sh            # shared IRR whois helpers for downloaders
	└── .github/
	    └── workflows/
	        └── update.yml
### Service Folders
Each service folder contains:

- `downloader.sh`: Script for fetching IP ranges from public sources
- `ipv4.txt`/`ipv6.txt`: the list of addresses (IPv4 or IPv6), which is the result of parsing one or more sources
- `ipv4_merged.txt`/`ipv6_merged.txt`: optimized lists combined into the smallest possible CIDRs

The repository root also holds `ipv4-services.txt`/`ipv6-services.txt`, an index listing the path of every populated `*_merged.txt` file across all services.

### Utility Scripts

The `utils/` folder houses Python scripts for fetching and processing IP lists:

- `merge.py`: collapses a list into the smallest equivalent set of CIDRs (netaddr `cidr_merge`). Drops stray default routes (`0.0.0.0/0`, `::/0`) centrally and refuses to emit a list when more than 5% of the source lines are unparseable (the previous committed list is kept instead)
- `arin-org.py`: resolves an ARIN organization handle to its registered networks via Whois-RWS (with retries; errors go to stderr and exit non-zero, so they never leak into a list)
- `ipcalc.py`: expands an IPv4 start–end range into CIDRs
- `lib-irr.sh`: shared IRR helpers sourced by the ASN/maintainer-based downloaders — `get_routes <ASN>`, `get_maintained <MNT>`, `get_maintained_inetnum <MNT>`, `get_as_set <AS-SET>`. Every mirror is queried independently with a per-query timeout, so one down registry never aborts a downloader
- `rpki-rov.py`: drops RPKI-INVALID prefixes for an origin ASN using a ROA snapshot

### Automated Updates
Daily updates are managed via GitHub Actions, as defined in `.github/workflows/update.yml`.

## Sister repos
Here's list of another data I use for my router configs:
  * [ipnames](https://github.com/antonme/ipnames): daily updated list of FQDNs and resolved IPs of some popular sites/platforms. Made for routing of some VPNs in my router
  * [geoip](https://github.com/antonme/geoip): lists of CIDR's by regions for routing VPNs in my router
