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
      "command": "/Users/me/.nvm/versions/node/v20.20.1/bin/node",
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
