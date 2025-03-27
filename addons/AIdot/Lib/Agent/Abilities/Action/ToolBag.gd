@tool
extends AIdotResource
class_name ToolBag

@export var bag_show : PackedStringArray = []
@export var add : String = ""
@export_tool_button("Add tool") var _edit_add = _add_for_editor
func _add_for_editor():
	if !ToolBox._tool_box.has(add):
		push_error(add, " has not been registered in ToolBox yet.")
		return
	if add_tool([add]).is_empty():
		print(">>>Can not add tool ", add, ".<<<")
		return
	print(">>>", add, "has been added.<<<")
@export var remove : String = ""
@export_tool_button("Remove tool") var _edit_remove = _remove_for_edit
func _remove_for_edit():
	if !bag_show.has(remove):
		push_error(remove, " does not exist in the Agent's bag.")
		return
	if remove_tool([remove]).is_empty():
		print(">>>Can not remove tool ", remove, ".<<<")
		return
	print(">>>", remove, "has been removed.<<<")

func _validate_property(property: Dictionary) -> void:
	if property.name == "bag_show":
		property.usage |= PROPERTY_USAGE_READ_ONLY

var _tool_list : Dictionary = {}:
	set(l):
		_tool_list = l
		var tools : Array = []
		var show : PackedStringArray = []
		for tool in _tool_list.keys():
			var std_tool = {
				"type": "function",
				"function": {
					"name": _tool_list[tool]._tool_name,
					"description": _tool_list[tool]._description,
					"parameters": _tool_list[tool]._input_schema
				},
				"strict": true
			}
			show.append(_tool_list[tool]._tool_name)
			tools.append(std_tool)
		bag_show = show
		_agent_tools = tools
var _agent_tools : Array = []

func get_tool_list() -> Array:
	var list := _tool_list.keys()
	return list

func add_tool(tools : Array[String]) -> Array:
	var list : Array = []
	for tool in tools:
		if ToolBox._tool_box.has(tool):
			_tool_list[tool] = ToolBox._tool_box[tool]
			list.append(tool)
		else:
			push_warning("The tool "+tool+" is not registered in ToolBox, it will be skipped.")
			continue
	return list

func remove_tool(tools : Array[String]) -> Array:
	var list : Array = []
	for tool in tools:
		if _tool_list.erase(tool):
			list.append(tool)
	return list

signal tool_response(call_id : int, result : Array)
func _tool_validation(name : String) -> bool:
	if !_tool_list.has(name):
		var tip := "The agent does not have permission to use tool {0}, 
					or tool {0} does not exist, or invalid tool name."
		push_error(tip.format([name]))
		return false
	elif !ToolBox._tool_box.has(name):
		var tip := "Tool {0} has not been registered in ToolBox yet."
		push_error(tip.format([name]))
		return false
	return true
func _wait_call(call_id : int, name : String, input : Dictionary = {}):
	var result = await _tool_list[name].use_tool(input)
	tool_response.emit(call_id, result)
## Call the tool and return whether the call was successful and call_id. 
## The result of the tool will be returned from the signal with id as the 
## unique identifier.
func call_tool(name : String, input : Dictionary = {}) -> Array:
	if !_tool_validation(name):
		return [false, 0]
	var id : int = Time.get_ticks_msec()
	_wait_call(id, name, input)
	return [true, id]
## Call this tool, wait and return the call result, use await.
func use_tool(name : String, input : Dictionary = {}) -> Array:
	if !_tool_validation(name):
		return []
	var result = await _tool_list[name].use_tool(input)
	return result
