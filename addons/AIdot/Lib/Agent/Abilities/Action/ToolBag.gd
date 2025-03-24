@tool
extends AIdotResource
class_name ToolBag

var _tool_list : Dictionary = {}:
	get:
		if _tool_list.is_empty():
			return ToolBox._tool_box
		else:
			return _tool_list
	set(l):
		_tool_list = l
		var tools : Array = []
		for tool in _tool_list.keys():
			tools.append(_tool_list[tool]._tool_data)
		_agent_tools = tools
var _agent_tools : Array = []

func get_tool_list():
	var list := _tool_list.keys()
	return list

func add_tool():
	pass
