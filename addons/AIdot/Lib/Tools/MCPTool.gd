@tool
extends BaseTool
class_name MCPTool

var client : MCPClient

func _call(arguments : Dictionary = {}):
	var result = await client.call_tool(tool_name, arguments)
	return result
