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

# Registered MCP client.
var _MCP_client : Dictionary = {}
# Registered tools.
var _tool_box : Dictionary = {}
## Get registered tools name in Box.
func get_box_tool():
	var list = _tool_box.keys()
	return list

var _creating : bool = false
signal create_mcp(is_ok : bool)
func _connect_ok(is_ok : bool):
	if is_connected("connection",_connect_ok):
		disconnect("connection",_connect_ok)
	_creating = false
	create_mcp.emit(is_ok)
func create_mcp_from_server(server : MCPServer):
	if _creating:
		push_warning("The previous MCP has not been created yet.")
		return
	_creating = true
	var new_client = MCPClient.new()
	add_child(new_client)
	new_client.server = server
	new_client.connection.connect(_connect_ok)
	new_client.connect_to_server()
