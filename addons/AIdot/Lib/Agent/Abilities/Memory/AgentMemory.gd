class_name AgentMemory
extends AIMemory

var s_memory : ShortMemory
var l_memory : LongMemory

var _long_memory : bool = false:
	set(b):
		_long_memory = b
		if b:
			l_memory
		

#func _get_memory():
	#pass
#func read_memory():
	#pass
#
#func _set_memory():
	#pass
#func write_memory():
	#pass

func add_memory():
	
	pass

func save():
	pass

## Used to generate template memory blocks. 
static func template_memory(content : String, role : String, char_name : String = ""):
	if char_name.is_empty():
		return {
			"role": role,
			"content": content
		}
	return {
		"role": role,
		"name": char_name,
		"content": content
	}
