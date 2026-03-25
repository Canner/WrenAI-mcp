# WrenAI MCP Plugin

Connect Claude to [WrenAI](https://getwren.ai) — query your data, generate SQL, build charts, and get business insights using natural language.

## Quick Start

### 1. Install the plugin

```bash
# From GitHub
/plugin marketplace add canner/wrenai-mcp
/plugin install wrenai-mcp@wrenai-mcp

# Or from a local directory
/plugin marketplace add --source directory --path /path/to/wrenai-mcp
/plugin install wrenai-mcp@wrenai-mcp
```

### 2. Connect to WrenAI

```
/setup-wrenai-mcp
```

This will walk you through:
- Entering your WrenAI URL and project ID
- Checking Node.js >= 20 (required for the MCP bridge)
- Writing the `.mcp.json` config

### 3. Start analyzing

```
/wrenai-analyst how many customers do I have?
/wrenai-analyst show revenue by product type with a chart
/wrenai-analyst 幫我分析每個客戶的營收
```

## Skills

| Skill | Description |
|-------|-------------|
| `/setup-wrenai-mcp` | One-time setup — connects Claude to your WrenAI instance |
| `/wrenai-analyst` | Data analyst — SQL, charts, insights from natural language |

## Requirements

- A running WrenAI instance with MCP enabled
- Node.js >= 20 (for the `mcp-remote` bridge)
- An API key or local dev mode (`MCP_SKIP_AUTH=true`)

## How it works

```
Claude Code ←stdio→ mcp-remote (bridge) ←HTTP→ WrenAI MCP Server
                                               ├── get_project_metadata
                                               ├── ask
                                               ├── generate_sql
                                               ├── run_sql
                                               ├── generate_chart
                                               └── generate_summary
```

Claude Code uses stdio to communicate with MCP servers. Since WrenAI exposes a
Streamable HTTP endpoint, `mcp-remote` bridges the two protocols.

## claude.ai Setup

If you're using claude.ai (web), you can add a **Data Analyst skill** for a better experience:

Paste these prompts into any claude.ai chat:

1. **[`prompts/setup-connector.md`](./prompts/setup-connector.md)** — Add the WrenAI MCP connector (OAuth login)
2. **[`prompts/create-skill.md`](./prompts/create-skill.md)** — Create a Data Analyst skill

## Claude Desktop

The setup skill also provides config for Claude Desktop:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
