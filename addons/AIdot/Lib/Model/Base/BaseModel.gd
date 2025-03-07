@tool
@icon("res://addons/AIdot/Res/UI/AIResource.svg")
class_name BaseModel
extends Resource

@export_group("Model inf")
@export var model_name : String = "BaseModel"
@export var model_type : String = ModelType.DEFAULT
var model_config_dict : Dictionary = {}

@export_group("API inf")
@export var api_url : String = ""
@export var api_key : String = ""

func _init(mod_type, url : String = "", key : String = "", config : Dictionary = {}):
	model_type = mod_type
	api_url = url
	api_key = key
	model_config_dict = config

func _parse_memory(agent_memory : Array):
	return agent_memory
## Format the historical records into the historical record format used by the model.
func format_memory(agent_memory : Array):
	return _parse_memory(agent_memory)

func _generator_request(prompt : String, history):
	var requset_data = {
		"head" : ["Content-Type: application/json"],
		"body" : {},
		"url" : api_url
	}
	return requset_data
## Format the request data into the request data dictionary required by the model.
func prepare_request(prompt : String, history : Array = []):
	var mod_memory = format_memory(history)
	var requset_data = _generator_request(prompt,mod_memory)
	return requset_data

func _parse_response(data : Dictionary):
	var answer : String = ""
	return answer
## Parse response data.
func get_response(response : Array) -> String:
	var answer : String = ""
	if response[0]:
		answer = _parse_response(response[1])
	else:
		answer = response[1]
	return answer

func save_model(path : String):
	var saved = ResourceSaver.save(self,path)
	if saved == OK:
		print(model_name, get_rid(), " saved successfully.")
	else:
		print(model_name, get_rid(), " save failed.")
