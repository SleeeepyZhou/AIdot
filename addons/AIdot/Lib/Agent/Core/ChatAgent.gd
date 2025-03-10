class_name ChatAgent
extends BaseAgent

var api_node : AIAPI = null:
	set(n):
		api_node = n
		if model:
			api_node.model = model
@export var model : BaseModel = null:
	set(m):
		model = m
		if api_node:
			api_node.model = model
		

@export var long_memory : bool = false
var memory : AgentMemory

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
