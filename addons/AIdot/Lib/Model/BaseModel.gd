@tool
@icon("res://addons/AIdot/Res/UI/AIResource.svg")
extends Resource
class_name BaseModel

@export_group("Model informationf")
@export var model_name : String = "BaseModel"
## In [ModelLayer]
@export var model_type : String = ModelLayer.DEFAULT
@export var model_config_dict : Dictionary = {}

@export_group("API information")
@export var api_url : String = ""
@export var api_key : String = ""

func _update_gitignore():
	var gitignore_path = "res://.gitignore"
	var gitignore_content = []
	if !FileAccess.file_exists(gitignore_path):
		var file = FileAccess.open(gitignore_path, FileAccess.WRITE)
		file.store_string(".env\n")
		file.close()
	else:
		var file = FileAccess.open(gitignore_path, FileAccess.READ)
		gitignore_content = file.get_as_text().split("\n")
		file.close()
		if !gitignore_content.has(".env"):
			var Wfile = FileAccess.open(gitignore_path, FileAccess.WRITE)
			gitignore_content.append(".env")
			var ignore = "\n".join(gitignore_content)
			Wfile.store_string(ignore)
func _get_env() -> Array:
	var type = ModelLayer.get_type(model_type)
	if !OS.is_debug_build():
		return ModelLayer.get_user_env(type)
	
	const EXAMPLE_PATH = "res://addons/AIdot/Lib/Model/ENV_example.json"
	var env_data
	var json_tool = preload("res://addons/AIdot/Utils/Json.gd").new()
	var env_path = "res://.env"
	var file = FileAccess.open(env_path, FileAccess.READ)
	if !file:
		var dir := DirAccess.open("res://")
		_update_gitignore()
		if dir.copy(EXAMPLE_PATH, env_path) != OK:
			push_error("Unable to create 'res://.env' file, please copy the ENV_example.")
	env_data = json_tool.read_json(env_path)
	var env_set = [env_data["url"].get(type,""),env_data["key"].get(type,"")]
	return env_set
func _init(mod_type : String = ModelLayer.DEFAULT, 
			url : String = "", key : String = "", config : Dictionary = {}):
	model_type = mod_type
	model_config_dict = config
	api_url = url
	api_key = key
	if api_url.is_empty():
		var base_url = _get_env()
		api_url = base_url[0]
		if api_key.is_empty():
			api_key = base_url[1]

func _parse_memory(agent_memory : Array = []):
	return agent_memory
## Format the historical records into the historical record format used by the model.
func format_memory(agent_memory : Array):
	return _parse_memory(agent_memory)

## Compatible with OAI
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
		"model": model_type,
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
## Format the request data into the request data dictionary required by the model.
const _ROLE = ["user", "system", "assistant", "tool"]
func prepare_request(prompt : String, memory : Array = [], role : String = "user",
					char_name : String = "", base64url : Array = ["",""]):
	if !_ROLE.has(role):
		role = "user"
	var mod_memory = format_memory(memory)
	var requset_data = _generator_request(prompt, mod_memory, role, char_name, base64url)
	requset_data.merge(model_config_dict, true)
	
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
				"reasoning_content": json_result["choices"][0]["message"].get("reasoning_content",""),
				"message":{
					"role": json_result["choices"][0]["message"]["role"],
					"content": json_result["choices"][0]["message"]["content"]
					},
				}
		else:
			answer = str(json_result)
	return answer
## Parse response data for debug.
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
func get_response(response : Array) -> Array:
	var parse = _get_debug_response(response)
	if parse.get("error"):
		return ["Error: " + parse["error"], parse]
	var answer = ""
	if parse.get("reasoning_content") and !parse["reasoning_content"].is_empty():
		answer = "<think>" + parse["reasoning_content"] + "</think>"
	answer += parse["message"]["content"]
	return [answer, parse]

func save_model(path : String):
	var saved = ResourceSaver.save(self,path)
	if saved == OK:
		print(model_name, get_rid(), " saved successfully.")
	else:
		print(model_name, get_rid(), " save failed.")
