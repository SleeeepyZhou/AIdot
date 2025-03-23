@tool
extends ChatAgent

## This singleton integrates MCP and allows realtime registration of tools.
## MCP - Model Context Protocol

# MCP
const _LATEST_PROTOCOL_VERSION = "2024-11-05"
const _MCP_VERSION = "0.1.0"
const SUPPORTED_PROTOCOL_VERSIONS = [1, _LATEST_PROTOCOL_VERSION]

var mcp_initialize : Dictionary = {
		"protocolVersion": _LATEST_PROTOCOL_VERSION,
		"capabilities": 
			{
				"sampling": {}, # Sampling not supported
				"roots": {"listChanged": true} # List roots not supported
			},
		"clientInfo": 
			{
				"name": "mcp", 
				"version": _MCP_VERSION
			}
	}
