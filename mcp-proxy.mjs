#!/usr/bin/env node
// Simple MCP stdio-to-HTTP proxy that bypasses OAuth discovery.
// Reads JSON-RPC from stdin, forwards to the remote MCP server via
// Streamable HTTP, and writes responses back to stdout.

import { createInterface } from "readline";
import https from "https";
import http from "http";

const url = process.argv[2];
const token = process.argv[3];

if (!url || !token) {
  process.stderr.write("Usage: mcp-proxy.mjs <url> <bearer-token>\n");
  process.exit(1);
}

const parsed = new URL(url);
const transport = parsed.protocol === "https:" ? https : http;

let sessionId = null;

function post(message) {
  return new Promise((resolve, reject) => {
    const headers = {
      "Content-Type": "application/json",
      Accept: "application/json, text/event-stream",
      Authorization: `Bearer ${token}`,
    };
    if (sessionId) headers["Mcp-Session-Id"] = sessionId;

    const body = JSON.stringify(message);
    headers["Content-Length"] = Buffer.byteLength(body);

    const opts = {
      hostname: parsed.hostname,
      port: parsed.port || undefined,
      path: parsed.pathname + parsed.search,
      method: "POST",
      headers,
    };

    const req = transport.request(opts, (res) => {
      const sid = res.headers["mcp-session-id"];
      if (sid) sessionId = sid;

      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        const ct = res.headers["content-type"] || "";
        if (ct.includes("text/event-stream")) {
          for (const line of data.split("\n")) {
            if (line.startsWith("data: ")) {
              const payload = line.slice(6).trim();
              if (payload) process.stdout.write(payload + "\n");
            }
          }
        } else {
          const trimmed = data.trim();
          if (trimmed) process.stdout.write(trimmed + "\n");
        }
        resolve();
      });
    });

    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

const rl = createInterface({ input: process.stdin });
rl.on("line", (line) => {
  const trimmed = line.trim();
  if (!trimmed) return;
  try {
    const msg = JSON.parse(trimmed);
    post(msg).catch((err) => {
      process.stderr.write(`Proxy error: ${err.message}\n`);
    });
  } catch {
    process.stderr.write(`Invalid JSON: ${trimmed}\n`);
  }
});
