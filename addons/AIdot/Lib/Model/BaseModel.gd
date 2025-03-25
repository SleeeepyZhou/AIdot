@tool
@icon("res://addons/AIdot/Res/UI/Icon/Model.svg")
extends AIdotResource
class_name BaseModel

@export_group("Model informationf")
@export var custom_name : String = "BaseModel"
## In [ModelLayer]
@export var model_name : String
@export var model_config_dict : Dictionary = {}
var tools : Dictionary = {"tools":[]}

@export_group("API information")
@export var api_url : String = ""
@export var api_key : String = ""

func _validate_property(property: Dictionary) -> void:
	if property.name == "api_key":
		property.hint |= PROPERTY_HINT_PASSWORD

func _default_model():
	model_name = ModelLayer.DEFAULT

func _init(mod_name : String = "", url : String = "", key : String = "", 
			config : Dictionary = {}):
	model_name = mod_name
	if model_name.is_empty():
		_default_model()
	model_config_dict = config
	api_url = url
	api_key = key
	if url.is_empty():
		var base_url = ModelLayer._get_env(model_name)
		api_url = base_url[0]
		if key.is_empty():
			api_key = base_url[1]

func _parse_memory(agent_memory : Array = []):
	return agent_memory
## Format the historical records into the historical record format used by the model.
func format_memory(agent_memory : Array):
	return _parse_memory(agent_memory)

# Compatible with OAI
func _generator_request(prompt : String, history, role : String = "user", 
				char_name : String = "", base64url : Array = ["",""]):
	var current = [{
		"role": role,
		"content":
				[{"type": "text", "text": prompt}]
		}]
	if !char_name.is_empty():
		current[0]["content"][0]["name"] = char_name
	var temp_data = {
		"model": model_name,
		"messages": history+current
		}
	var headers : PackedStringArray = ["Content-Type: application/json", 
										"Authorization: Bearer " + api_key]
	
	if !base64url[0].is_empty():
		temp_data["messages"][0]["content"].append(
							{"type": base64url[0], 
							base64url[0]:
								{"url": "data:image/jpeg;base64," + base64url[1]}})
	var data = JSON.stringify(temp_data)
	var requset_data = {
		"head" : headers,
		"body" : data,
		"url" : api_url + "/chat/completions"
	}
	return requset_data
# Format the request data into the request data dictionary required by the model.
const _ROLE = ["user", "system", "assistant", "tool"]
func prepare_request(prompt : String, memory : Array = [], role : String = "user",
					char_name : String = "", base64url : Array = ["",""]):
	if !_ROLE.has(role):
		role = "user"
	var mod_memory = format_memory(memory)
	var requset_data = _generator_request(prompt, mod_memory, role, char_name, base64url)
	requset_data.merge(model_config_dict, true)
	if !tools["tools"].is_empty():
		requset_data.merge(tools, true)
	## Currently not supporting stream.
	requset_data.merge({"stream": false}, true)
	
	return requset_data

func _parse_response(data : Dictionary):
	var answer
	var json_result = data
	if json_result != null:
		# 安全
		if json_result.has("choices") and json_result["choices"].size() > 0 and\
				json_result["choices"][0].has("message") and\
				json_result["choices"][0]["message"].has("content"):
			answer = {
				"debug":{
					"model": json_result.get("model",""),
					"id": json_result.get("id",""),
					"finish_reason": json_result["choices"][0].get("finish_reason",""),
					"time": json_result.get("created",""),
					"total_tokens": json_result.get("usage",{}).get("total_tokens",0)
					},
				"reasoning_content": 
					json_result["choices"][0]["message"].get("reasoning_content",""),
				"message":{
					"role": json_result["choices"][0]["message"]["role"],
					"content": json_result["choices"][0]["message"]["content"]
					}
				}
			if json_result["choices"][0]["message"].has("tool_calls") and \
					json_result["choices"][0]["message"]["tool_calls"] is Array:
				var call_list = json_result["choices"][0]["message"]["tool_calls"]
				var tool_list = []
				for call in call_list:
					if call is Dictionary and call.has("function") and \
							call["function"] is Dictionary and call["function"].has("name"):
						tool_list.append(call["function"])
				if !tool_list.is_empty():
					answer["tool_calls"] = tool_list
		else:
			answer = str(json_result)
	return answer
# Parse response data for debug.
func _get_debug_response(response : Array) -> Dictionary:
	var answer : Dictionary = {}
	if response.is_empty():
		push_error("No data!")
		return {"error": "No data!"}
	if response[0]:
		answer = _parse_response(response[1])
	else:
		answer = {"error": response[1]}
	return answer

## Parse response data return answer Array[answer String, debug Dictionary]. 
## If debug Dictionary has "error", 
func get_response(response : Array) -> Array:
	var parse = _get_debug_response(response)
	if parse.get("error"):
		return ["Error: " + parse["error"], parse]
	var answer = ""
	if parse.get("reasoning_content") and !parse["reasoning_content"].is_empty():
		answer = "<think>\n" + parse["reasoning_content"] + "\n</think>\n"
	answer += parse["message"]["content"]
	return [answer, parse]

func save_model(path : String):
	var saved = ResourceSaver.save(self,path)
	if saved == OK:
		print(model_name, get_rid(), " saved successfully.")
	else:
		print(model_name, get_rid(), " save failed.")
