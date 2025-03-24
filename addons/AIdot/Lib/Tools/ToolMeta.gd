@tool
extends AIdotResource
class_name BaseTool

var _tool_name : String
var _description : String
var _input_schema : Dictionary

var _tool_data : Dictionary:
	set(d):
		if d.get("name"):
			_tool_data = d
			_tool_name = d.get("name")
			_description = d.get("_description","")
			_input_schema = d.get("_input_schema",{})
		else:
			push_error("Invalid tool data.")

func _call(arguments : Dictionary = {}) -> Array:
	var result = ["This is the tool base class."]
	return result

func use_tool(arguments : Dictionary = {}) -> Array:
	if !_input_schema.is_empty():
		var required = _input_schema.get("required",[])
		assert(required is Array, "Invalid input schema.")
		var in_arg = arguments.keys()
		for arg in required:
			if !in_arg.has(arg):
				push_error("The necessary arg ", arg, " is missing when running ", _tool_name,".")
				return []
	var result = await _call(arguments)
	return result

#func type_comparison(arg, type : String) -> bool:
	#var check : String = type.dedent().to_lower()
	#var arg_type : String = type_string(typeof(arg)).dedent().to_lower()
	#if check == "string":
		#return true
	#else:
		#return true
