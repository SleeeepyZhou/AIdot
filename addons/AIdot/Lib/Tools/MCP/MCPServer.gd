@tool
@icon("res://addons/AIdot/Res/UI/Icon/mcp.png")
extends AIdotResource
class_name MCPServer

## MCP Server Abstract base class.

@export_file var server_path : String = "":
	set(path):
		_set_server_path(path)

func _set_server_path(path: String):
	server_path = path

func set_server_path(path: String):
	_set_server_path(path)
