@tool
extends MarginContainer

#{
	#"name": name,
	#"description": str
	#"input_schema": dict
#}

var in_data : Dictionary = {}:
	set(d):
		$Box/Info/Name.text = d["name"]
		$Box/Description.text = d["description"]
		$Box/Info/Args/Arg.text = str(d["input_schema"])
		#var input_schema = d["input_schema"]
