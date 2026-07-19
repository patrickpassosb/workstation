# Security Lab Setup

The setup installs a learning-oriented security lab without putting every offensive tool directly on the host.

## Host tools

- `semgrep` is installed with `uv tool install semgrep`.
- `codeql` is installed from GitHub's Linux CodeQL bundle into `~/.local/codeql`.
- `ghidraRun` is linked when an existing Ghidra install is found.

## Isolated wrappers

- `nuclei-docker` runs `projectdiscovery/nuclei:latest` with the current directory mounted at `/work`.
- `aflpp-docker` runs `aflplusplus/aflplusplus:latest` with the current directory mounted at `/src`.
- `snyk-agent-scan-safe` uses `uvx snyk-agent-scan@latest` and warns before execution because MCP/tool configs can execute commands.

### Network egress (`LAB_RELAXED=1`)

By default the wrappers run on the `lab-none` internal Docker network
(no internet egress). This prevents a compromised tool from phoning
home with your data. Some workflows need egress — e.g. an AFL++
plugin that fetches an LLVM pass from GitHub, or `nuclei -t templates`
which needs to update its template repo. To opt into egress for a
single invocation:

```bash
LAB_RELAXED=1 aflpp-docker afl-fuzz ...
LAB_RELAXED=1 nuclei-docker -t templates
```

The wrapper prints a `[WARN]` to stderr when egress is enabled so you
don't enable it by accident.

### `SNYK_TOKEN`

`snyk-agent-scan-safe` only authenticates if you export a `SNYK_TOKEN`
env var. Without it, the wrapper still runs but the underlying
`snyk-agent-scan` CLI will report unauthenticated. Generate a token
from your Snyk account and `export SNYK_TOKEN=...` in the shell where
you invoke the wrapper (don't commit it — `.gitignore` blocks the
common secret file patterns).

## Proxy tools

Caido and Burp Suite are checked and given project directories under
`~/hacking/proxy/`, but the script does not silently install
extensions, tokens, licenses, or app-side MCP credentials.

## MCP repos

- Ghidra MCP is cloned to `~/hacking/tools/ghidra-mcp`. Pin to a
  specific commit with `GHIDRA_MCP_COMMIT=<sha>` before running
  `tools/ghidra.sh`.
- AFL++ MCP is cloned (with submodules) to `~/hacking/tools/aflpp-mcp`
  and built when Node is available. Pin to a specific commit with
  `AFLPP_MCP_COMMIT=<sha>`. Submodules are re-initialized after the
  pin is checked out.
- OSS-Fuzz-Gen is cloned to `~/hacking/tools/oss-fuzz-gen`.

Register MCP servers only after reviewing their configs and
permissions. `configs/lab-mcp-consent.sh` walks you through the
registered MCPs and prints the registration commands for the ones
you approve — it never auto-registers.

### Docker image pinning

The wrappers default to mutable `:latest` Docker tags. For
reproducibility, pin a specific image digest:

```bash
export NUCLEI_DOCKER_IMAGE='projectdiscovery/nuclei:3.3.0@sha256:...'
export AFLPP_DOCKER_IMAGE='aflplusplus/aflplusplus:v4.30c@sha256:...'
```

The installers log the resolved digest of whatever image they pull so
you can copy it into the env var above.
