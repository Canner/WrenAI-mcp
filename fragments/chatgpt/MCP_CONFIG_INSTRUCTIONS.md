Configure the WrenAI MCP server in ChatGPT Developer Mode:

1. Go to **ChatGPT → Settings → Developer Mode** (enable if not already)
2. Click **Add MCP Server**
3. Enter the connection details:
   - **Name**: `wrenai`
   - **URL**: `https://app.getwren.ai/api/mcp/{project_id}` (or your self-hosted URL)
   - **Transport**: Streamable HTTP
4. If authentication is required, add the API key header:
   - **Header**: `Authorization: Bearer <api_key>`

For self-hosted WrenAI with `mcp-remote` bridge, use the stdio transport:
- **Command**: `npx`
- **Args**: `mcp-remote`, `<endpoint_url>`