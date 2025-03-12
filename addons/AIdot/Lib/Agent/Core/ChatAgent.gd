extends BaseAgent
class_name ChatAgent

var _api : LLMAPI = null:
	set(n):
		_api = n
		add_child(n)
	get:
		assert(_api, "No API Node!!!")
		return _api
@export var model : BaseModel = null:
	set(m):
		model = m
		if _api:
			_api.model = model
		else:
			_api = LLMAPI.new(model)

@export var long_memory : bool = false:
	set(b):
		long_memory = b
		memory._long_memory = b
var memory : AgentMemory = AgentMemory.new()

func _ready() -> void:
	
	pass # Replace with function body.

func chat(prompt : String, role : String = "user", chr_name : String = ""):
	_api.run_api(prompt)
	pass
