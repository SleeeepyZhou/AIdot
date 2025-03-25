@tool
extends Node
class_name BaseAgent

## Agent's id. Chat memory storage will be based on this id.
@export var agent_id : String = "":
	get:
		if agent_id.is_empty():
			return "Agent_" + to_string()
		return agent_id

@export_enum("user","assistant","tool") var role : String = "assistant"
