---
name: setup-wrenai-mcp
description: "Set up WrenAI MCP server connection. Detects Node.js, installs mcp-remote bridge, configures .mcp.json, and verifies the connection. Triggers on 'connect to wrenai', 'setup wrenai mcp', 'connect mcp', or 'wrenai mcp setup'."
---

## Setup WrenAI MCP Connection

Configures the current project to connect to a WrenAI MCP server so the AI can
query data, generate SQL, run queries, build charts, and provide business insights.

### When to Use

- User wants to connect Claude to a WrenAI instance
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

### Step 3 — Write .mcp.json

Create or update `.mcp.json` in the **project root** (current working directory).

If `.mcp.json` already exists with other servers, **merge** — don't overwrite.

**Without auth (local dev):**
```json
{
  "mcpServers": {
    "wrenai": {
      "command": "<npx_full_path>",
      "args": [
        "mcp-remote",
        "<endpoint_url>"
      ],
      "env": {
        "PATH": "<node_bin_dir>:/usr/bin:/bin"
      }
    }
  }
}
```

**With API key:**
```json
{
  "mcpServers": {
    "wrenai": {
      "command": "<npx_full_path>",
      "args": [
        "mcp-remote",
        "<endpoint_url>",
        "--header",
        "Authorization: Bearer <api_key>"
      ],
      "env": {
        "PATH": "<node_bin_dir>:/usr/bin:/bin"
      }
    }
  }
}
```

**IMPORTANT:** `.mcp.json` only supports `command`/`args` (stdio) format.
Do NOT use `type: "streamable-http"` or `type: "sse"` — these are not supported.

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
| "Failed to reconnect" | Fully restart Claude Code, not just `/mcp` reconnect |
| 401 Unauthorized | Check API key, or set `MCP_SKIP_AUTH=true` on the WrenAI server |
| Node.js version error | `mcp-remote` needs Node >= 20 — check the `command` path |
| Connection refused | Verify WrenAI is running at the specified URL |
| "Authentication successful but reconnection failed" | Restart Claude Code completely |

---

### Claude Desktop setup

The same config works for Claude Desktop. The config file location:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

Use the same `command`/`args`/`env` structure as `.mcp.json`.
