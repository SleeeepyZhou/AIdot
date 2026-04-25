@tool
extends MCPServer
class_name HTTPServer
## HTTP-based MCP server configuration.
##
## Connects to a remote or local MCP server that communicates over HTTP/HTTPS.
## Set [member server_path] to the server's base URL (e.g. [code]http://localhost:8080[/code]).

func _set_server_path(path: String):
	if path.is_empty():
		_server_path = path
		return
	if path.begins_with("http://") or path.begins_with("https://"):
		_server_path = path
	else:
		push_error("HTTPServer path must be an HTTP/HTTPS URL.")
