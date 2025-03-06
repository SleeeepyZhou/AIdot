class_name BaseModel
extends Resource

var model_type : String = ModelType.DEFAULT

var api_url : String
var api_key : String

var model_config_dict : Dictionary

func _parse_memory():
	pass
func get_memory():
	pass

func _generator_request():
	pass
func create_request(prompt : String, history : Array = []):
	_generator_request()
	var requset_data = {
		"head" : ["Content-Type: application/json"],
		"body" : {},
		"url" : api_url
	}
	return requset_data

func _parse_response(data : Dictionary):
	var answer : String = ""
	return answer
func get_response(response : Array) -> String:
	var answer : String = ""
	if response[0]:
		answer = _parse_response(response[1])
	else:
		answer = response[1]
	return answer
