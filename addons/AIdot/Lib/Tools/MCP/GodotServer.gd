@tool
extends MCPServer
class_name GodotServer
## Godot-native service configuration for in-process GDScript execution.
##
## Unlike [StdioServer] (external process) and HTTP-based servers (remote endpoint),
## GodotServer provides Godot-internal capabilities without spawning any subprocess.
##
## [b]Intended use cases:[/b]
## [br]• [b]Game runtime[/b]: Smart NPC generates GDScript and executes it dynamically
##   via [code]GDScript.new() + reload()[/code].
## [br]• [b]Editor[/b]: Inject LLM-generated code directly into Godot's built-in
##   script editor via [code]EditorInterface.get_script_editor()[/code] (requires [code]@tool[/code]).
##
## [b]Note:[/b] GodotServer does NOT launch [code]godot --headless[/code]. It registers
## in-process tools to [ToolBox] directly. No [MCPClient] subprocess needed.

func _set_server_path(path: String):
	if path.is_empty():
		_server_path = path
		return
	if path.get_extension() == "gd":
		_server_path = path.simplify_path()
	else:
		push_error("GodotServer script must be a .gd file")
