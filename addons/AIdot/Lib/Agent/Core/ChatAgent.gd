@tool
extends BaseAgent
class_name ChatAgent

# Agent
## Agent's name. The conversation will be based on this name.
@export var character_name: String = ""

## If there is an 'error' in the debug Dictionary, 
## then this response only contains the error text.
signal response(answer : String, debug : Dictionary)

## Dialogue with Agent
func chat(prompt : String, role : String = "user", chr_name : String = ""):
	last_chat = AgentMemory.template_memory(prompt, role, chr_name)
	var history = memory.read_memory()
	_api.run_api(prompt, history, role, chr_name)
	memory.add_memory(prompt, role, chr_name)
	if auto_save_memory:
		_auto_save += 1

## The last conversation initiated with the Agent.
var last_chat : Dictionary = {}
## Try the last conversation before the error Again.
func retry_last_chat():
	if last_chat.is_empty():
		return
	chat(last_chat["content"], last_chat["role"], last_chat.get("name",""))

func _call_back(answer : String, debug : Dictionary):
	if debug.get("error"):
		memory._history.pop_back()
		push_error(agent_id + "'s response has an error.")
	else:
		last_chat = {}
		memory.add_memory(debug["message"]["content"], debug["message"]["role"],character_name)
	response.emit(answer, debug)

# Model
@export var model : BaseModel = null:
	set(m):
		model = m
		if _set_api:
			_api.model = model
		else:
			_set_api = true
			_api = LLMAPI.new(model)
var _api : LLMAPI = null:
	set(n):
		_api = n
		if n == null:
			_set_api = false
		else:
			add_child(_api)
			_api.response.connect(_call_back)
	get:
		assert(_api, "No Model!!!")
		return _api
var _set_api : bool = false


# Memory
@export_group("Memory")
@onready @export var memory : AgentMemory = AgentMemory.new():
	set(m):
		if m:
			memory = m
		else:
			memory = AgentMemory.new()
@export var auto_save_memory : bool = false
## The interval for automatic saving (/session).
@export var auto_save_interval : int = 10
var _auto_save : int = 0:
	set(i):
		if i >= auto_save_interval:
			_auto_save = 0
			save_memory()
		else:
			_auto_save = i
@export_global_dir var memory_save_dir : String = ""
func save_memory() -> String:
	var path = memory.save(memory_save_dir, agent_id)
	## Save path
	return path

@export_multiline var sys_prompt : String = "":
	set(t):
		sys_prompt = t
		memory.set_sys(t)

# Perception
@export_group("Perception")
@export var p : Node

# Action
@export_group("Action")
@export var tool : Node

# Planning
@export_group("Planning")
@export var re : Resource
