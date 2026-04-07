#!/usr/bin/env bash
set -euo pipefail

# Workstation Focus Mode (Deep Block)
# Blocks 50+ distracting and NSFW domains at the OS level.
# Excludes YouTube, Twitch, Reddit, and LinkedIn as requested.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Focus Mode — Deep Block (50+ Domains)"
log "═══════════════════════════════════════════════════════"

# ── Domain List ──────────────────────────────────────────────────────
DOMAINS=(
  # Major Adult Tube Sites
  "pornhub.com" "www.pornhub.com"
  "xvideos.com" "www.xvideos.com"
  "xnxx.com" "www.xnxx.com"
  "xhamster.com" "www.xhamster.com"
  "redtube.com" "www.redtube.com"
  "youporn.com" "www.youporn.com"
  "youjizz.com" "www.youjizz.com"
  "porn.com" "www.porn.com"
  "nuvid.com" "www.nuvid.com"
  "spankbang.com" "www.spankbang.com"
  "chaturbate.com" "www.chaturbate.com"
  "tube8.com" "www.tube8.com"
  "thumbzilla.com" "www.thumbzilla.com"
  "eporner.com" "www.eporner.com"
  "porntrex.com" "www.porntrex.com"
  "yourporn.sexy" "www.yourporn.sexy"
  "porndig.com" "www.porndig.com"
  "pornmz.com" "www.pornmz.com"
  "beeg.com" "www.beeg.com"
  "fapdu.com" "www.fapdu.com"
  "motherless.com" "www.motherless.com"
  "pornmd.com" "www.pornmd.com"
  "cam4.com" "www.cam4.com"
  "bongacams.com" "www.bongacams.com"
  "stripchat.com" "www.stripchat.com"
  "thisvid.com" "www.thisvid.com"
  "redgifs.com" "www.redgifs.com"
  "aznude.com" "www.aznude.com"
  "pornhat.com" "www.pornhat.com"
  "pornpics.com" "www.pornpics.com"
  "hqporner.com" "www.hqporner.com"
  "sex.com" "www.sex.com"
  "pussyspace.com" "www.pussyspace.com"
  "4tube.com" "www.4tube.com"
  "freeones.com" "www.freeones.com"
  "tnaflix.com" "www.tnaflix.com"
  "empflix.com" "www.empflix.com"
  "heavy-r.com" "www.heavy-r.com"
  "daftsex.com" "www.daftsex.com"
  "javhd.com" "www.javhd.com"
  "pornoz.com" "www.pornoz.com"
  "porndish.com" "www.porndish.com"
  "perfectgirls.net" "www.perfectgirls.net"
  "cumlouder.com" "www.cumlouder.com"

  # Cam & Live Chat
  "jerkmate.com" "www.jerkmate.com"
  "sniffies.com" "www.sniffies.com"
  "xhamsterlive.com" "www.xhamsterlive.com"

  # Adult Creator Platforms
  "onlyfans.com" "www.onlyfans.com"
  "fansly.com" "www.fansly.com"
  "loyalfans.com" "www.loyalfans.com"
  "mym.fans" "www.mym.fans"

  # Hentai, Adult Manga & Image Boards
  "nhentai.net" "www.nhentai.net"
  "tsumino.com" "www.tsumino.com"
  "hentaihaven.xxx" "www.hentaihaven.xxx"
  "hanime.tv" "www.hanime.tv"
  "hentaicube.com" "www.hentaicube.com"
  "doujins.com" "www.doujins.com"
  "hentai2read.com" "www.hentai2read.com"
  "e-hentai.org" "www.e-hentai.org"
  "rule34.xxx" "www.rule34.xxx"
  "gelbooru.com" "www.gelbooru.com"
  "secretclass.us" "www.secretclass.us"
  "mangahe.com" "www.mangahe.com"
  "mangaxo.com" "www.mangaxo.com"
  "nanime.biz" "www.nanime.biz"
  "kissanime.com.ru" "www.kissanime.com.ru"
  "gogoanime.ai" "www.gogoanime.ai"
  "e621.net" "www.e621.net"
  "hdporncomics.com" "www.hdporncomics.com"
  "hentainexus.com" "www.hentainexus.com"
  "nhder.com" "www.nhder.com"
  "hentaiworld.tv" "www.hentaiworld.tv"
  "fetlife.com" "www.fetlife.com"
  "theporndude.com" "www.theporndude.com"
  "literotica.com" "www.literotica.com"
  "listcrawler.eu" "www.listcrawler.eu"

  # Tabloid & Gossip Sites
  "tmz.com" "www.tmz.com"
  "dailymail.co.uk" "www.dailymail.co.uk"
  "thesun.co.uk" "www.thesun.co.uk"
  "buzzfeed.com" "www.buzzfeed.com"
  "perezhilton.com" "www.perezhilton.com"
  "pagesix.com" "www.pagesix.com"
  "hellomagazine.com" "www.hellomagazine.com"
  "usmagazine.com" "www.usmagazine.com"
  "okmagazine.com" "www.okmagazine.com"

  # Gambling & Betting Platforms
  "bet365.com" "www.bet365.com"
  "pokerstars.com" "www.pokerstars.com"
  "888poker.com" "www.888poker.com"
  "draftkings.com" "www.draftkings.com"
  "bovada.lv" "www.bovada.lv"
  "stake.com" "www.stake.com"
  "roobet.com" "www.roobet.com"
  "ignitioncasino.eu" "www.ignitioncasino.eu"

  # Distractions & Social
  "tiktok.com" "www.tiktok.com"
  "9gag.com" "www.9gag.com"
  "4chan.org" "www.4chan.org"

  # Streaming Platforms
  "netflix.com" "www.netflix.com"
  "primevideo.com" "www.primevideo.com"
  "disneyplus.com" "www.disneyplus.com"
  "hulu.com" "www.hulu.com"
  "hbomax.com" "www.hbomax.com"
  "paramountplus.com" "www.paramountplus.com"
)

# ── Update /etc/hosts ───────────────────────────────────────────────
HOSTS_FILE="/etc/hosts"

# Unlock if already immutable
if lsattr "$HOSTS_FILE" 2>/dev/null | grep -q "^....i"; then
  log "Unlocking $HOSTS_FILE for updates..."
  sudo chattr -i "$HOSTS_FILE"
fi

log "Adding distraction blocks to $HOSTS_FILE (Deep Block)..."

# Backup current hosts if not already backed up
if [[ ! -f "${HOSTS_FILE}.bak" ]]; then
  sudo cp "$HOSTS_FILE" "${HOSTS_FILE}.bak"
fi

# Filter and append only missing domains
for domain in "${DOMAINS[@]}"; do
  if ! grep -qF "$domain" "$HOSTS_FILE"; then
    echo "127.0.0.1 $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
  fi
done

# ── Lock /etc/hosts ─────────────────────────────────────────────────
log "Locking $HOSTS_FILE (making it immutable)..."
sudo chattr +i "$HOSTS_FILE"

log "Focus Mode setup complete."
