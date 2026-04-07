# Feature: System-Level Focus Control (Deep Block)

## Overview
Integrates distraction-free controls directly into the workstation bootstrap process by blocking 50+ focus-robbing domains via `/etc/hosts` and ensuring DNS settings cannot be easily bypassed by making them immutable.

## Problem Statement
Distractions like social media, streaming, gossip, gambling, and world-class adult content can derail deep work. A permanent, low-level block helps maintain an environment optimized for coding.

## Solution
1. **Ultra-Host-Based Blocking**: Append an expanded list of distracting domains to `/etc/hosts` pointing to `127.0.0.1`.
2. **Immutability Protection**: Use `chattr +i` on `/etc/hosts` and `/etc/resolv.conf` to prevent unauthorized or accidental modifications.
3. **Core Integration**: Call the focus-mode script during Phase 1 of `setup.sh`.

## Requirements

### Functional
- [ ] Block major adult tube sites (Pornhub, XVideos, XNXX, YouJizz, etc.).
- [ ] Block hentai, adult manga, and image boards (NHentai, Rule34, Gelbooru, etc.).
- [ ] Block adult creator platforms (OnlyFans, Fansly, etc.).
- [ ] Block addictive tabloid and gossip sites (TMZ, Daily Mail, BuzzFeed, etc.).
- [ ] Block major gambling and betting platforms (Bet365, PokerStars, etc.).
- [ ] Block `tiktok.com` and major streaming platforms (Netflix, Prime Video, etc.).
- [ ] **EXCLUDE** `youtube.com`, `twitch.tv`, `reddit.com`, and `linkedin.com` from the block list.
- [ ] Make `/etc/hosts` immutable.
- [ ] Make `/etc/resolv.conf` immutable.

### Non-Functional
- **Security**: Requires `sudo` permissions as it modifies system files.
- **Persistence**: Blocks should survive reboots and shell sessions.

## Integration Points

### `setup.sh`
- How it integrates: Added to the "Configs & Auth" section of Phase 1.
- Files affected: `setup.sh`

### `configs/dns-nextdns.sh`
- How it integrates: Append immutability for `resolv.conf` after completion.
- Files affected: `configs/dns-nextdns.sh`

## Out of Scope
- Dynamic toggling (e.g., turning focus mode on/off via CLI).
