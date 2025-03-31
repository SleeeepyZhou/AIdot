@tool
extends Node
class_name BaseAgent

## Agent's unique identifier. Chat memory storage will be based on this id.
@export var agent_id : String = "":
	get:
		if agent_id.is_empty():
			return "Agent_" + to_string()
		return agent_id

## Agent's name. The conversation will be based on this name.
@export var character_name: String = ""


## Agent's role. The conversation will be based on this. 
## It will only be one of ["user", "assistant", "tool"].
@export_enum("user","assistant","tool") var role : String = "assistant"

func _chat(prompt : String, source : BaseAgent) -> int:
	return 0

## Dialogue with Agent
func chat(prompt : String, source : BaseAgent) -> int:
	var id = _chat(prompt, source)
	return id
