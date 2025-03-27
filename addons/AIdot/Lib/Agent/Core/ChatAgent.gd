@tool
extends BaseAgent
class_name ChatAgent

# Agent
const _max_retry = 5
@export var auto_retry : bool = false
@export_range(0, _max_retry) var retry_times : int = 3
@export var auto_callback : bool = false
@export var auto_task_clear : int = 300
## If there is an 'error' in the debug Dictionary, 
## then this response only contains the error text.
signal response(answer : String, debug : Dictionary, chat_id : int)
signal chat_completed(chat_id : int, chat_info : Dictionary)

var _chat_list : Dictionary = {}
enum ChatStatus {
	PENDING,
	RUNNING,
	SUCCESS,
	WAITING,
	FAILED} 
func _str_status(chat_status : ChatStatus):
	var status : String
	match chat_status:
		ChatStatus.PENDING: status = "pending"
		ChatStatus.WAITING: status = "waiting"
		ChatStatus.RUNNING: status = "running"
		ChatStatus.FAILED: status = "failed"
func _task_clear(chat_id : int):
	await get_tree().create_timer(auto_task_clear).timeout
	_chat_list.erase(chat_id)
class ChatTask:
	var id : int
	var status : ChatStatus
	var target : BaseAgent
	var data : MemoryBlock
	var result : Dictionary = {}
	var retry : int = 0
	func _init(
			chat_data : MemoryBlock, 
			chat_status : ChatStatus, 
			chat_id : int = 0,
			chat_target : BaseAgent = AgentCoordinator.user
		) -> void:
		id = chat_id
		data = chat_data
		status = chat_status
		target = chat_target
func _call_chat(id : int):
	# Construct a complete prompt.
	var task : ChatTask = _chat_list[id]
	var chat_data = task.data
	if tool_user:
		model.tools["tools"] = _get_tools()
	var history = memory.read_memory()
	task.status = ChatStatus.RUNNING
	
	# Request
	var result = await _api.run_api(chat_data.content, history, chat_data.role, 
									id, chat_data.character_name)
	model.tools["tools"] = []
	var answer : String = result[0]
	var debug : Dictionary = result[1]
	
	# Error handle
	var handle_error = func(error_tip : String = ""):
		push_error(agent_id + "'s response has an error. " + error_tip)
		task.status = ChatStatus.FAILED
		task.result = debug
		if auto_retry and task.retry < min(retry_times, _max_retry):
			task.status = ChatStatus.WAITING
			retry_chat(id)
		else:
			chat_completed.emit(id, get_task_info(id))
			_task_clear(id)
		return
	
	# Handle result
	if debug.get("error"):
		handle_error.call("Prompt: " + chat_data.content)
		return
	else:
		var message : Array = []
		var final : PackedStringArray = []
		message.append(
			AgentMemory.template_memory(
				chat_data.content, chat_data.role, chat_data.character_name
				)
			)
		
		# callback handle
		var callbacks = str(debug["message"]["content"])
		message.append(AgentMemory.template_memory(callbacks, role, character_name))
		final.append(callbacks)
		
		# planning
		if planer:
			pass
		
		# tools
		var tool_memory : String = ""
		if tool_user and debug.has("tool_calls"):
			var tool_result = await _handle_toolcall(debug["tool_calls"], id)
			for tool in tool_result.keys():
				tool_memory += tool_result[tool]["tip"] + "\n"
				tool_memory += tool_result[tool]["result"] + "\n"
			
			var tool_chat = await _api.run_api(tool_memory, message, "tool")
			var tool_debug : Dictionary = tool_chat[1]
			if tool_debug.get("error"):
				handle_error.call("Tool call failed.")
				return
			else:
				var toolbacks = "[Received the result of calling the tool!]\n" + \
								str(tool_debug["message"]["content"])
				final.append(toolbacks)
		var final_answer : String = "\n".join(final)
		
		# memory
		memory.add_memory(chat_data.content, chat_data.role, chat_data.character_name)
		if !tool_memory.is_empty():
			memory.add_memory(tool_memory, "tool")
			_auto_save += 1
		memory.add_memory(final_answer, role, character_name)
		
		debug["message"] = AgentMemory.template_memory(final_answer, role, character_name)
		task.result = debug
		task.status = ChatStatus.SUCCESS
		chat_completed.emit(id, get_task_info(id))
		_task_clear(id)
		
		# Callback
		if task.target is UserAgent:
			task.target.record_prompt(chat_data.content,self)
			task.target.chat(final_answer, self)
		elif auto_callback:
			task.target.chat(final_answer, self)
func get_task_info(chat_id : int) -> Dictionary:
	var task : ChatTask = _chat_list[chat_id]
	var status : String = _str_status(task.status)
	var info : Dictionary = {
		"id": chat_id,
		"status": status,
		"agent": self,
		"target": task.target,
		"input": task.data.get_data(),
		"result": task.result
	}
	return info
func _chat(prompt : String, source : BaseAgent = AgentCoordinator) -> int:
	# Identity of the interlocutor
	var in_role : String = source.role
	var chr_name : String = source.character_name
	if in_role != "tool":
		prompt += memory._get_long(prompt)
	
	# Pending Task
	var id : int = int(Time.get_unix_time_from_system()*1000)
	var task : ChatTask = ChatTask.new(
		MemoryBlock.new(AgentMemory.template_memory(prompt, in_role, chr_name)),
		ChatStatus.PENDING, id, source)
	_chat_list[id] = task
	_call_chat(id)
	return id
## Try conversation before the error Again.
func retry_chat(chat_id : int):
	if !_chat_list.has(chat_id) or _chat_list[chat_id].status != ChatStatus.WAITING:
		return
	var task : ChatTask = _chat_list[chat_id]
	task.status = ChatStatus.PENDING
	task.retry += 1
	_call_chat(chat_id)

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
		if _api:
			if _api.response.is_connected(_call_back):
				_api.response.disconnect(_call_back)
			_api.queue_free()
		_api = n
		if _api == null:
			_set_api = false
		else:
			add_child(_api)
			_api.response.connect(_call_back)
	get:
		assert(_api, "No Model!!!")
		return _api
var _set_api : bool = false # Indicates whether an API node has been set.
func _call_back(answer : String, debug : Dictionary, requset_id : int):
	response.emit(answer, debug, requset_id)


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
		if auto_save_memory:
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
		if !b:
			tool_bag = null
@export var tool_bag : ToolBag = ToolBag.new():
	set(t):
		if t:
			tool_bag = t
		else:
			tool_bag = ToolBag.new()

signal tool_call(result_list : Dictionary, chat_id : int)
func _get_tools():
	return tool_bag._agent_tools
func call_tool(tool_name : String, input : Dictionary = {}):
	var tool_result = await tool_bag.use_tool(tool_name, input)
	return tool_result
func _handle_toolcall(tool_calls : Array, chat_id : int) -> Dictionary:
	var result_list : Dictionary = {}
	var call_tip : String = "[Calling tool {0} with args {1}]"
	for call in tool_calls:
		var result = await call_tool(call["name"], call.get("arguments",{}))
		result_list[call["name"]] = {
			"args": call.get("arguments",{}),
			"tip": call_tip.format([call["name"],str(call.get("arguments",{}))]),
			"result": str(result)
		}
	tool_call.emit(result_list,chat_id)
	return result_list
