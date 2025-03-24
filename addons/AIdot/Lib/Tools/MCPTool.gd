@tool
extends BaseTool
class_name MCPTool

var client : MCPClient

func _call(arguments : Dictionary = {}) -> Array:
	var result = await client.call_tool(_tool_name, arguments)
	return result
