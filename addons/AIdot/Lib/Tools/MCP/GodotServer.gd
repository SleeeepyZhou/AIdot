@tool
extends MCPServer
class_name GodotServer

func _set_server_path(path: String):
	if path.is_empty():
		server_path = path
		return
	var type : String = path.get_extension()
	match type:
		"gd":
			server_path = path.simplify_path()
		_:
			push_error("GodotServer script must be a .gd file")
			return
