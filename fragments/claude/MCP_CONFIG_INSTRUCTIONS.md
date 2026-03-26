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