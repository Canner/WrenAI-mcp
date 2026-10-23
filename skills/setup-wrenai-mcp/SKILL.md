---
name: setup-wrenai-mcp
description: "Set up WrenAI MCP server connection. Detects Node.js, configures .mcp.json with stdio proxy, and verifies the connection. Triggers on 'connect to wrenai', 'setup wrenai mcp', 'connect mcp', or 'wrenai mcp setup'."
---

<!-- AUTO-GENERATED from SKILL.md.tmpl for claude — do not edit directly -->

## Setup WrenAI MCP Connection

Configures the current project to connect to a WrenAI MCP server so the AI can
query data, generate SQL, run queries, build charts, and provide business insights.

### When to Use

- User wants to connect to a WrenAI instance
- User says "connect to wrenai", "setup mcp", "connect mcp"
- User needs to query their data through WrenAI

---

### Step 1 — Gather connection info

Ask the user for:

1. **WrenAI URL** — e.g. `http://localhost:3000` or `https://app.getwren.ai`
2. **Project ID** — the numeric project ID (visible in the WrenAI URL)
3. **Authentication** — one of:
   - **API key** (`sk-...`) — recommended for most setups
   - **None** — local dev with `MCP_SKIP_AUTH=true` on the server

Construct the MCP endpoint: `{url}/api/mcp/{project_id}`

---

### Step 2 — Check Node.js >= 20

The stdio proxy requires Node.js >= 20 (for native `https` module ESM support). Find a suitable `node` binary:

```bash
node --version
```

If not found, version < 20, or unpatched (see below), search common locations:
- `~/.nvm/versions/node/v2*/bin/node`
- `~/.volta/bin/node`
- `/usr/local/bin/node`
- `/opt/homebrew/bin/node`

Patched minimums: **22.23.4+, 24.22.1+, or 26.12.1+** (or a newer line). Older builds lack the security fixes from the [October 2026 Node.js security release](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases), and Node 20 gets no fix. Prefer a patched `node` from any of these locations. If every one found is >= 20 but unpatched (an older 22, 24, or 26 build, or a line with no fix such as 20, 23, or 25), continue with the newest and warn the user (do not block):
> Node.js vX.Y.Z lacks the October 2026 security fixes. Upgrade to 22.23.4+, 24.22.1+, or 26.12.1+.

If no Node.js >= 20 found, offer to install:
> You need Node.js >= 20 for the MCP proxy.
> - **nvm**: `nvm install 24`
> - **Direct**: download from https://nodejs.org

Record the **full absolute path** to `node` (e.g. `/Users/me/.nvm/versions/node/v24.22.1/bin/node`).

---

### Step 3 — Write MCP config

Write the following JSON to `.mcp.json` in the **project root**.

If the file already exists with other servers, **merge** — don't overwrite.

> **Note:** Claude Code's native HTTP transport auto-discovers OAuth and gets stuck
> if the server advertises `/.well-known/oauth-authorization-server`.
> Use the stdio proxy (`mcp-proxy.mjs`) to bypass this.

**Step 3a — Locate the proxy**

The `mcp-proxy.mjs` file ships with this plugin. Find its absolute path:

```bash
# If installed as a plugin, it's in the plugin directory:
ls "$(pwd)/mcp-proxy.mjs" 2>/dev/null || echo "Not found in current dir"
```

**Step 3b — Write `.mcp.json`**

**Without auth (local dev):**
```json
{
  "mcpServers": {
    "wrenai": {
      "type": "stdio",
      "command": "<node_path>",
      "args": [
        "<absolute_path_to>/mcp-proxy.mjs",
        "<endpoint_url>"
      ]
    }
  }
}
```

**With API key:**
```json
{
  "mcpServers": {
    "wrenai": {
      "type": "stdio",
      "command": "<node_path>",
      "args": [
        "<absolute_path_to>/mcp-proxy.mjs",
        "<endpoint_url>",
        "<api_key>"
      ]
    }
  }
}
```

For example:
```json
{
  "mcpServers": {
    "wrenai": {
      "type": "stdio",
      "command": "/Users/me/.nvm/versions/node/v24.22.1/bin/node",
      "args": [
        "/Users/me/wrenai-mcp/mcp-proxy.mjs",
        "https://app.getwren.ai/api/mcp/123",
        "sk-abc123"
      ]
    }
  }
}
```

**IMPORTANT:** Do NOT use `--transport http` or `type: "http"` — Claude Code's HTTP transport auto-discovers OAuth endpoints and fails if the server exposes one. The stdio proxy bypasses this entirely.

---

### Step 4 — Verify & next steps

Tell the user:

> WrenAI MCP config written to `.mcp.json`.
>
> **Next steps:**
> 1. **Restart Claude Code** to activate the connection (config changes require a restart)
> 2. After restarting, try: `/wrenai-analyst how many records do I have?`
>
> The `wrenai-analyst` skill is available for data analysis, SQL generation, and charting.

---

### Step 5 — Troubleshooting

If the connection fails:

| Issue | Fix |
|-------|-----|
| "Failed to reconnect" | Fully restart the agent — `/mcp` reconnect uses cached config |
| 401 Unauthorized | Check API key, or set `MCP_SKIP_AUTH=true` on the WrenAI server |
| Node.js version error | The proxy needs Node >= 20, ideally a patched 22.23.4+, 24.22.1+, or 26.12.1+ (October 2026 Node.js security release) — check the `command` path |
| Connection refused | Verify WrenAI is running at the specified URL |
| OAuth timeout (HTTP transport) | Do NOT use `type: "http"` — use the stdio proxy to bypass OAuth discovery |
| "Token expired without refresh token" | Remove any stale server config from `~/.claude.json` with `claude mcp remove wrenai -s local` |

---

### Claude Desktop setup

The same config works for Claude Desktop. The config file location:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

Use the same `command`/`args` structure as `.mcp.json`. The `mcp-proxy.mjs` path
must be absolute.
