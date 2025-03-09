@tool
@icon("res://addons/AIdot/Res/UI/AIResource.svg")
class_name BaseModel
extends Resource

@export_group("Model inf")
@export var model_name : String = "BaseModel"
@export var model_type : String = ModelType.DEFAULT
@export var model_config_dict : Dictionary = {}

@export_group("API inf")
@export var api_url : String = ""
@export var api_key : String = ""

func _get_env() -> Array:
	const EXAMPLE_PATH = "res://addons/AIdot/Lib/Model/ENV_example.json"
	var env_data
	var mod_type = ModelType.model_type(self)
	if !Engine.is_editor_hint():
		return ModelLayer.get_user_env(model_type)
	else:
		var json_tool = preload("res://addons/AIdot/Utils/Json.gd").new()
		var env_path = "res://.env"
		var file = FileAccess.open(env_path, FileAccess.READ)
		if !file:
			var dir := DirAccess.open("res://")
			if dir.copy(EXAMPLE_PATH, env_path) != OK:
				push_error("Unable to create 'res://.env' file, please copy the ENV_example.")
		env_data = json_tool.read_json(env_path)
	var env_set = [env_data["url"].get(mod_type,""),env_data["key"].get(mod_type,"")]
	return env_set
func _init(mod_type, url : String = "", key : String = "", config : Dictionary = {}):
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

func _generator_request(prompt : String, history, role : String = "user", 
				char_name : String = "", base64url : Array = ["",""]):
	var requset_data = {
		"head" : ["Content-Type: application/json"],
		"body" : {},
		"url" : ""
	}
	return requset_data
const _ROLE = ["user", "system", "assistant", "tool"]
## Format the request data into the request data dictionary required by the model.
func prepare_request(prompt : String, memory : Array = [], role : String = "user",
					char_name : String = "", base64url : Array = ["",""]):
	if !_ROLE.has(role):
		role = "user"
	var mod_memory = format_memory(memory)
	var requset_data = _generator_request(prompt, mod_memory, role, char_name, base64url)
	requset_data.merge(model_config_dict, true)
	return requset_data

func _parse_response(data : Dictionary):
	var answer : String = ""
	return answer
## Parse response data.
func get_response(response : Array) -> String:
	var answer : String = ""
	if response.is_empty():
		push_error("No data!")
		return "No data!"
	if response[0]:
		answer = _parse_response(response[1])
	else:
		answer = response[1]
	return answer

func memory_template():
	
	pass

func save_model(path : String):
	var saved = ResourceSaver.save(self,path)
	if saved == OK:
		print(model_name, get_rid(), " saved successfully.")
	else:
		print(model_name, get_rid(), " save failed.")
