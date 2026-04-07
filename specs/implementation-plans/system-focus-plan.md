# Implementation Plan: System-Level Focus Control (Deep Block)

## Overview
Add a low-level domain block and file immutability to the workstation setup.

## Prerequisites
- [ ] System must have `e2fsprogs` installed (for `chattr`).

---

## Tasks

### Phase 1: Core Focus Script
- [ ] Create/Update `configs/focus-mode.sh`
      - Implement "Deep Block" domain list (Tabloids, Gambling, All major Porn sites, Creator platforms, Adult Manga, etc.)
      - Append to `/etc/hosts`
      - Run `sudo chattr +i /etc/hosts`

### Phase 2: DNS Immutability
- [ ] Update `configs/dns-nextdns.sh`
      - Add `sudo chattr +i /etc/resolv.conf` at the end of the script.

### Phase 3: Setup Orchestration
- [ ] Update `setup.sh`
      - Add `bash "$SCRIPT_DIR/configs/focus-mode.sh"` in the **Configs & Auth** section.

### Phase 4: Verification
- [ ] Run `lsattr /etc/hosts` and `lsattr /etc/resolv.conf` to verify the `i` flag.
- [ ] Ping blocked domains to ensure they resolve to `127.0.0.1`.
- [ ] Verify internet connectivity still works.
