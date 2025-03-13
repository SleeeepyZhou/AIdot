class_name AIMemory
extends Resource
## Temporarily stored as text, RAG will be supported in the future.

@export var long_memory : bool = false

# Short Memory
var _history : Array = []

## Memory max length.(Unit: Character)
@export var max_memory : int = 2000

var _block_times : int = 0:
	set(t):
		if t > 5:
			_block_times = 0
			if short_memory_len() > max_memory:
				_out_memory()
		else:
			_block_times = t
func short_memory_len():
	return len(str(_history))
func add_memory(content : String, role : String, char_name : String = ""):
	var block = template_memory(content, role, char_name)
	_history.append(block)
	_block_times += 1
func read_memory(len : int = 0):
	if len <= 0 or len >= len(_history):
		return _history
	var m : Array = []
	for i in range(len):
		m.append(_history[-len+i])
	return m

# Long Memory
var _long
func _out_memory():
	if long_memory:
		pass
	else:
		pass

#func _set_memory():
	#pass
#func write_memory():
	#pass
func save():
	pass

const _Role = ["user","assistant","tool","system"]

## Used to generate template memory blocks. 
static func template_memory(content : String, role : String, char_name : String = ""):
	assert(_Role.has(role), "Wrong message role " + role +"!!!")
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
