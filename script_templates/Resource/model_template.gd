# meta-name: ModelAPI
# meta-description: ModelAPI adapter

@tool
#class_name NameModel
extends BaseModel


# Config
func _default_model():
	#model_name = ModelLayer.DEFAULT
	pass

func _validate_property(property: Dictionary) -> void:
	if property.name == "api_key":
		property.hint = PROPERTY_HINT_PASSWORD
	if property.name == "model_name":
		property.hint = PROPERTY_HINT_ENUM
		#property.hint_string = ",".join(ModelLayer._oai)


# History
# Format the historical records into the historical record format used by the model.
func _parse_memory(agent_memory : Array = []):
	var history = agent_memory
	return history


# Request
# Format the request data into the request data dictionary required by the model.
func _generator_request(prompt : String, history, role : String = "user", 
				char_name : String = "", base64url : Array = ["",""]): # base64url [type,url]
	var current = [{
		"role": role,
		"content":
				[{"type": "text", "text": prompt}]
		}]
	if !char_name.is_empty():
		current[0]["content"][0]["name"] = char_name
	
	var requset_data = {
		"head" : ["Content-Type: application/json"],
		"body" : {},
		"url" : api_url
	}
	return requset_data


# Response
# Parse response data.
func _parse_response(data : Dictionary):
	var answer : Dictionary = {
		"debug":{
			"model": "",
			"id": "response id",
			"finish_reason": "", # [stop, length, content_filter, insufficient_system_resource]
			"time": Time.get_unix_time_from_system(),
			"total_tokens": 0
			},
		"reasoning_content": "",
		"message":{
			"role": "assistant",
			"content": JSON.stringify(data)
			},
	}
	if data.has("tool_calls"):
		var call_list = data["tool_calls"]
		var tool_list = []
		for call in call_list:
			if call is Dictionary and call.has("function") and \
					call["function"] is Dictionary and call["function"].has("name"):
				var tool : Dictionary = {
					"name": call["function"]["name"],
					"arguments": JSON.parse_string(call["function"].get("arguments","{}"))
				}
				tool_list.append(tool)
		if !tool_list.is_empty():
			answer["tool_calls"] = tool_list
	return answer
