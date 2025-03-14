@tool
extends AIMemory
class_name AgentMemory
## Temporarily stored as text, RAG will be supported in the future.

# Config
enum MEMORY_MOD {
	CHAT,
	ONE_SHOT,
	AGENT
}
@export var memory_mod : MEMORY_MOD = MEMORY_MOD.CHAT
@export var RAG : bool = false

func _validate_property(property: Dictionary) -> void:
	if property.name == "edit_memory":
		property.usage &= ~PROPERTY_USAGE_STORAGE



# Memory
@export_storage var sys_prompt : Dictionary = {}
func set_sys(prompt : String):
	sys_prompt = template_memory(prompt, "system")
func reset_sys():
	sys_prompt = {}
const _Role = ["user","assistant","tool","system"]
## Used to generate template memory blocks. 
static func template_memory(content : String, role : String, char_name : String = "") -> Dictionary:
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

func save(memory_save_path: String = "", agent_id: String = "") -> String:
	var file_name: String = agent_id
	if file_name.is_empty():
		push_warning("Has no agent name and will use a unix to name the memory.")
		file_name = "Agent_" + str(Time.get_unix_time_from_system())
	file_name += ".tres"
	var dir = memory_save_path
	if !dir.is_absolute_path():
		push_warning("Memory file storage location" + dir + \
					" invalid, default location will be used.'user://'")
		dir = "user://"
	var dir_open = DirAccess.open(dir)
	if dir_open.get_open_error() != OK:
		dir_open.make_dir_recursive(dir)
	ResourceSaver.save(self, dir + "/" + file_name)
	return dir + "/" + file_name
func reset():
	_history = []



# Short Memory
@export_storage var _history : Array = []

## Memory max length.(/Character)
@export_range(1000, 30000) var max_character : int = 10000
func short_memory_len():
	var length : int = len(str(_history))
	return length
func add_memory(content : String, role : String, char_name : String = ""):
	if memory_mod == MEMORY_MOD.ONE_SHOT:
		_history.clear()
	var block = template_memory(content, role, char_name)
	_history.append(block)
	_out_memory_check()
func read_memory(len : int = 0):
	var m : Array = []
	if !sys_prompt.is_empty():
		m = [sys_prompt]
	if len <= 0 or len >= len(_history):
		return m + _history
	for i in range(len):
		m.append(_history[-len+i])
	return m
func set_memory(memory : Array):
	for block in memory:
		assert(block is Dictionary, "Incorrect memory format!!!")
		assert(block.get("role"), "Incorrect memory format!!! Error: 'role'")
		assert(block.get("content"), "Incorrect memory format!!! Error: 'content'")
	_history = memory
	_out_memory_check()
func write_memory(idx : int, content : String, role : String, char_name : String = ""):
	if idx >= len(_history):
		push_error("Index out of memory.")
		return
	var block = template_memory(content, role, char_name)
	_history[idx] = block

@export var edit_memory : Array[MemoryBlock] = []
@export_tool_button("Read Memory") var _editorread = _editor_read
func _editor_read():
	var e_m : Array[MemoryBlock] = []
	for block in _history:
		var temp_b = MemoryBlock.new()
		temp_b._h_data = block
		e_m.append(temp_b)
	edit_memory = e_m
@export_tool_button("Set Memory") var _editorset = _editor_set
func _editor_set():
	var r_h : Array = []
	for block in edit_memory:
		r_h.append(block._h_data)
	_history = r_h



# Long Memory
var _long

func _out_memory_check():
	if short_memory_len() < max_character:
		return
	
	match memory_mod:
		MEMORY_MOD.ONE_SHOT:
			_history.clear()
		MEMORY_MOD.CHAT:
			pass
		MEMORY_MOD.AGENT:
			pass
