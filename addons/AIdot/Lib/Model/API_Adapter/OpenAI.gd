@tool
class_name OpenAIModel
extends BaseModel

# Format the historical records into the historical record format used by the model.
#func _parse_memory(agent_memory : Array = []):
	#var history = agent_memory
	#return history

# Format the request data into the request data dictionary required by the model.
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
		"messages": history+current,
		"max_tokens": 300
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

# Parse response data.
func _parse_response(data : Dictionary):
	var answer : String = ""
	var json_result = data
	if json_result != null:
		# 安全
		if json_result.has("choices") and json_result["choices"].size() > 0 and\
				json_result["choices"][0].has("message") and\
				json_result["choices"][0]["message"].has("content"):
			answer = json_result["choices"][0]["message"]["content"]
		else:
			answer = str(json_result)
	return answer
