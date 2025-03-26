@tool
extends ChatAgent

var user : UserAgent
func _ready() -> void:
	user = UserAgent.new()
	add_child(user)

var agent_list
var net

# AgentFactory

# Agent Relationship Network

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
