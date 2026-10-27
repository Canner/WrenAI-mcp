#!/usr/bin/env bash
set -euo pipefail

# ─── Colors & helpers ────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()  { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
warn()  { printf "  ${YELLOW}!${NC} %s\n" "$1"; }
fail()  { printf "\n  ${RED}✗${NC} %s\n\n" "$1"; exit 1; }
ask()   { printf "  ${CYAN}?${NC} %s" "$1"; }

# ─── Header ──────────────────────────────────────────────────────
echo ""
printf "  ${BOLD}WrenAI MCP — Claude Code Installer${NC}\n"
echo "  ==================================="
echo ""

# ─── Guard: needs interactive terminal ───────────────────────────
if [ ! -t 0 ]; then
  fail "Interactive terminal required.
    Run:  bash <(curl -fsSL https://raw.githubusercontent.com/canner/wrenai-mcp/main/install.sh)"
fi

# ─── Step 1: Node.js ────────────────────────────────────────────
printf "  ${BOLD}[1/4] Checking Node.js ...${NC}\n"

# First patched release on each supported line, oldest line first. Update all three on the next advisory.
NODE_PATCHED="22.23.4 24.22.1 26.12.1"
NODE_ADVISORY="October 2026"
NODE_ADVISORY_URL="https://nodejs.org/en/blog/vulnerability/october-2026-security-releases"

# "22.23.4+, 24.22.1+, or 26.12.1+"
NODE_PATCHED_LIST=""
node_patched_count=$(echo $NODE_PATCHED | wc -w)
node_patched_i=0
for v in $NODE_PATCHED; do
  node_patched_i=$((node_patched_i + 1))
  if [ "$node_patched_i" -eq 1 ]; then NODE_PATCHED_LIST="$v+"
  elif [ "$node_patched_i" -lt "$node_patched_count" ]; then NODE_PATCHED_LIST="$NODE_PATCHED_LIST, $v+"
  elif [ "$node_patched_count" -eq 2 ]; then NODE_PATCHED_LIST="$NODE_PATCHED_LIST or $v+"
  else NODE_PATCHED_LIST="$NODE_PATCHED_LIST, or $v+"
  fi
done

# 24.22.1 -> 24022001
version_num() {
  local major minor patch
  IFS=. read -r major minor patch _ <<< "${1%%[-+]*}"
  major=${major//[^0-9]/} minor=${minor//[^0-9]/} patch=${patch//[^0-9]/}
  echo $(( 10#${major:-0} * 1000000 + 10#${minor:-0} * 1000 + 10#${patch:-0} ))
}

# Succeeds when the version is at or above its line's NODE_PATCHED floor.
node_has_security_fixes() {
  local have major floor fix newest="${NODE_PATCHED##* }" release="${1%%+*}"
  have=$(version_num "$1")
  major=$(( have / 1000000 ))
  for floor in $NODE_PATCHED; do
    [ "$major" -eq "${floor%%.*}" ] || continue
    fix=$(version_num "$floor")
    # X.Y.Z-pre sorts before X.Y.Z and lacks the embargoed fixes.
    [ "$have" -gt "$fix" ] || { [ "$have" -eq "$fix" ] && [ "$release" = "${release%%-*}" ]; }
    return
  done
  [ "$major" -gt "${newest%%.*}" ]
}

NODE_CMD=""
if command -v node &>/dev/null; then
  NODE_VERSION=$(node -v | sed 's/v//')
  MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
  if [ "$MAJOR" -ge 18 ]; then
    NODE_CMD=$(command -v node)
    info "Node.js v${NODE_VERSION} — ${DIM}${NODE_CMD}${NC}"
    if ! node_has_security_fixes "$NODE_VERSION"; then
      warn "Node.js v${NODE_VERSION} lacks the ${NODE_ADVISORY} security fixes. Upgrade to ${NODE_PATCHED_LIST}.
    ${NODE_ADVISORY_URL}"
    fi
  else
    fail "Node.js v${NODE_VERSION} found but >= 18 is required.
    Install Node.js ${NODE_PATCHED_LIST}: https://nodejs.org"
  fi
else
  fail "Node.js not found.
    Install Node.js ${NODE_PATCHED_LIST}: https://nodejs.org"
fi

# ─── Step 2: Locate repo ────────────────────────────────────────
echo ""
printf "  ${BOLD}[2/4] Locating wrenai-mcp ...${NC}\n"

REPO_DIR=""

# Try: script's own directory (./install.sh)
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || true
fi
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/mcp-proxy.mjs" ]; then
  REPO_DIR="$SCRIPT_DIR"
fi

# Try: current directory
if [ -z "$REPO_DIR" ] && [ -f "$(pwd)/mcp-proxy.mjs" ]; then
  REPO_DIR="$(pwd)"
fi

# Try: ./wrenai-mcp subdirectory
if [ -z "$REPO_DIR" ] && [ -f "$(pwd)/wrenai-mcp/mcp-proxy.mjs" ]; then
  REPO_DIR="$(pwd)/wrenai-mcp"
fi

if [ -n "$REPO_DIR" ]; then
  info "Found at ${REPO_DIR}"
else
  warn "Not found in current directory."
  echo ""
  echo "    1) Clone into ./wrenai-mcp  ${DIM}(recommended)${NC}"
  echo "    2) Enter path to existing clone"
  echo ""
  ask "Choose [1/2] (default 1): "
  read -r REPO_CHOICE
  REPO_CHOICE="${REPO_CHOICE:-1}"

  if [ "$REPO_CHOICE" = "2" ]; then
    ask "Path: "
    read -r CUSTOM_PATH
    CUSTOM_PATH="${CUSTOM_PATH/#\~/$HOME}"
    CUSTOM_PATH="${CUSTOM_PATH%/}"
    [ -f "$CUSTOM_PATH/mcp-proxy.mjs" ] || fail "mcp-proxy.mjs not found at ${CUSTOM_PATH}"
    REPO_DIR="$CUSTOM_PATH"
  else
    echo ""
    echo "  Cloning ..."
    git clone --depth 1 https://github.com/canner/wrenai-mcp.git "$(pwd)/wrenai-mcp"
    REPO_DIR="$(pwd)/wrenai-mcp"
  fi
  info "Repository at ${REPO_DIR}"
fi

PROXY_PATH="${REPO_DIR}/mcp-proxy.mjs"

# Final check: mcp-proxy.mjs must exist
if [ ! -f "$PROXY_PATH" ]; then
  fail "mcp-proxy.mjs not found at ${PROXY_PATH}
    The repo may be incomplete. Try re-cloning:
    git clone https://github.com/canner/wrenai-mcp.git"
fi
info "Proxy: ${DIM}${PROXY_PATH}${NC}"

# ─── Step 3: Credentials ────────────────────────────────────────
echo ""
printf "  ${BOLD}[3/4] WrenAI credentials${NC}\n"
echo ""
printf "  Open ${CYAN}WrenAI → Settings → API${NC} to find:\n"
echo "    • MCP URL  — looks like https://app.getwren.ai/api/mcp/cm..."
echo "    • API Key  — create one under API Keys"
echo ""

ask "MCP endpoint URL: "
read -r MCP_URL
[ -n "$MCP_URL" ] || fail "MCP URL is required."

echo ""
ask "API Key (input hidden): "
read -rs API_KEY
echo ""
[ -n "$API_KEY" ] || fail "API Key is required."

# Show masked key for confirmation
MASKED="${API_KEY:0:4}...${API_KEY: -4}"
printf "  ${DIM}  → key: %s${NC}\n" "$MASKED"

# ─── Step 4: Configure ──────────────────────────────────────────
echo ""
printf "  ${BOLD}[4/4] Configuring Claude Code ...${NC}\n"
echo ""
echo "    1) Global  — available in all projects ${DIM}(recommended)${NC}"
echo "    2) Project — only in current directory"
echo ""
ask "Scope [1/2] (default 1): "
read -r SCOPE_CHOICE
SCOPE_CHOICE="${SCOPE_CHOICE:-1}"

if [ "$SCOPE_CHOICE" = "2" ]; then
  SCOPE="project"
else
  SCOPE="user"
fi

if command -v claude &>/dev/null; then
  # Use the official CLI — handles config merging automatically
  claude mcp remove wrenai --scope "$SCOPE" 2>/dev/null || true
  claude mcp add wrenai --scope "$SCOPE" -t stdio -- \
    "$NODE_CMD" "$PROXY_PATH" "$MCP_URL" "$API_KEY"
  info "MCP server registered  ${DIM}(scope: ${SCOPE})${NC}"
else
  # Fallback: write .mcp.json with proper merging
  warn "'claude' CLI not in PATH — writing .mcp.json instead"

  if [ "$SCOPE" = "project" ]; then
    CONFIG_FILE="$(pwd)/.mcp.json"
  else
    mkdir -p "$HOME/.claude"
    CONFIG_FILE="$HOME/.claude/.mcp.json"
  fi

  # Use Node.js for safe JSON merging (handles special chars in API key)
  "$NODE_CMD" -e "
    const fs = require('fs');
    const p  = process.argv[1];
    let cfg  = {};
    try { cfg = JSON.parse(fs.readFileSync(p, 'utf8')); } catch {}
    cfg.mcpServers = cfg.mcpServers || {};
    cfg.mcpServers.wrenai = {
      type: 'stdio',
      command: process.argv[2],
      args: [process.argv[3], process.argv[4], process.argv[5]]
    };
    fs.writeFileSync(p, JSON.stringify(cfg, null, 2) + '\n');
  " "$CONFIG_FILE" "$NODE_CMD" "$PROXY_PATH" "$MCP_URL" "$API_KEY"

  info "Config written to ${CONFIG_FILE}"
fi

# ─── Done ────────────────────────────────────────────────────────
echo ""
printf "  ${GREEN}${BOLD}Setup complete!${NC}\n"
echo ""
echo "  Next steps:"
echo "    1. Restart Claude Code (or open a new session)"
echo "    2. Optionally install the analyst skill:"
printf "       ${CYAN}/install canner/wrenai-mcp${NC}\n"
echo "    3. Try it out:"
printf "       ${CYAN}/wrenai-analyst tell me about my data${NC}\n"
echo ""
