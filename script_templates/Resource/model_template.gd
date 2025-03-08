# meta-name: ModelAPI
# meta-description: ModelAPI adapter

#@tool
#class_name NameModel
extends BaseModel

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
