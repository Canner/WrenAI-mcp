Create or update `codex.json` in the **project root**.

If the file already exists with other servers, **merge** — don't overwrite.

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

**With API key**, add `"--header", "Authorization: Bearer <api_key>"` to `args`.