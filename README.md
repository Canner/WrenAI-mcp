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
- **Web / desktop** (claude.ai, Claude Desktop, ChatGPT): just your WrenAI account (OAuth login)
- **CLI** (Claude Code): Node.js >= 18 for the stdio proxy + WrenAI API key

---

## Install by Platform

### 1. claude.ai (Web) and Claude Desktop(chat/cowork/code)

Add MCP connector + create skill. Auth is handled via OAuth.

**Step 1 — Add MCP Connector:**

1. Go to **Customize → Connectors → Add custom connector**
2. Give a name to your mcp
3. URL: Copy your project MCP url in wrenai. 
4. Auth: OAuth (you'll be redirected to log in with your WrenAI account)

**Step 2 — Upload Skill:**

1. Open a **Customize → Skills → Create a skill → Upload a skill**
2. Upload `web/claude/wrenai-analyst/SKILL.md`

> Generate the skill files locally: `git clone https://github.com/canner/wrenai-mcp.git && cd wrenai-mcp && ./setup --host web`

---


### 2. Claude Code (CLI)

Clone the repo, run the installer, and install the skill plugin:

```bash
git clone https://github.com/canner/wrenai-mcp.git
cd wrenai-mcp
./install.sh
claude plugin marketplace add ./
claude plugin install wrenai-mcp
```

> You'll need your **MCP URL** and **API key** from [WrenAI](https://cloud.getwren.ai/) → **Settings → API**.

Done. Restart Claude Code and try `/wrenai-analyst tell me about my data`

---

### 3. ChatGPT

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

## Skills

| Skill | Description |
|-------|-------------|
| `setup-wrenai-mcp` | One-time setup — connects your agent to a WrenAI instance |
| `wrenai-analyst` | Data analyst — SQL, charts, insights from natural language |

## Platform Summary

| Platform | MCP Setup | Skill Setup | Steps |
|----------|-----------|-------------|-------|
| **claude.ai** | Connectors UI (OAuth) | Skills UI (paste content) | 2 |
| **Claude Desktop** | Integrations UI (OAuth) | Project Knowledge | 2 |
| **Claude Code** | `./install.sh` (auto-configures stdio proxy + API key) | `claude plugin marketplace add ./` + `claude plugin install wrenai-mcp` | 2 |
| **ChatGPT** | Developer Mode → Add MCP Connector | Custom Instructions (paste content) | 2 |

## Add to your repo (optional)

Let teammates use the skills without installing:

```bash
# For Claude Code — clone into project and configure .mcp.json
git clone https://github.com/canner/wrenai-mcp.git .claude/plugins/wrenai-mcp
# Then add the .mcp.json config as shown in section 3 above
```
