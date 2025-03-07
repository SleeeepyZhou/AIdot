# meta-name: ModelAPI
# meta-description: ModelAPI adapter

#@tool
#class_name NameModel
extends BaseModel


func _init(mod_type, url : String = "", key : String = "", config : Dictionary = {}):
	model_type = mod_type
	if url.is_empty() or key.is_empty():
		var _json_tool = preload("res://addons/AIdot/Utils/Json.gd").new()
		var dafult = _json_tool.read_json("res://addons/AIdot/Res/Data/base_url.json")
	api_url = url
	if api_url.is_empty():
		var temp_url
		pass
	api_key = key
	if api_key.is_empty():
		pass
	model_config_dict = config

# Format the historical records into the historical record format used by the model.
func _parse_memory(agent_memory : Array):
	var history
	return history

# Format the request data into the request data dictionary required by the model.
func _generator_request(prompt : String, history):
	var requset_data = {
		"head" : ["Content-Type: application/json"],
		"body" : {},
		"url" : api_url
	}
	return requset_data

# Parse response data.
func _parse_response(data : Dictionary):
	var answer : String = ""
	return answer
