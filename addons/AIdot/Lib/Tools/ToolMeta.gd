@tool
extends AIdotResource
class_name BaseTool

var tool_name : String
var description : String
var input_schema : Dictionary

var _tool_data : Dictionary:
	set(d):
		if d.get("name"):
			_tool_data = d
			tool_name = d.get("name")
			description = d.get("description","")
			input_schema = d.get("input_schema",{})
		else:
			push_error("Invalid tool data.")

func _call(arguments : Dictionary = {}):
	var result = "This is the tool base class."
	return result

func use_tool(arguments : Dictionary = {}):
	if !input_schema.is_empty():
		var required = input_schema.get("required",[])
		assert(required is Array, "Invalid input schema.")
		var in_arg = arguments.keys()
		for arg in required:
			if !in_arg.has(arg):
				push_error("The necessary arg ", arg, " is missing when running ", tool_name,".")
				return {}
	var result = await _call(arguments)
	return result

#func type_comparison(arg, type : String) -> bool:
	#var check : String = type.dedent().to_lower()
	#var arg_type : String = type_string(typeof(arg)).dedent().to_lower()
	#if check == "string":
		#return true
	#else:
		#return true
