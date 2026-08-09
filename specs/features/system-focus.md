# Feature: System-Level Focus Control (Deep Block)

## Overview
Integrates distraction-free controls directly into the workstation bootstrap process by blocking 50+ focus-robbing domains via `/etc/hosts` and ensuring DNS settings cannot be easily bypassed by making them immutable.

## Problem Statement
Distractions like social media, streaming, gossip, gambling, and world-class adult content can derail deep work. A permanent, low-level block helps maintain an environment optimized for coding.

## Solution
1. **Curated + full-list blocking**: A curated core list (~215 high-traffic domains including the biggest Brazilian betting brands — betano, pixbet, esportes da sorte, blaze, estrelabet) plus the full StevenBlack porn+betting blocklist (~50k registrable domains) appended to `/etc/hosts` pointing to `127.0.0.1`.
2. **Immutability Protection**: Use `chattr +i` on `/etc/hosts` and `/etc/resolv.conf` to prevent unauthorized or accidental modifications.
3. **Core Integration**: Call the focus-mode script during Phase 1 of `setup.sh`.
4. **Sticky by design**: Deliberately no "off" toggle — the point is friction, so a single command can't defeat the block at the first urge.

## Requirements

### Functional
- [x] Block major adult tube sites (Pornhub, XVideos, XNXX, YouJizz, etc.).
- [x] Block hentai, adult manga, and image boards (NHentai, Rule34, Gelbooru, etc.).
- [x] Block adult creator platforms (OnlyFans, Fansly, etc.).
- [x] Block addictive tabloid and gossip sites (TMZ, Daily Mail, BuzzFeed, etc.).
- [x] Block major gambling and betting platforms (Bet365, PokerStars, etc.).
- [x] Block Brazilian betting platforms (Betano, Pixbet, Esportes da Sorte, Blaze, Estrelabet, etc.).
- [x] Block `tiktok.com` and major streaming platforms (Netflix, Prime Video, etc.).
- [x] **EXCLUDE** `youtube.com`, `twitch.tv`, `reddit.com`, and `linkedin.com` from the block list.
- [x] Make `/etc/hosts` immutable.
- [x] Make `/etc/resolv.conf` immutable.
- [x] Cover the full long tail via the StevenBlack porn+betting list (~50k domains) in addition to the curated core.

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
