# Roadmap: From Pre-built to Bare Metal

A learning progression from installing pre-built apps to building a custom OS on RISC-V bare metal. 10 phases, 10 levels each — 100 possible positions.

Each phase has 11 levels (0-10). Level 0 is always "pre-built / skip this phase." Level 10 is the hardest challenge in that phase.

Phases are sequential — you progress from Phase 1 to 10. Earlier phases use pre-built versions of things that later phases teach you to compile.

```
Phase 1:   "I compiled ripgrep with cargo"
Phase 5:   "I compiled the Rust compiler, then compiled ripgrep"
Phase 7:   "I compiled the kernel that runs the Rust that compiled ripgrep"
Phase 10:  "I cross-compiled it all for RISC-V and booted it on bare metal"
```

---

## Phase 1: CLI Tools & Small Apps *(implemented)*

**Hardware:** Any laptop.
**Time estimate:** Level 1 adds ~5 min. Level 10 adds ~45 min.
**Status:** Fully implemented in code.
**Prerequisites:** None — this is the starting point.

Build command-line tools and small applications from source. You'll learn how Go, Rust, and C projects are structured, how different build systems work (cargo, go build, autotools, cmake, meson), and how to compile and install binaries.

| Level | Name | Tools compiled | Build system | Time added | What you learn |
|-------|------|---------------|--------------|------------|----------------|
| 0 | Pre-built | — | — | 0 min | Nothing — just install and use |
| 1 | First steps | codex, claude-code, gemini-cli, kilo-cli, vercel-cli, context-hub | npm | ~2 min | How Node.js/TypeScript projects are built: `npm install` fetches dependencies, `npm run build` compiles TypeScript to JavaScript, `npm link` creates a global symlink |
| 2 | Go basics | + fzf, lazygit, lazydocker, opencode | `go build` | ~1 min | How Go compiles to a single static binary with no runtime dependencies. One command: `go build -o binary .` |
| 3 | Rust basics | + ripgrep, fd | `cargo build` | ~2 min | How Cargo manages Rust projects: downloads crates (dependencies), compiles everything, produces a single binary in `target/release/` |
| 4 | Rust medium | + starship, uv | `cargo build` | ~10 min | Same as L3 but these projects have many more dependencies. Your CPU will work hard. You'll see Cargo download 200+ crates |
| 5 | Official repos | + gh, tailscale, docker CLI | `make` + Go | ~5 min | How larger Go projects use Makefiles to orchestrate builds. Multiple binaries (tailscale + tailscaled). Build flags and version embedding |
| 6 | CMake & Meson | + flameshot, easyeffects | CMake, Meson | ~15 min | Two modern build systems. CMake generates Makefiles, Meson generates Ninja files. Both handle library detection, compiler flags, install targets. First encounter with Qt5 and GTK4 dependencies |
| 7 | Autotools intro | + htop, jq | autotools | ~5 min | The classic Unix build pattern: `./autogen.sh && ./configure && make`. Autotools generates portable `./configure` scripts. `./configure` detects your system. `make` compiles. `make install` copies binaries |
| 8 | Core system | + tmux, zsh | autotools | ~5 min | Same pattern as L7 but with more complex dependencies (libevent for tmux, ncurses for both). These are tools your daily workflow depends on |
| 9 | Core infrastructure | + git | make | ~3 min | Git has its own make-based build system (no autotools). Many optional features controlled by compile flags: SSL, curl, expat. You'll see how a tool you use 100x/day is assembled |
| 10 | Full source | + Node.js | `./configure && make` | ~30 min | Compile an entire language runtime from C++. Node.js is V8 (Google's JavaScript engine) + libuv (async I/O) + Node's standard library. The longest build in Phase 1 — your machine will be at 100% CPU |

**Cumulative totals:**

| Level | Tools compiled | Tools pre-built | Approx total time |
|-------|---------------|----------------|-------------------|
| 0 | 0 | 31 | ~15 min |
| 1 | 6 | 25 | ~17 min |
| 2 | 10 | 21 | ~18 min |
| 3 | 12 | 19 | ~20 min |
| 4 | 14 | 17 | ~30 min |
| 5 | 17 | 14 | ~35 min |
| 6 | 19 | 12 | ~50 min |
| 7 | 21 | 10 | ~55 min |
| 8 | 23 | 8 | ~60 min |
| 9 | 24 | 7 | ~63 min |
| 10 | 25 | 6 | ~90 min |

**Desktop apps (OBS, GIMP, Audacity, Telegram, Bitwarden) are always pre-built via flatpak in Phase 1.** They move to Phase 2.

**Key concepts you'll learn in Phase 1:**
- **Static vs dynamic linking:** Go produces static binaries (no dependencies). Rust/C produce dynamically linked binaries (need shared libraries).
- **Build systems:** npm (JavaScript), cargo (Rust), go build (Go), make (C), autotools (C, portable), CMake (C++, modern), Meson (C++, newest).
- **The build→install pattern:** Compile produces a binary in the source tree. `install` copies it to `/usr/local/bin/` so it's on your PATH.
- **Dependencies:** Some tools need libraries installed first (Qt5 for flameshot, libevent for tmux). `ensure_build_deps` handles this.

---

## Phase 2: Desktop Apps

**Hardware:** 8GB+ RAM recommended. Some builds need 16GB+. All on your laptop.
**Time estimate:** Level 1 adds ~20 min. Level 10 adds 2-6 hours.
**Status:** Not yet implemented.
**Prerequisites:** Phase 1 gives you familiarity with CMake and Meson (Levels 6-7).

Heavy desktop applications with large dependency trees, complex build systems, and GUI frameworks. This is where builds start failing, dependencies conflict, and you learn to troubleshoot.

| Level | Name | Tool | Build system | Time | What you learn |
|-------|------|------|-------------|------|----------------|
| 0 | Pre-built | — | — | 0 | Flatpak handles everything — sandboxed, no dependency conflicts |
| 1 | Warmup | Audacity | CMake | ~20 min | Audio app. CMake with wxWidgets (GUI toolkit), many audio codec libraries. First build where `apt install` of build deps takes several minutes |
| 2 | Warmup+ | + EasyEffects | Meson | ~15 min | GTK4 + PipeWire audio processing. Meson build with many C++ libraries. Learn about PipeWire (modern Linux audio) |
| 3 | Qt intro | + Flameshot | CMake + Qt5 | ~10 min | First full Qt5 application from source. Qt's MOC (Meta-Object Compiler) generates extra C++ code. `cmake` must find Qt5 headers and libraries |
| 4 | *(reserved)* | — | — | — | Space for future desktop tools |
| 5 | Heavy cmake | + OBS Studio | CMake + Qt6 | ~30 min | Huge dependency tree: Qt6, FFmpeg codecs, PipeWire, V4L2 (video), Wayland/X11. Git submodules. Many optional features. Build may fail on missing deps — learning to read CMake error messages is the skill |
| 6 | Heavy meson | + GIMP | Meson | ~25 min | Image editor with GEGL (graph-based image processing), many format libraries (JPEG, PNG, TIFF, WebP, HEIF). Build touches many parts of the graphics stack |
| 7 | Fragile | + Telegram (Nicegram) | CMake + Ninja + Qt6 | ~40 min | The most fragile build. Deep git submodules (`--init --recursive` fetches 1GB+). Qt6, custom patches, version mismatches. **This build will likely fail on the first try.** Debugging it is the lesson |
| 8 | Electron | + Bitwarden | npm + Electron | ~20 min | TypeScript/Electron app. `npm ci` downloads hundreds of Node packages. Electron bundles Chromium — you're building a browser inside a password manager. Learn how modern desktop apps are really web apps |
| 9 | Chromium prep | *(reserved)* | — | — | Install Chromium build dependencies, fetch depot_tools, understand the Chromium build system (GN + Ninja). Preparation for Level 10 |
| 10 | The final boss | + Brave browser | GN + Ninja | 2-6 hours | **Chromium fork.** 100GB+ disk space, 16GB+ RAM minimum. The `fetch` step alone downloads 30GB+ of source. GN generates Ninja build files. Ninja compiles ~30,000 C++ files. This is the largest open-source build in existence. Completing this means you can build almost anything |

**Key concepts you'll learn in Phase 2:**
- **GUI frameworks:** Qt5, Qt6, GTK4, wxWidgets, Electron. How desktop apps draw windows and handle events.
- **Media libraries:** FFmpeg, PipeWire, PulseAudio, V4L2. The Linux audio/video stack.
- **Build failure debugging:** Reading CMake/Meson error messages, finding missing dependencies, patching build scripts.
- **Git submodules:** How large projects (OBS, Telegram) bundle dependencies as nested git repos.
- **Electron:** How web technologies (HTML/CSS/JS) become desktop apps by bundling Chromium.
- **The Chromium build system:** GN (Generate Ninja) + Ninja. Used by Chrome, Brave, Electron, VS Code, and many more.

**Source repositories:**
- Audacity: `https://github.com/audacity/audacity.git`
- EasyEffects: `https://github.com/wwmm/easyeffects.git`
- Flameshot: `https://github.com/flameshot-org/flameshot.git`
- OBS Studio: `https://github.com/obsproject/obs-studio.git`
- GIMP: `https://gitlab.gnome.org/GNOME/gimp.git`
- Telegram (Nicegram): `https://github.com/nicegram/nicegram-desktop.git`
- Bitwarden: `https://github.com/bitwarden/clients.git`
- Brave: `https://github.com/nicegram/nicegram-desktop.git` (uses Chromium's depot_tools)

---

## Phase 3: Runtimes & Interpreters

**Hardware:** Any laptop. 4GB+ RAM. Each build is 10-60 minutes.
**Time estimate:** Full phase ~3-4 hours.
**Status:** Not yet implemented.
**Prerequisites:** Phase 1 (familiarity with `./configure && make` from Levels 7-10).

Build the language runtimes that your tools depend on. In Phase 1, Python came from apt, Node.js from nvm, Ruby from apt. Now you compile them from their C/C++ source code and understand what a "language runtime" actually is.

| Level | Name | Tool | Build system | Time | What you learn |
|-------|------|------|-------------|------|----------------|
| 0 | Pre-built | — | — | 0 | Language runtimes from apt/nvm |
| 1 | Tiny runtime | Lua 5.4 | make | ~1 min | The simplest language to compile. ~30 .c files, one Makefile. Read the source — you can understand the entire interpreter in a weekend. Learn what a stack-based VM is |
| 2 | JIT intro | + LuaJIT | make | ~2 min | Same language, but with a JIT (Just-In-Time) compiler. LuaJIT translates Lua bytecode to machine code at runtime. Compare performance with standard Lua |
| 3 | Scripting | + Perl | `./Configure && make` | ~10 min | Perl's `Configure` (capital C!) is a custom config script, not autotools. 10,000+ lines of shell. Generates `config.h` with 500+ platform-specific defines |
| 4 | GUI toolkit | + Tcl/Tk | `./configure && make` | ~10 min | Tcl is a scripting language + Tk is a GUI toolkit. Together they power `gitk`, `tkinter` (Python), and many Unix tools. Two separate builds |
| 5 | Python | + CPython | `./configure && make` | ~15 min | The Python you use every day is written in C. `./configure` detects 50+ optional modules (SSL, SQLite, readline, zlib). Missing deps = missing Python modules. `make` compiles the interpreter + C extensions |
| 6 | Python tools | + pip, setuptools | Python | ~5 min | Bootstrap Python's package ecosystem from source. `ensurepip` builds pip from bundled wheel. Understand how `pip install` works under the hood |
| 7 | Ruby | + Ruby | `./configure && make` | ~15 min | Ruby's build is similar to Python's. Important because Homebrew is written in Ruby — building Ruby is a prerequisite for Phase 4+ Homebrew from source |
| 8 | Node.js | + Node.js | `./configure && make` | ~30 min | V8 JavaScript engine (from Google Chrome) + libuv (async I/O library) + Node standard library. The heaviest runtime build. V8 alone is millions of lines of C++ |
| 9 | Java | + OpenJDK | make + custom | ~60 min | The most complex runtime. JVM (Java Virtual Machine), JIT compiler (C2/Graal), garbage collector, class library. Bootstrap requires an existing JDK. Massive build |
| 10 | All runtimes | Everything | — | ~2.5 hours | Every language runtime on your system is compiled from source |

**Key concepts you'll learn in Phase 3:**
- **Interpreters vs JIT compilers:** Lua interprets bytecode. LuaJIT compiles it to machine code. Python does both (bytecode + optional JIT in newer versions).
- **The C extension pattern:** Python, Ruby, Lua all support C extensions — native code that runs inside the interpreter for performance.
- **Bootstrap compilers:** OpenJDK needs an existing JDK to compile. This is the "chicken and egg" problem of compilers.
- **Configure-time feature detection:** `./configure` probes your system for libraries. Missing library = missing feature in the final build.
- **What "runtime" means:** Memory management (GC), I/O, standard library, module system. All implemented in C/C++.

**Source repositories:**
- Lua: `https://github.com/lua/lua.git`
- LuaJIT: `https://github.com/LuaJIT/LuaJIT.git`
- Perl: `https://github.com/Perl/perl5.git`
- Tcl: `https://github.com/tcltk/tcl.git`
- Tk: `https://github.com/tcltk/tk.git`
- CPython: `https://github.com/python/cpython.git`
- Ruby: `https://github.com/ruby/ruby.git`
- Node.js: `https://github.com/nodejs/node.git`
- OpenJDK: `https://github.com/openjdk/jdk.git`

---

## Phase 4: Build Systems

**Hardware:** Any laptop.
**Time estimate:** Full phase ~1-2 hours.
**Status:** Not yet implemented.
**Prerequisites:** Phase 1 Levels 6-7 (you've used CMake, Meson, and autotools as a consumer). Phase 3 Level 5 (Python, needed for Meson).

Build the build systems themselves. These are the tools that Phase 1-3 used to compile everything. You'll understand what `./configure` actually does, how `make` works, and why there are so many build systems.

| Level | Name | Tool | How it builds itself | Time | What you learn |
|-------|------|------|---------------------|------|----------------|
| 0 | Pre-built | — | — | 0 | Build systems from apt |
| 1 | Ninja | Ninja | Python bootstrap script | ~1 min | Ninja is a tiny, fast build executor. It doesn't generate build files — it just runs them fast. CMake and Meson generate Ninja files. Written in C++, bootstraps with a Python script (`./configure.py && ninja`) |
| 2 | pkg-config | + pkg-config | autotools | ~1 min | The invisible hero: `pkg-config --cflags --libs libfoo` tells the compiler where to find libraries. Every `./configure` script uses it. Tiny codebase, enormous impact |
| 3 | Meson | + Meson | Python (pip install from source) | ~2 min | Meson is a Python program. "Building" it means installing the Python package from the source repo. Understand how a Python project becomes a system-wide build tool |
| 4 | CMake | + CMake | `./bootstrap && make` | ~10 min | CMake bootstraps itself: the `./bootstrap` script is a shell script that compiles CMake using just a C++ compiler. Then the compiled CMake can build the next version of CMake. Self-hosting! |
| 5 | GNU Make | + GNU Make | `make` (existing make) | ~2 min | `make` builds `make`. The ultimate self-hosting tool. The Makefile is read by the existing system `make` to produce a new `make` binary. Understand the `make` rule syntax: targets, prerequisites, recipes |
| 6 | Autoconf | + Autoconf | `./configure && make` (but it generates `./configure`) | ~2 min | Autoconf generates `./configure` scripts from `configure.ac` templates. Written in M4 (a macro language). When you run `./configure`, you're running thousands of shell commands generated by Autoconf |
| 7 | Automake | + Automake | Perl + autotools | ~2 min | Automake generates `Makefile.in` from `Makefile.am`. The chain: `Makefile.am` → (automake) → `Makefile.in` → (./configure) → `Makefile`. Now you understand the full autotools pipeline |
| 8 | Libtool | + Libtool | autotools | ~2 min | Handles the complexity of shared libraries across Unix variants. `.la` files, versioned `.so` symlinks, `rpath`. The glue that makes `make install` work for libraries |
| 9 | M4 | + GNU M4 | `./configure && make` | ~1 min | The macro processor underneath Autoconf. M4 reads text with macro definitions and expands them. Understanding M4 = understanding how `./configure` scripts are generated |
| 10 | All build systems | Everything | — | ~25 min | You compiled every build system. You understand the full chain: M4 → Autoconf → Automake → ./configure → Makefile → make → binary |

**The build system family tree:**
```
M4 (macro processor)
 └── Autoconf (generates ./configure)
      └── Automake (generates Makefile.in)
           └── Libtool (handles shared libraries)
                └── ./configure && make && make install

CMake (generates Makefiles or Ninja files)
 └── Ninja (fast build executor)

Meson (generates Ninja files, written in Python)
 └── Ninja (fast build executor)

pkg-config (finds libraries for all of the above)
```

**Key concepts you'll learn in Phase 4:**
- **Self-hosting builds:** `make` builds `make`. CMake builds CMake. The new version is built by the old version.
- **The autotools pipeline:** `configure.ac` → autoconf → `configure` → `Makefile.in` → automake → `Makefile`. Now you know why running `autoreconf -i` is sometimes needed.
- **M4 macros:** The template language that generates `./configure`. AC_CHECK_LIB, AC_CHECK_HEADERS — these are M4 macros.
- **Why Meson and CMake exist:** Autotools is powerful but complex and slow. CMake (2000) and Meson (2013) are modern alternatives.
- **Ninja vs Make:** Make is smart (dependency tracking, rules). Ninja is dumb but fast (just executes what CMake/Meson tells it to).

**Source repositories:**
- Ninja: `https://github.com/ninja-build/ninja.git`
- pkg-config: `https://gitlab.freedesktop.org/pkg-config/pkg-config.git`
- Meson: `https://github.com/mesonbuild/meson.git`
- CMake: `https://github.com/Kitware/CMake.git`
- GNU Make: `https://git.savannah.gnu.org/git/make.git`
- Autoconf: `https://git.savannah.gnu.org/git/autoconf.git`
- Automake: `https://git.savannah.gnu.org/git/automake.git`
- Libtool: `https://git.savannah.gnu.org/git/libtool.git`
- M4: `https://git.savannah.gnu.org/git/m4.git`

---

## Phase 5: Compilers

**Hardware:** 16GB+ RAM recommended. 8GB minimum for GCC. Builds take 1-4 hours each.
**Time estimate:** Full phase ~10-15 hours.
**Status:** Not yet implemented.
**Prerequisites:** Phase 4 (understanding build systems). Phase 3 Level 5+ (Python, needed for LLVM tests).

Build the compilers themselves. This is where you learn about **bootstrapping** — a compiler is written in its own language, so you need an older version to compile the new one. You'll understand how source code becomes machine code.

| Level | Name | Tool | Bootstrap method | Time | What you learn |
|-------|------|------|-----------------|------|----------------|
| 0 | Pre-built | — | — | 0 | Compilers from apt/rustup |
| 1 | Go bootstrap | Go | apt's Go → new Go | ~15 min | Go is written in Go (since Go 1.5). Install apt's Go, use it to compile the latest Go source. Then you have a Go compiler you built yourself. Delete apt's Go if you want |
| 2 | Go deep | + rebuild std library | your Go | ~5 min | Rebuild Go's entire standard library with your compiled Go. Run the test suite. Understand how `go build` works internally: parsing → type checking → SSA → machine code |
| 3 | Rust stage0 | Rust (rustc) | download stage0 binary | ~2 hours | Rust bootstraps in 3 stages. Stage0: download a pre-built compiler. Stage1: use stage0 to compile rustc source → stage1 compiler. Stage2: use stage1 to compile rustc source again → stage2 (final). This ensures the compiler can compile itself |
| 4 | Rust full | + Cargo, rustfmt, clippy | stage2 rustc | ~30 min | Build the full Rust toolchain: package manager (cargo), formatter (rustfmt), linter (clippy). Understand how `rustup` manages multiple toolchains |
| 5 | GCC basic | GCC (C compiler only) | system GCC → new GCC | ~2 hours | The GNU C Compiler. 3-stage bootstrap like Rust: old GCC → stage1 GCC → stage2 GCC → stage3 GCC. Stages 2 and 3 should produce identical binaries (bootstrap verification). `./configure --enable-languages=c` |
| 6 | GCC full | + C++, Fortran frontends | your GCC | ~3 hours | Add more language frontends. GCC's architecture: frontend (parsing) → GIMPLE (IR) → RTL (low-level IR) → machine code. Each language has its own frontend but shares the optimizer and code generator |
| 7 | LLVM/Clang | LLVM + Clang | system GCC or Clang | ~3 hours | Alternative to GCC. LLVM's architecture: Clang (frontend) → LLVM IR → optimization passes → machine code. LLVM IR is the key insight — a portable intermediate representation. Used by Rust, Swift, Julia |
| 8 | Binutils | as, ld, objdump, readelf | `./configure && make` | ~15 min | The assembler (`as`) turns assembly into object files. The linker (`ld`) combines object files into executables. `objdump` disassembles binaries. These are the lowest-level tools in the compilation chain |
| 9 | GDB | GNU Debugger | `./configure && make` | ~20 min | The debugger. Understands DWARF debug info, ELF binary format, ptrace system call. Build it from source to understand how breakpoints and stack traces work |
| 10 | Full toolchain | Everything | — | ~8 hours | You compiled every compiler, assembler, linker, and debugger. You understand the full chain: source → preprocessor → compiler → assembler → linker → executable |

**The compilation pipeline:**
```
Source code (.c)
 │
 ├── Preprocessor (cpp)     — #include, #define, macro expansion
 │
 ├── Compiler (gcc/clang)   — C → assembly (.s)
 │   ├── Frontend           — parsing, type checking
 │   ├── Middle-end         — optimization (GIMPLE/LLVM IR)
 │   └── Backend            — register allocation, instruction selection
 │
 ├── Assembler (as)         — assembly → object file (.o)
 │
 ├── Linker (ld)            — object files → executable (ELF)
 │
 └── Executable             — machine code your CPU runs
```

**Key concepts you'll learn in Phase 5:**
- **Bootstrap problem:** The compiler is written in its own language. How do you compile the first compiler? Answer: cross-compile from another language, or use a pre-built binary as stage0.
- **3-stage bootstrap:** Old → Stage1 → Stage2 → Stage3. Compare Stage2 and Stage3 — if identical, the compiler correctly compiles itself.
- **Intermediate representations:** GIMPLE (GCC), LLVM IR (LLVM). The compiler doesn't go directly from C to machine code — it goes through IR, optimizes, then generates machine code.
- **GCC vs LLVM:** Different architectures, same job. GCC: monolithic. LLVM: modular library design.
- **ELF format:** The binary format on Linux. Headers, sections (.text for code, .data for data, .bss for uninitialized data), symbol tables.

**Source repositories:**
- Go: `https://go.googlesource.com/go` or `https://github.com/golang/go.git`
- Rust: `https://github.com/rust-lang/rust.git`
- GCC: `https://gcc.gnu.org/git/gcc.git`
- LLVM: `https://github.com/llvm/llvm-project.git`
- Binutils: `https://sourceware.org/git/binutils-gdb.git`
- GDB: (same repo as binutils)

---

## Phase 6: Core System

**Hardware:** VM or chroot REQUIRED. NEVER on your host system.
**Time estimate:** Full phase ~8-12 hours.
**Status:** Not yet implemented.
**Prerequisites:** Phase 5 (you have your own compiled toolchain). Phase 4 (you understand autotools/make).

**WARNING: Do NOT install these on your host system. A wrong glibc or systemd will brick your OS. Always use a VM, chroot, or container.**

Build the foundation your OS runs on. Every command you type, every program you run, depends on these components. This is the beginning of Linux From Scratch.

| Level | Name | Tool | What it provides | Time | What you learn |
|-------|------|------|-----------------|------|----------------|
| 0 | Pre-built | — | — | 0 | Use distro's everything |
| 1 | Coreutils | GNU coreutils | ls, cp, mv, rm, cat, echo, chmod, chown, mkdir, sort, uniq, wc, head, tail — 100+ commands | ~10 min | These ~100 commands are the building blocks of every shell script. They're all in one repo, one build. Each is a small C program. `cat` is ~200 lines of C |
| 2 | Text tools | + findutils, grep, sed, gawk | find, xargs, grep, sed, awk | ~15 min | The Unix text processing pipeline. `find \| xargs grep \| sed \| awk` — the pattern that makes Unix powerful. Each is a standalone C project with autotools |
| 3 | Shell | + bash | /bin/bash | ~10 min | Your shell is a C program (~140,000 lines). Parser, lexer, job control, signal handling, readline integration. When you type a command, bash: parses it → forks a process → exec's the binary → waits for exit |
| 4 | Compression | + gzip, bzip2, xz-utils, tar | gzip, bzip2, xz, tar | ~10 min | Compression algorithms implemented in C. gzip uses DEFLATE (LZ77 + Huffman coding). bzip2 uses Burrows-Wheeler. xz uses LZMA2. tar is just concatenation + metadata — compression is separate |
| 5 | C library | + glibc | libc.so, libm.so, libpthread.so, ld-linux.so | ~60 min | **The most important and dangerous build.** glibc is the C standard library — `printf()`, `malloc()`, `open()`, `fork()`, `exec()`. Every binary on your system links to it. The dynamic linker (`ld-linux.so`) loads shared libraries at runtime. **Installing a broken glibc = every program stops working** |
| 6 | Users & auth | + shadow | login, passwd, su, useradd, groupadd | ~5 min | User authentication. `passwd` reads your password, hashes it (SHA-512), stores it in `/etc/shadow`. `login` checks the hash. `su` changes your UID via `setuid()` system call. Security-critical code |
| 7 | System utils | + util-linux | mount, umount, fdisk, lsblk, dmesg, kill, more, hexdump | ~15 min | Low-level system utilities. `mount` attaches filesystems. `fdisk` partitions disks. `lsblk` lists block devices. These talk directly to the kernel via system calls and `/proc` / `/sys` |
| 8 | Simple init | + sysvinit or OpenRC | init (PID 1), rc scripts | ~10 min | The first process (PID 1). After the kernel boots, it runs `/sbin/init`. sysvinit runs shell scripts in `/etc/rc.d/`. OpenRC is a dependency-based init. Simple enough to understand fully |
| 9 | Systemd | + systemd | systemd, journald, udevd, logind, networkd | ~30 min | The modern init system. Meson build, 1.5M+ lines of C. Manages services, logging, devices, user sessions, networking. Controversial because of its scope, but understanding it means understanding modern Linux boot |
| 10 | Full userspace | Everything compiled | — | ~3 hours | You built the entire userspace from source. Every command, every library, every service between the kernel and your shell prompt |

**The boot sequence (what you're building):**
```
Power on
 │
 ├── BIOS/UEFI          — firmware, initializes hardware
 │
 ├── GRUB               — bootloader, loads kernel (Phase 7)
 │
 ├── Linux kernel       — initializes hardware, mounts root (Phase 7)
 │
 ├── initramfs          — temporary root, loads drivers (Phase 7)
 │
 ├── init (PID 1)       — systemd or sysvinit (Phase 6, Level 8-9)
 │   ├── udevd          — device manager
 │   ├── journald       — logging
 │   └── services       — networking, display manager, etc.
 │
 ├── glibc (libc.so)    — C library, loaded by every program (Phase 6, Level 5)
 │
 ├── coreutils          — ls, cp, cat, etc. (Phase 6, Level 1)
 │
 ├── bash               — your shell (Phase 6, Level 3)
 │
 └── Your prompt        — you're here
```

**Key concepts you'll learn in Phase 6:**
- **Everything is a file:** `/proc/cpuinfo`, `/dev/sda`, `/sys/class/net/`. Linux exposes kernel state as files.
- **Dynamic linking:** `ldd /bin/ls` shows that `ls` depends on `libc.so`, `libselinux.so`, etc. The dynamic linker loads them at runtime.
- **System calls:** User programs talk to the kernel via syscalls. `open()`, `read()`, `write()`, `fork()`, `exec()`, `mmap()`. glibc wraps these in C functions.
- **PID 1:** The init process. If it crashes, the kernel panics. It adopts orphaned processes. It's the ancestor of every process on the system.

**Source repositories:**
- GNU coreutils: `https://git.savannah.gnu.org/git/coreutils.git`
- findutils: `https://git.savannah.gnu.org/git/findutils.git`
- grep: `https://git.savannah.gnu.org/git/grep.git`
- sed: `https://git.savannah.gnu.org/git/sed.git`
- gawk: `https://git.savannah.gnu.org/git/gawk.git`
- bash: `https://git.savannah.gnu.org/git/bash.git`
- glibc: `https://sourceware.org/git/glibc.git`
- shadow: `https://github.com/shadow-maint/shadow.git`
- util-linux: `https://github.com/util-linux/util-linux.git`
- systemd: `https://github.com/systemd/systemd.git`

---

## Phase 7: OS Internals

**Hardware:** VM required. 8GB+ RAM. Dedicated disk/partition for LFS.
**Time estimate:** Full phase ~40-80 hours (LFS is a multi-day project).
**Status:** Not yet implemented.
**Prerequisites:** Phase 5 (you can build GCC), Phase 6 (you understand userspace).

Build the operating system itself. You'll compile the Linux kernel, create an initramfs, build a bootloader, and ultimately construct a complete bootable Linux system from source — Linux From Scratch.

| Level | Name | What you build | Time | What you learn |
|-------|------|---------------|------|----------------|
| 0 | Pre-built | — | 0 | Use distro kernel |
| 1 | Kernel default | Linux kernel with `defconfig` | ~30 min | `make defconfig && make -j$(nproc)`. You built a kernel! It's a 30M bzImage file. The kernel is ~28 million lines of C. `defconfig` selects reasonable defaults for your architecture |
| 2 | Kernel modules | Load a hello world `.ko` module | ~10 min | Write a C file with `module_init()` / `module_exit()`, compile with `make -C /lib/modules/$(uname -r)/build M=$PWD`. Load with `insmod`, check with `dmesg`. Your first kernel-space code |
| 3 | Kernel config | Kernel with `menuconfig` | ~45 min | `make menuconfig` — a text UI to select every kernel feature. Thousands of options: filesystem support, networking protocols, device drivers, security modules. Understand what CONFIG_* options do |
| 4 | Kernel optimized | Kernel tuned for your hardware | ~30 min | Strip unused drivers (you don't need SCSI, Firewire, or S390 support). Enable specific CPU optimizations. Measure boot time before/after. A custom kernel can be 5x smaller and boot faster |
| 5 | Initramfs | Custom initramfs with busybox | ~2 hours | The initramfs is a compressed cpio archive loaded into RAM at boot. It contains a minimal userspace (busybox) that loads kernel modules, mounts the root filesystem, then `exec`s `/sbin/init`. Write your own `init` script |
| 6 | Boot process | Trace the full boot sequence | ~2 hours | Understand every step: BIOS/UEFI → GRUB → kernel decompression → kernel init → initramfs → switch_root → systemd. Use `dmesg`, `systemd-analyze`, `bootchart`. Modify the init flow |
| 7 | GRUB | GRUB bootloader from source | ~1 hour | GRUB understands filesystems, loads the kernel, passes command-line arguments. Build it, install it to a disk image, boot from it in QEMU. Understand `grub.cfg`, GRUB modules, chainloading |
| 8 | LFS prep | Set up LFS build environment | ~4 hours | Follow Linux From Scratch Chapter 4-5. Create a new partition, set up a build user, cross-compile a temporary toolchain (binutils + GCC) that targets your new system. This temporary toolchain builds everything in the final system |
| 9 | LFS basic | Bootable Linux From Scratch | ~20 hours | Follow LFS Chapters 6-8. Build ~80 packages from source: glibc, binutils, GCC, coreutils, bash, kernel, GRUB. Configure networking, users, fstab. Boot into your system. You built Linux |
| 10 | LFS complete | LFS + BLFS extras | ~40 hours | Beyond LFS: add X11/Wayland, a window manager, a web browser, package management. A usable desktop system you built entirely from source code |

**Key concepts you'll learn in Phase 7:**
- **Kernel architecture:** Process scheduler, memory manager (virtual memory, page tables), VFS (Virtual File System), network stack, device model.
- **Kernel modules:** Loadable code that extends the kernel at runtime. Drivers are modules.
- **The boot process:** BIOS → bootloader → kernel → initramfs → userspace. Every step has a purpose.
- **Cross-compilation for LFS:** You build a cross-compiler on your host, use it to build a temporary system, then use that temporary system to build the final system. Three layers of bootstrapping.
- **Linux From Scratch:** The definitive project for understanding Linux. By building every package, you learn what each one does and why it's needed.

**Key resources:**
- Linux From Scratch book: https://www.linuxfromscratch.org/lfs/
- Beyond Linux From Scratch: https://www.linuxfromscratch.org/blfs/
- Linux kernel source: `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- GRUB: `https://git.savannah.gnu.org/git/grub.git`
- Busybox: `https://git.busybox.net/busybox`

---

## Phase 8: Networking & Drivers

**Hardware:** VM for development and testing. Optional: USB devices, Raspberry Pi, or other hardware for real driver testing.
**Time estimate:** Full phase ~30-50 hours.
**Status:** Not yet implemented.
**Prerequisites:** Phase 7 Levels 1-3 (kernel compilation and module basics).

Write kernel-space code. This is C programming inside the Linux kernel — no standard library, no memory protection, one bug = system crash. You'll write device drivers, filesystem modules, and network filters.

| Level | Name | What you build | Time | What you learn |
|-------|------|---------------|------|----------------|
| 0 | Pre-built | — | 0 | Use distro drivers |
| 1 | Hello kernel | Hello world module | ~2 hours | Write `hello_init()` that prints to kernel log. Compile as `.ko`, load with `insmod`, read with `dmesg`, unload with `rmmod`. Learn the module Makefile, `MODULE_LICENSE`, `module_init`/`module_exit` macros |
| 2 | Char device | Character device `/dev/mydevice` | ~4 hours | Register a character device with `register_chrdev()`. Implement `file_operations`: `open`, `read`, `write`, `release`. User programs can now `echo "hello" > /dev/mydevice` and `cat /dev/mydevice` |
| 3 | Procfs | /proc interface | ~3 hours | Create `/proc/myinfo` that shows custom data. Use `proc_create()` and `seq_file` interface. Understand how `/proc/cpuinfo`, `/proc/meminfo` work — they're kernel functions generating text on read |
| 4 | Sysfs | /sys interface | ~3 hours | Create sysfs attributes for your device. `DEVICE_ATTR` macro, `show`/`store` callbacks. This is how `lsblk`, `lsusb`, and other tools discover hardware — by reading `/sys/` |
| 5 | Netfilter | Packet filter module | ~5 hours | Hook into the kernel's network stack with `nf_register_net_hook()`. Inspect every incoming/outgoing packet. Build a simple firewall that drops packets by IP or port. This is how iptables/nftables work |
| 6 | Block device | RAM-backed block device | ~5 hours | Create a block device backed by kernel memory. Implement `submit_bio()` to handle read/write requests. You can `mkfs.ext4 /dev/myblock && mount /dev/myblock /mnt`. A filesystem on your virtual disk |
| 7 | Filesystem | Simple in-memory filesystem | ~8 hours | Implement VFS operations: `inode_operations`, `file_operations`, `super_operations`. Create files, directories, read, write. Understand how the kernel translates `open("/foo/bar")` into inode lookups |
| 8 | USB driver | USB device driver | ~8 hours | Interface with a real USB device (LED controller, USB-serial adapter, etc.). Use the USB subsystem: `usb_register()`, `usb_driver`, URBs (USB Request Blocks). Handle hot-plug events |
| 9 | Network driver | Virtual network interface | ~8 hours | Create a virtual network interface (`net_device`). Implement `ndo_start_xmit()` to send packets. Register with `register_netdev()`. You can `ip addr add 10.0.0.1/24 dev mynet` |
| 10 | Full driver | Production-quality driver | ~10 hours | Take one of the above and make it production-ready: proper error handling, `ioctl` interface, DMA transfers, interrupt handling with `request_irq()`, power management, sysfs attributes, documentation |

**Key concepts you'll learn in Phase 8:**
- **Kernel vs userspace:** No libc, no `printf`, no `malloc`. Use `printk()`, `kmalloc()`, `kfree()`. One bug = kernel oops or panic.
- **Concurrency in the kernel:** Spinlocks, mutexes, RCU, atomic operations. Multiple CPUs access your code simultaneously.
- **The device model:** Everything in Linux is a device. Devices have drivers. Drivers register with subsystems (USB, PCI, platform).
- **Virtual File System (VFS):** The abstraction layer between userspace (`open`, `read`, `write`) and filesystem implementations (ext4, btrfs, your custom fs).

**Key resources:**
- Linux Device Drivers 3rd Edition (free online): https://lwn.net/Kernel/LDD3/
- The Linux Kernel Module Programming Guide: https://sysprog21.github.io/lkmpg/
- Kernel source: `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`

---

## Phase 9: Cross-Compilation

**Hardware:** Laptop + QEMU. Optional: Raspberry Pi (~$35) or RISC-V board (~$60-80).
**Time estimate:** Full phase ~20-30 hours.
**Status:** Not yet implemented.
**Prerequisites:** Phase 5 (understanding compilers and toolchains), Phase 7 Levels 1-5 (kernel compilation).

Build software for architectures other than x86_64. Your laptop has an x86_64 CPU, but you'll generate binaries for ARM64 (phones, Raspberry Pi) and RISC-V (the open-source CPU architecture). Run them in QEMU or on real hardware.

| Level | Name | What you build | Time | What you learn |
|-------|------|---------------|------|----------------|
| 0 | Native | — | 0 | x86_64 only |
| 1 | QEMU | QEMU from source | ~30 min | Build the emulator. QEMU translates CPU instructions: your x86 machine runs ARM64 or RISC-V code by translating each instruction. Supports full system emulation (boot a kernel) or user-mode (run a single binary) |
| 2 | Cross intro | hello.c → ARM64 binary | ~2 hours | Install `gcc-aarch64-linux-gnu` (cross-compiler). `aarch64-linux-gnu-gcc hello.c -o hello`. Run with `qemu-aarch64 ./hello`. The binary contains ARM64 instructions, not x86 — `objdump -d` shows different assembly |
| 3 | Cross toolchain | Build GCC targeting ARM64 | ~3 hours | Build binutils + GCC configured with `--target=aarch64-linux-gnu`. Now you have a cross-compiler you built yourself. Understand sysroot, target triplets (arch-vendor-os), multilib |
| 4 | Cross app | Cross-compile ripgrep for ARM64 | ~2 hours | `cargo build --target aarch64-unknown-linux-gnu`. Cross-compilation with Rust is easier than C because Cargo handles sysroot configuration. Run the result in QEMU |
| 5 | RISC-V intro | hello.c → RISC-V binary | ~2 hours | Install `gcc-riscv64-linux-gnu`. Cross-compile for RISC-V. Run with `qemu-riscv64 ./hello`. Compare RISC-V assembly with ARM64 and x86 — RISC-V is simpler (fewer instructions, uniform encoding) |
| 6 | RISC-V toolchain | Build GCC targeting RISC-V | ~3 hours | Build a complete RISC-V cross-toolchain from source: binutils + GCC + glibc. `--target=riscv64-linux-gnu`. Now you can compile anything for RISC-V |
| 7 | RISC-V kernel | Cross-compile Linux for RISC-V | ~1 hour | `make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig && make`. Boot it in QEMU: `qemu-system-riscv64 -kernel arch/riscv/boot/Image`. You booted Linux on a different CPU architecture |
| 8 | RISC-V system | Kernel + busybox for RISC-V | ~3 hours | Cross-compile busybox, create an initramfs, boot a minimal RISC-V Linux in QEMU with a shell. `ls`, `cat`, `mount` all work — on a CPU architecture you don't physically have |
| 9 | RISC-V full | Full Linux system for RISC-V | ~8 hours | Cross-compile coreutils, bash, networking tools. A usable RISC-V Linux system running in QEMU with SSH access |
| 10 | Multi-arch | Multiple target architectures | ~5 hours | Build the same software for x86_64, ARM64, and RISC-V. Compare binary sizes, instruction counts, performance in QEMU. Understand what "architecture-independent" code means |

**Key concepts you'll learn in Phase 9:**
- **Target triplets:** `x86_64-pc-linux-gnu`, `aarch64-unknown-linux-gnu`, `riscv64-linux-gnu`. Format: `arch-vendor-os-abi`. The cross-compiler uses this to know what machine code to generate.
- **Sysroot:** The cross-compiler needs headers and libraries for the target architecture. The sysroot is a directory tree that mirrors `/usr/include` and `/usr/lib` for the target.
- **ISA differences:** x86_64 is CISC (Complex Instruction Set). ARM64 and RISC-V are RISC (Reduced Instruction Set). RISC-V is the simplest — designed to be taught and understood.
- **QEMU modes:** User-mode (run a single cross-compiled binary) vs system-mode (emulate an entire machine with CPU, RAM, devices).

**Source repositories:**
- QEMU: `https://gitlab.com/qemu-project/qemu.git`
- Busybox: `https://git.busybox.net/busybox`
- Linux kernel: `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`

---

## Phase 10: Bare Metal

**Hardware:** QEMU for emulation. RISC-V board ($60-80, e.g., StarFive VisionFive 2, Milk-V Duo) for real hardware.
**Time estimate:** Full phase ~100-200 hours (this is an OS development project).
**Status:** Not yet implemented.
**Prerequisites:** Phase 9 (RISC-V cross-compilation), Phase 8 (kernel programming), Phase 5 (understanding compilers/assemblers).

No operating system. No standard library. No safety net. Your code runs directly on the CPU. You write everything: bootloader, interrupt handlers, memory manager, process scheduler. By Level 10, you have a working operating system.

| Level | Name | What you build | Time | What you learn |
|-------|------|---------------|------|----------------|
| 0 | Concepts | Study the RISC-V ISA specification | ~5 hours | Read the RISC-V spec (free, open). Understand registers (x0-x31), instruction formats (R/I/S/B/U/J), addressing modes. RISC-V has ~50 base instructions — you can memorize them all |
| 1 | First assembly | Hello world in RISC-V assembly | ~5 hours | Write `.text` / `.globl _start`. Use `li` (load immediate), `ecall` (system call). Assemble with `riscv64-linux-gnu-as`, link with `ld`, run with `qemu-riscv64`. Your first hand-written machine code |
| 2 | Assembly programs | Loops, functions, stack operations | ~8 hours | `jal` (jump and link — function call), `sp` (stack pointer), calling conventions (a0-a7 for arguments, ra for return address). Write a function that computes fibonacci. Understand the stack frame |
| 3 | Bare-metal C | C without an OS | ~10 hours | Write `_start` in assembly that sets up the stack pointer and calls `main()`. Write `main()` in C. No `printf`, no `malloc` — you write your own. Link with `-nostdlib -nostartfiles`. Run on QEMU with `-machine virt` |
| 4 | UART driver | Serial I/O from bare metal | ~8 hours | The UART (Universal Asynchronous Receiver/Transmitter) is the simplest I/O device. Memory-mapped at a known address on QEMU's `virt` machine. Write bytes to the UART register to print to the console. Implement `putchar()` and `puts()` |
| 5 | Bootloader | Code that runs at power-on | ~15 hours | The CPU starts executing at a fixed address (0x80000000 on RISC-V). Your bootloader: disables interrupts, sets up the stack, initializes memory, loads the kernel from a known location, jumps to it. Understand machine mode (M-mode) vs supervisor mode (S-mode) |
| 6 | Interrupts | Trap and interrupt handling | ~15 hours | Set up the trap vector (`mtvec`/`stvec`). Handle timer interrupts (CLINT), external interrupts (PLIC), exceptions (page faults, illegal instructions). Write an interrupt service routine. Implement a timer that fires every 10ms |
| 7 | Memory | Virtual memory and paging | ~20 hours | Set up Sv39 page tables (3-level, 39-bit virtual address space). Map kernel memory, map user memory. Handle page faults. Implement `kmalloc()` and `kfree()`. Enable the MMU. Now every memory access goes through your page tables |
| 8 | Processes | Process scheduling | ~25 hours | Define a process struct (registers, page table, state). Implement context switching: save registers → switch page table → restore registers. Write a round-robin scheduler. Run two processes that print alternating lines. You have multitasking |
| 9 | Mini OS | Minimal OS with a shell | ~30 hours | Combine everything: boot → interrupts → memory → processes → filesystem (in-memory) → system calls → shell. Implement `fork()`, `exec()`, `wait()`, `exit()`. Write a simple shell that can run built-in commands. You have an operating system |
| 10 | Custom OS | Full OS on RISC-V | ~50 hours | Add: virtual filesystem, block device driver, networking (if brave), user/kernel separation, ELF loader. Run on real RISC-V hardware (not just QEMU). Your operating system, on a real CPU, running real programs |

**The layers you build (bottom to top):**
```
Level 10:  Shell & user programs    ← you wrote this
Level 9:   System calls (fork, exec, read, write)
Level 8:   Process scheduler        ← you wrote this
Level 7:   Virtual memory (paging)  ← you wrote this
Level 6:   Interrupt handling       ← you wrote this
Level 5:   Bootloader               ← you wrote this
Level 4:   UART driver              ← you wrote this
Level 3:   Bare-metal C runtime     ← you wrote this
Level 1-2: Assembly foundations     ← you wrote this
           Hardware (RISC-V CPU)    ← QEMU or real board
```

**Key concepts you'll learn in Phase 10:**
- **Privilege levels:** RISC-V has Machine mode (M), Supervisor mode (S), and User mode (U). Your bootloader runs in M-mode, your kernel in S-mode, user programs in U-mode.
- **Memory-mapped I/O:** Devices are accessed by reading/writing specific memory addresses. No special I/O instructions needed (unlike x86).
- **Page tables:** Virtual address → physical address translation. The MMU hardware walks your page table on every memory access.
- **Context switching:** Save all registers → switch stack pointer → switch page table → restore all registers. In ~50 lines of assembly, you switch between two completely isolated processes.
- **System calls:** User programs trap into the kernel via `ecall`. The kernel reads the syscall number from `a7`, dispatches to the handler, returns the result in `a0`.

**Key resources:**
- RISC-V ISA specification: https://riscv.org/technical/specifications/
- "Operating Systems: Three Easy Pieces" (free online): https://pages.cs.wisc.edu/~remzi/OSTEP/
- xv6-riscv (MIT's teaching OS): `https://github.com/mit-pdos/xv6-riscv`
- Blog: "Writing an OS in Rust" (concepts transfer): https://os.phil-opp.com/

**Recommended RISC-V hardware:**
- **Milk-V Duo** (~$8): Tiny, limited, good for blinking LEDs
- **StarFive VisionFive 2** (~$60-80): Full Linux-capable RISC-V board, good for running your OS
- **SiFive HiFive Unmatched** (~$500+, discontinued): Powerful, PCIe, good for serious development
- **QEMU** (free): `qemu-system-riscv64 -machine virt` emulates a RISC-V machine perfectly

---

## Hardware Requirements Summary

| Phase | What you need | Cost | Can do on laptop? |
|-------|-------------- |------|-------------------|
| 1 | Any machine | $0 | Yes |
| 2 | 8GB+ RAM, 16GB for Brave | $0 | Yes |
| 3 | Any machine | $0 | Yes |
| 4 | Any machine | $0 | Yes |
| 5 | 16GB+ RAM recommended | $0 | Yes, but slow |
| 6 | VM software (free: VirtualBox, QEMU) | $0 | Yes, in a VM |
| 7 | VM + 20GB+ free disk for LFS | $0 | Yes, in a VM |
| 8 | VM + optional USB devices | $0-20 | Yes, in a VM |
| 9 | QEMU (free) or ARM64/RISC-V board | $0-80 | Yes, with QEMU |
| 10 | QEMU (free) or RISC-V board | $0-80 | Yes, with QEMU |

**Everything can be done on a laptop with QEMU.** Real hardware (RISC-V board) makes Phase 10 more satisfying but is not required.

**Safety reminders:**
- Phases 6-7: NEVER install glibc, systemd, or a kernel on your host system. Use a VM.
- Phase 8: Buggy kernel modules can crash your VM (that's fine, that's learning). Never test on your host.
- Phase 10: Bare metal can't damage anything — your OS runs on QEMU or a separate board.

---

## The Full Dependency Chain

```
Phase 1:  Applications        — uses pre-built toolchains (apt, rustup, nvm)
Phase 2:  Desktop apps        — uses pre-built toolchains
Phase 3:  Runtimes            — uses pre-built compilers (gcc, go from apt)
Phase 4:  Build systems       — uses pre-built compilers
Phase 5:  Compilers           — bootstraps from system compiler (apt's gcc → your gcc)
Phase 6:  Core system         — uses your compiled toolchain (from Phase 5)
Phase 7:  OS internals        — uses your compiled userspace (from Phase 6)
Phase 8:  Drivers             — extends your compiled kernel (from Phase 7)
Phase 9:  Cross-compilation   — targets architectures you don't have
Phase 10: Bare metal          — no OS, no libraries, no safety net — just you and the CPU
```

Each phase peels back one more layer of abstraction. By Phase 10, there are no layers left — you understand the entire stack from transistors to `ls`.

---

## Estimated Total Time

| Phase | Estimated time (Level 10) |
|-------|--------------------------|
| 1 | ~90 min |
| 2 | ~6 hours |
| 3 | ~4 hours |
| 4 | ~2 hours |
| 5 | ~15 hours |
| 6 | ~12 hours |
| 7 | ~80 hours |
| 8 | ~50 hours |
| 9 | ~30 hours |
| 10 | ~200 hours |

**Total: ~400-500 hours to go from Level 0 to Phase 10 Level 10.**

That's roughly 3-6 months of evenings and weekends. Or a very intense university semester. By the end, you'll understand more about how computers work than most professional software engineers.
