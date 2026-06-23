# Security Lab Setup

The Fedora setup now installs a learning-oriented security lab without putting every offensive tool directly on the host.

## Host tools

- `semgrep` is installed with `uv tool install semgrep`.
- `codeql` is installed from GitHub's Linux CodeQL bundle into `~/.local/codeql`.
- `ghidraRun` is linked when an existing Ghidra install is found.

## Isolated wrappers

- `nuclei-docker` runs `projectdiscovery/nuclei:latest` with the current directory mounted at `/work`.
- `aflpp-docker` runs `aflplusplus/aflplusplus:latest` with the current directory mounted at `/src`.
- `snyk-agent-scan-safe` uses `uvx snyk-agent-scan@latest` and warns before execution because MCP/tool configs can execute commands.

## Proxy tools

Caido and Burp Suite are checked and given project directories under `~/hacking/proxy/`, but the script does not silently install extensions, tokens, licenses, or app-side MCP credentials.

## MCP repos

- Ghidra MCP is cloned to `~/hacking/tools/ghidra-mcp`.
- AFL++ MCP is cloned to `~/hacking/tools/aflpp-mcp` and built when Node is available.
- OSS-Fuzz-Gen is cloned to `~/hacking/tools/oss-fuzz-gen`.

Register MCP servers only after reviewing their configs and permissions.
