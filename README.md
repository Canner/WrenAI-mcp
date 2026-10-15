# WrenAI MCP

Connect AI agents to [WrenAI](https://getwren.ai) — query your data, generate SQL, build charts, and get business insights in natural language, straight from Claude or ChatGPT.

```
AI client (Claude / ChatGPT)
   │  OAuth
   ▼
https://cloud.getwren.ai/api/mcp          ← one endpoint for your whole org
   ├── list_projects            (discover which projects you can query)
   ├── get_project_metadata     (table schema for a project)
   ├── ask                      (end-to-end natural-language Q&A)
   ├── generate_sql / run_sql
   ├── generate_chart           (Vega spec)
   └── generate_summary
```

> **New model (July 2026):** MCP is now a **single organization-level endpoint** with **OAuth** login — no API key and no local proxy. After you connect, your agent calls `list_projects` and then works against any project your org has exposed. The old per-project URL (`…/api/mcp/{token}`) is **deprecated** — see [Migrating](#migrating-from-the-per-project-url).

---

## How it works

1. An **org admin** enables MCP for the organization and picks which projects are **exposed**.
2. You add **one URL** — `https://cloud.getwren.ai/api/mcp` — as an MCP connector in your AI client and log in with **OAuth** (your WrenAI account).
3. Your agent calls **`list_projects`** to see the projects you can reach, then passes a **`projectId`** to the other tools.
4. If your organization uses row/column-level data security (an **Enterprise** feature), it's applied **per user**, server-side — you only see what your WrenAI account is allowed to see.

## Requirements

- A WrenAI **Essential** or **Enterprise** plan.
- An **org admin** to enable MCP + expose projects (one-time, below).
- Your own WrenAI account (for the OAuth login). **No API key, no proxy.**

---

## Part 1 · Admin: enable MCP for your organization

*(One-time, done by an organization admin.)*

1. In WrenAI, go to **Settings → Organization → MCP**.
2. Turn on **Enable MCP for this organization**.
3. Under **Exposed projects**, toggle **Exposed** on for each project you want reachable over MCP. Optionally set **New projects default** to *Exposed*.
4. Copy the **endpoint URL** shown here — it's the same for everyone in the org:
   `https://cloud.getwren.ai/api/mcp`

> Only exposed projects are reachable, and each user still only sees projects they’re a member of. Toggling a project off here (or disabling the org switch) immediately cuts MCP access to it.

---

## Part 2 · Connect your AI client

You only need the endpoint URL and your WrenAI login. Pick your client:

### claude.ai (Web) & Claude Desktop

1. **Settings → Connectors → Add custom connector**.
2. **Name:** `WrenAI`  ·  **URL:** `https://cloud.getwren.ai/api/mcp`
3. **Connect** → you’ll be redirected to log in with your WrenAI account (OAuth). Approve access.

### ChatGPT

*(Requires connector/Developer-Mode access on your ChatGPT plan; exact menu names vary by version.)*

1. Open **Plugins → Connectors** and start a new connector (**New Plugin**).
2. **Name:** `WrenAI`. Keep **Connection: Server URL** and enter `https://cloud.getwren.ai/api/mcp`.
3. **Authentication:** OAuth → tick **“I understand and want to continue”** → **Create**.
4. Log in with your WrenAI account when prompted.

### Claude Code (CLI)

```bash
claude mcp add --transport http wrenai https://cloud.getwren.ai/api/mcp
# then, inside Claude Code:
/mcp        # select "wrenai" and complete the OAuth login in your browser
```

No proxy and no API key — you connect to the remote endpoint and authenticate via OAuth.

> If `/mcp` hangs at the OAuth step, update Claude Code to the latest version and retry (older versions don't fully support remote OAuth MCP servers). Please open an issue here if it persists.

### Self-hosted WrenAI

Use your own instance’s origin instead of `cloud.getwren.ai`, e.g. `https://wren.yourcompany.com/api/mcp`. Everything else is identical.

---

## Part 3 · Using it

Once connected, just ask in natural language. Behind the scenes the agent:

1. calls **`list_projects`** → picks the right `projectId`,
2. reads schema with **`get_project_metadata`**,
3. answers with **`ask`** (or `generate_sql` / `run_sql`), and renders a **`generate_chart`** visualization.

Example prompts:
- “List my WrenAI projects.”
- “In the *Sales* project, what were the top 5 products by revenue last quarter? Chart it.”

> **Multiple orgs?** If your account belongs to more than one MCP-enabled org, `list_projects` shows the exposed projects across all of them.

### Optional: the WrenAI Analyst skill

For sharper analysis behavior, install the **`wrenai-analyst`** skill:

| Client | How |
|---|---|
| claude.ai / Desktop | **Customize → Skills → Create → Upload** `web/claude/wrenai-analyst/SKILL.md` |
| ChatGPT | Paste `web/chatgpt/wrenai-analyst-skill.md` into **Custom Instructions** |
| Claude Code | `claude plugin marketplace add ./ && claude plugin install wrenai-mcp` |

> Generate the skill files: `git clone https://github.com/canner/wrenai-mcp.git && cd wrenai-mcp && ./setup --host web` (or `--host chatgpt`).

---

## Tools

| Tool | Purpose | Takes `projectId` |
|---|---|---|
| `list_projects` | Projects you can query | — |
| `get_project_metadata` | Table schema for a project | ✅ |
| `ask` | End-to-end natural-language Q&A | ✅ |
| `generate_sql` | Question → SQL | ✅ |
| `run_sql` | Execute SQL | ✅ |
| `generate_chart` | Vega chart spec | ✅ |
| `generate_summary` | Summarize results | ✅ |

## Data security & limits

- **Per-user RLS/CLS** *(Enterprise feature)* — row/column policies are resolved server-side from the **Wren AI account that authenticated the connection** (the OAuth user); the client can’t override them. ⚠️ **Avoid shared accounts** — anyone using a shared Wren AI account inherits that account’s data permissions, so RLS/CLS can’t tell the individuals apart. Have each person connect with their own account.
- **MCP availability** — available on Essential and Enterprise plans.
- **Interactive mode only** — Agentic Mode is not available over MCP.

---

## Migrating from the per-project URL

The legacy per-project URL — `https://cloud.getwren.ai/api/mcp/{token}` — and its **Settings → Project → MCP connection** page are **deprecated and will be removed soon**. To migrate:

1. Have an admin enable MCP + expose the project in **Settings → Organization → MCP** (Part 1).
2. In your AI client, replace the old per-project URL with `https://cloud.getwren.ai/api/mcp` and reconnect (Part 2).
3. Your agent now picks the project via `list_projects` instead of the URL.

