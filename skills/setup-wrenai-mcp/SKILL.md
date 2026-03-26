---
name: setup-wrenai-mcp
description: "Set up WrenAI MCP server connection. Detects Node.js, installs mcp-remote bridge, configures .mcp.json, and verifies the connection. Triggers on 'connect to wrenai', 'setup wrenai mcp', 'connect mcp', or 'wrenai mcp setup'."
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

The `mcp-remote` bridge requires Node.js >= 20. Find a suitable binary:

```bash
node --version
```

If not found or version < 20, search common locations:
- `~/.nvm/versions/node/v2*/bin/npx`
- `~/.volta/bin/npx`
- `/usr/local/bin/npx`
- `/opt/homebrew/bin/npx`

If no Node.js >= 20 found, offer to install:
> You need Node.js >= 20 for the MCP bridge.
> - **nvm**: `nvm install 20`
> - **Direct**: download from https://nodejs.org

Record the **full absolute path** to `npx` (e.g. `/Users/me/.nvm/versions/node/v20.20.1/bin/npx`).
Also record the `bin` directory for the `PATH` env var.

---

### Step 3 — Write MCP config

Register the WrenAI MCP server using the Claude Code CLI.

> **Note:** Claude Code's native HTTP transport has a known bug (#29688).
> Use the stdio bridge workaround below until it's fixed.

**Step 1 — Generate an API key** in WrenAI project settings if you don't have one.

**Step 2 — Run this command:**

```bash
claude mcp add --transport stdio --scope project wrenai -- \
  npx mcp-remote <endpoint_url> \
  --header "Authorization: Bearer <api_key>"
```

For example:
```bash
claude mcp add --transport stdio --scope project wrenai -- \
  npx mcp-remote https://app.getwren.ai/api/mcp/123 \
  --header "Authorization: Bearer sk-abc123"
```

**Step 3 — Restart Claude Code** to activate the connection.

**Scope options:**
- `project` (recommended) — shared with teammates via `.mcp.json`
- `local` — only you, only this project
- `user` — available across all your projects

**IMPORTANT:** Do NOT use `--transport http` directly — it has a known bug (#29688) that prevents MCP session establishment. The stdio bridge via `mcp-remote` is the workaround.

---

### Step 4 — Verify & next steps

Tell the user:

> WrenAI MCP config written to `.mcp.json`.
>
> **Next steps:**
> 1. Restart Claude Code (or run `/mcp` → Reconnect) to activate the connection
> 2. After reconnecting, try: `/wrenai-analyst how many records do I have?`
>
> The `wrenai-analyst` skill is available for data analysis, SQL generation, and charting.

---

### Step 5 — Troubleshooting

If the connection fails:

| Issue | Fix |
|-------|-----|
| "Does not adhere to MCP server configuration schema" | Must use `command`/`args` format, not `type: streamable-http` |
| "Failed to reconnect" | Fully restart the agent |
| 401 Unauthorized | Check API key, or set `MCP_SKIP_AUTH=true` on the WrenAI server |
| Node.js version error | `mcp-remote` needs Node >= 20 — check the `command` path |
| Connection refused | Verify WrenAI is running at the specified URL |
| "Authentication successful but reconnection failed" | Restart the agent completely |

---

### Claude Desktop setup

The same config works for Claude Desktop. The config file location:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

Use the same `command`/`args`/`env` structure as `.mcp.json`.
