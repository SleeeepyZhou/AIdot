@tool
extends BaseAgent
class_name UserAgent

func _init() -> void:
	role = "user"

func _chat(prompt : String, source : BaseAgent) -> int:
	var source_id := source.agent_id
	var message : Array = chat_data.get(source_id,[])
	message.append(AgentMemory.template_memory(prompt,source.role,source.character_name))
	chat_data[source_id] = message
	return 1

func record_prompt(prompt : String, source : BaseAgent):
	var source_id := source.agent_id
	var message : Array = chat_data.get(source_id,[])
	message.append(AgentMemory.template_memory(prompt,role,character_name))
	chat_data[source_id] = message

var chat_data : Dictionary = {
	
}
