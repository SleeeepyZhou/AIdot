@tool
extends AIdotResource
class_name ToolBag

var _tool_list : Dictionary = {}:
	set(l):
		_tool_list = l
		var tools : Array = []
		for tool in _tool_list.keys():
			tools.append(_tool_list[tool]._tool_data)
		_agent_tools = tools
var _agent_tools : Array = []

func get_tool_list() -> Array:
	var list := _tool_list.keys()
	return list

func add_tool(tools : Array[String]) -> Array:
	for tool in tools:
		if ToolBox._tool_box.has(tool):
			_tool_list[tool] = ToolBox._tool_box[tool]
		else:
			push_warning("The tool "+tool+" is not registered in ToolBox, it will be skipped.")
			continue
	return get_tool_list()

func remove_tool(tools : Array[String]) -> Array:
	var list : Array = []
	for tool in tools:
		if _tool_list.erase(tool):
			list.append(tool)
	return list

signal tool_response(call_id : int, result : Array)
func _wait_call(call_id : int, name : String, input : Dictionary = {}):
	var result = await _tool_list[name].use_tool(input)
	tool_response.emit(call_id, result)
func use_tool(name : String, input : Dictionary = {}) -> Array:
	if !_tool_list.has(name):
		var tip := "The agent does not have permission to use tool {0}, 
					or tool {0} does not exist, or invalid tool name."
		push_error(tip.format([name]))
		return [false, 0]
	elif !ToolBox._tool_box.has(name):
		var tip := "Tool {0} has not been registered in ToolBox yet."
		push_error(tip.format([name]))
		return [false, 0]
	var id : int = Time.get_ticks_msec()
	_wait_call(id, name, input)
	return [true, id]
