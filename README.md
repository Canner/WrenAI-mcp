# WrenAI MCP Plugin

Connect AI agents to [WrenAI](https://getwren.ai) — query your data, generate SQL, build charts, and get business insights using natural language.

```
AI Agent ←→ MCP ←→ WrenAI Server
                    ├── get_project_metadata
                    ├── ask (end-to-end Q&A)
                    ├── generate_sql
                    ├── run_sql
                    ├── generate_chart (VegaSpec)
                    └── generate_summary
```

## Requirements

- A running WrenAI instance with MCP enabled
- **Web platforms** (claude.ai, ChatGPT): just your WrenAI account (OAuth login)
- **CLI / code editors** (Claude Code, Claude Desktop): Node.js >= 20 for the stdio proxy + API key or local dev mode (`MCP_SKIP_AUTH=true`)
- **Other CLI** (Codex, Kiro): Node.js >= 18 for the `mcp-remote` bridge + API key

---

## Install by Platform

### 1. Claude Code (CLI)

> **Note:** Claude Code's HTTP transport auto-discovers OAuth and hangs if the server
> advertises `/.well-known/oauth-authorization-server`. The stdio proxy bypasses this.

```bash
# Step 1: Clone the plugin
git clone https://github.com/canner/wrenai-mcp.git
cd wrenai-mcp

# Step 2: Add MCP server (stdio proxy with API key)
#   Replace {node_path} with your Node.js >= 20 binary (e.g. ~/.nvm/versions/node/v20.20.1/bin/node)
#   Replace {your_project_id} and {your_api_key} with your WrenAI credentials
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "wrenai": {
      "type": "stdio",
      "command": "{node_path}",
      "args": [
        "{absolute_path_to_repo}/mcp-proxy.mjs",
        "https://app.getwren.ai/api/mcp/{your_project_id}",
        "{your_api_key}"
      ]
    }
  }
}
EOF

# Step 3: Restart Claude Code

# Step 4 (optional): Install the data analyst skill plugin
/install canner/wrenai-mcp
```

Generate an API key in your [WrenAI project settings](https://app.getwren.ai).

Done. Try `/wrenai-analyst tell me about my data`

---

### 2. claude.ai (Web)

Add MCP connector + create skill. Auth is handled via OAuth.

**Step 1 — Add MCP Connector:**

1. Go to **Settings → Connectors → Go to Customize -> click + icon -> add custom connector**
2. Name: `wrenai`
3. URL: `https://app.getwren.ai/api/mcp/{your_project_id}`
4. Auth: OAuth (you'll be redirected to log in with your WrenAI account)

**Step 2 — Upload Skill:**

1. Go to **Settings → Skills → Upload Skill**
2. Upload `web/claude/wrenai-analyst/SKILL.md`

> Generate the skill files locally: `git clone https://github.com/canner/wrenai-mcp.git && cd wrenai-mcp && ./setup --host web`

---

### 3. Claude Desktop

**2 steps.** Edit MCP config + add skill to project. Uses the stdio proxy to bypass OAuth discovery.

**Step 1 — Add MCP Server:**

Clone the plugin: `git clone https://github.com/canner/wrenai-mcp.git`

Edit `claude_desktop_config.json`:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "wrenai": {
      "command": "{node_path}",
      "args": [
        "{absolute_path_to_repo}/mcp-proxy.mjs",
        "https://app.getwren.ai/api/mcp/{your_project_id}",
        "{your_api_key}"
      ]
    }
  }
}
```

**Step 2 — Add Skill:**

1. Open a **Project → Project Knowledge → Upload Skill**
2. Upload `web/claude/wrenai-analyst/SKILL.md`

---

### 4. ChatGPT

Add MCP connector + set up custom instructions. Auth is handled via OAuth.

**Step 1 — Enable Developer Mode & Add MCP Connector:**

1. Go to **Settings → Apps & Connectors → Advanced settings**
2. Enable **Developer Mode**
3. Back to **Apps & Connectors**, click **Add** → **Add MCP server**
4. Name: `wrenai`
5. URL: `https://app.getwren.ai/api/mcp/{your_project_id}`
6. Auth: OAuth (you'll be redirected to log in with your WrenAI account)

**Step 2 — Add Custom Instructions:**

1. Go to **Settings → Personalization → Custom Instructions**
2. Paste the content from [`web/chatgpt/wrenai-analyst-skill.md`](./web/chatgpt/wrenai-analyst-skill.md)

> Generate the skill content locally: `git clone https://github.com/canner/wrenai-mcp.git && cd wrenai-mcp && ./setup --host chatgpt`
>
> See [ChatGPT Developer Mode & MCP docs](https://help.openai.com/en/articles/12584461-developer-mode-apps-and-full-mcp-connectors-in-chatgpt-beta) for details.

---

### 5. Codex (OpenAI)

**2 steps.** Clone + setup, then configure MCP.

```bash
# Step 1: Install skills
git clone https://github.com/canner/wrenai-mcp.git .agents/skills/wrenai-mcp
cd .agents/skills/wrenai-mcp && ./setup --host codex
```

**Step 2 — Add MCP config** to `codex.json` in project root:

```json
{
  "mcpServers": {
    "wrenai": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://app.getwren.ai/api/mcp/{your_project_id}",
        "--header",
        "Authorization: Bearer {your_api_key}"
      ]
    }
  }
}
```

---

### 6. Kiro

**2 steps.** Clone + setup, then configure MCP.

```bash
# Step 1: Install skills
git clone https://github.com/canner/wrenai-mcp.git ~/wrenai-mcp
cd ~/wrenai-mcp && ./setup --host kiro
```

**Step 2 — Add MCP config** to `.kiro/settings/mcp.json` in project root:

```json
{
  "mcpServers": {
    "wrenai": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://app.getwren.ai/api/mcp/{your_project_id}",
        "--header",
        "Authorization: Bearer {your_api_key}"
      ]
    }
  }
}
```

---

## Skills

| Skill | Description |
|-------|-------------|
| `setup-wrenai-mcp` | One-time setup — connects your agent to a WrenAI instance |
| `wrenai-analyst` | Data analyst — SQL, charts, insights from natural language |

## Platform Summary

| Platform | MCP Setup | Skill Setup | Steps |
|----------|-----------|-------------|-------|
| **Claude Code** | `.mcp.json` (stdio proxy + API key) | Plugin: `/install canner/wrenai-mcp` | 3 |
| **claude.ai** | Connectors UI (OAuth) | Skills UI (paste content) | 2 |
| **Claude Desktop** | Edit `claude_desktop_config.json` (stdio proxy) | Project Knowledge | 2 |
| **ChatGPT** | Developer Mode → Add MCP Connector | Custom Instructions (paste content) | 2 |
| **Codex** | Edit `codex.json` | `git clone` + `./setup --host codex` | 2 |
| **Kiro** | Edit `.kiro/settings/mcp.json` | `git clone` + `./setup --host kiro` | 2 |

## Add to your repo (optional)

Let teammates use the skills without installing:

```bash
# For Claude Code — clone into project and configure .mcp.json
git clone https://github.com/canner/wrenai-mcp.git .claude/plugins/wrenai-mcp
# Then add the .mcp.json config as shown in section 1 above

# For Codex / Cursor
git clone https://github.com/canner/wrenai-mcp.git .agents/skills/wrenai-mcp
cd .agents/skills/wrenai-mcp && ./setup --host codex
```
