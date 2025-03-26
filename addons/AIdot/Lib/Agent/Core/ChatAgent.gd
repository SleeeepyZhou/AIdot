@tool
extends BaseAgent
class_name ChatAgent

# Agent
@export var auto_retry : bool = false
## If there is an 'error' in the debug Dictionary, 
## then this response only contains the error text.
signal response(answer : String, debug : Dictionary, requset_id : int)

## >>>>>> need fix <<<<<<

var _wait_you : BaseAgent
var _chat_list : Dictionary = {}
func _request_chat(prompt : String, in_role : String = "user", chr_name : String = ""):
	# Construct a complete prompt.
	if tool_user:
		model.tools["tools"] = _get_tools()
	var history = memory.read_memory()
	
	var id : int = int(Time.get_unix_time_from_system())
	_chat_list[id] = AgentMemory.template_memory(prompt, in_role, chr_name)
	_api.run_api(prompt, history, in_role, id, chr_name)
	memory.add_memory(prompt, in_role, chr_name)
	if auto_save_memory:
		_auto_save += 1
	return id
## Dialogue with Agent
func chat(prompt : String, source : BaseAgent = AgentCoordinator.user):
	# Identity of the interlocutor
	var in_role : String = source.role
	var chr_name : String = source.character_name
	_wait_you = source
	if in_role != "tool":
		prompt = memory._get_long(prompt) + prompt
	return _request_chat(prompt, in_role, chr_name)

## Try conversation before the error Again.
func retry_chat(chat_id : int):
	if !_chat_list.has(chat_id):
		return
	var target = _chat_list[chat_id]
	var newid = _request_chat(target["content"], target["role"], target.get("name",""))
	_chat_list.erase(chat_id)
	_chat_list[newid] = target
	return newid

func _call_back(answer : String, debug : Dictionary, requset_id : int):
	# handle memory and callbacks
	var callback_taget = _wait_you
	if debug.get("error"):
		memory._history.pop_back()
		push_error(agent_id + "'s response has an error. Prompt: " + callback_taget["prompt"])
		if auto_retry:
			retry_chat(requset_id)
	else:
		# callback handle
		var callbacks = str(debug["message"]["content"])
		# planning
		if planer:
			pass
		
		memory.add_memory(callbacks, role, character_name)
		
		# tools
		if tool_user and debug.has("tool_calls"):
			_handle_toolcall(debug["tool_calls"])
	
	_chat_list.erase(requset_id)
	response.emit(answer, debug, requset_id)

## >>>>>> need fix <<<<<<




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
var _set_api : bool = false # Indicates whether an API node has been set.


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
## Save path
@export_global_dir var memory_save_dir : String = ""
func save_memory() -> String:
	var path = memory.save(memory_save_dir, agent_id)
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
			if !tool_chat.is_connected(_request_chat):
				tool_chat.connect(_request_chat)
		else:
			tool_bag = null
			if tool_chat.is_connected(_request_chat):
				tool_chat.disconnect(_request_chat)
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
