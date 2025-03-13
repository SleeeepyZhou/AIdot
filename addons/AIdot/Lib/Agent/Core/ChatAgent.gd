extends BaseAgent
class_name ChatAgent


# Model
@export var model : BaseModel = null:
	set(m):
		model = m
		if _api:
			_api.model = model
		else:
			_api = LLMAPI.new(model)
var _api : LLMAPI = null:
	set(n):
		_api = n
		add_child(n)
	get:
		assert(_api, "No Model!!!")
		return _api


# Memory
var memory : AIMemory = AIMemory.new()
@export var long_memory : bool = false:
	set(b):
		long_memory = b
		memory.long_memory = b
@export var auto_save_memory : bool = false


# Perception


# Action


# Planning



func _ready() -> void:
	
	pass # Replace with function body.

func chat(prompt : String, role : String = "user", chr_name : String = ""):
	_api.run_api(prompt)
	pass
