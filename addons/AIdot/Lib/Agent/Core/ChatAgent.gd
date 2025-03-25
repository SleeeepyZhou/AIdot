@tool
extends BaseAgent
class_name ChatAgent

# Agent
## If there is an 'error' in the debug Dictionary, 
## then this response only contains the error text.
signal response(answer : String, debug : Dictionary)

## Dialogue with Agent
func chat(prompt : String, in_role : String = "user", chr_name : String = ""):
	if in_role == "user" or in_role == "assistant":
		prompt = memory._get_long(prompt) + prompt
	if tool_user:
		model.tools["tools"] = _get_tools()
	last_chat = AgentMemory.template_memory(prompt, in_role, chr_name)
	var history = memory.read_memory()
	_api.run_api(prompt, history, in_role, chr_name)
	memory.add_memory(prompt, in_role, chr_name)
	if auto_save_memory:
		_auto_save += 1

## The last conversation initiated with the Agent.
var last_chat : Dictionary = {}
## Try the last conversation before the error Again.
func retry_last_chat():
	if last_chat.is_empty():
		return
	chat(last_chat["content"], last_chat["role"], last_chat.get("name",""))

func _call_back(answer : String, debug : Dictionary): # handle memory and callbacks
	if debug.get("error"):
		var templast = memory._history.pop_back()
		push_error(agent_id + "'s response has an error. Prompt: " + templast["content"])
	else:
		last_chat = {}
		# callback handle
		var callbacks = str(debug["message"]["content"])
		# planning
		if planer:
			pass
		
		memory.add_memory(callbacks, role, character_name)
		# tools
		if tool_user and debug.has("tool_calls"):
			_handle_toolcall(debug["tool_calls"])
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


# Planning
@export_group("Planning")
@export var planer : bool = false


# Perception
@export_group("Perception")
@export var monitoring : bool = false
#@export var sensor2D : AgentSensor2D
#@export var sensor3D : AgentSensor3D


# Action
@export_group("Action")
@export var tool_user : bool = true:
	set(b):
		if b:
			if !tool_chat.is_connected(chat):
				tool_chat.connect(chat)
		else:
			tool_bag = null
			if tool_chat.is_connected(chat):
				tool_chat.disconnect(chat)
@export var tool_bag : ToolBag = ToolBag.new():
	set(t):
		if t:
			tool_bag = t
		else:
			tool_bag = ToolBag.new()

signal tool_chat(prompt : String, in_role : String, chr_name : String)
func _get_tools():
	return tool_bag._agent_tools
func call_tool(tool_name : String, input : Dictionary = {}):
	var tool_result = await tool_bag.use_tool(tool_name, input)
	return tool_result

func _handle_toolcall(tool_calls : Array):
	var final_result : PackedStringArray = []
	var call_tip : String = "[Calling tool {0} with args {1}]"
	for call in tool_calls:
		final_result.append(call_tip.format([call["name"],str(call.get("arguments",{}))]))
		var result = await call_tool(call["name"], call.get("arguments",{}))
		final_result.append(str(result))
	tool_chat.emit("\n".join(final_result),"tool","")
