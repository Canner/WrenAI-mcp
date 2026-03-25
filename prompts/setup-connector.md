Help me set up WrenAI so I can analyze my data directly in Claude.

Go to Settings → Connectors → Add Connector, and add a new MCP connector with:

- **Name:** wrenai
- **URL:** `https://app.getwren.ai/api/mcp/{project_id}`

Ask me for my project ID (a number, visible in the Wren AI URL when I'm logged in). Once I provide it, construct the full URL and guide me through adding the connector. It uses OAuth — I'll be redirected to log in with my Wren AI account.
