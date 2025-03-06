class_name OpenAIModel
extends BaseModel

func create_request(prompt : String, history : Array = []):
	var current = [{
		"role": "user",
		"content":
				[{"type": "text", "text": prompt}]
		}]
	var temp_data = {
		"model": model_type,
		"max_tokens": 300
		}
	if !history.is_empty():
		temp_data["messages"] = history+current
	else:
		temp_data["messages"] = current
	
	var headers : PackedStringArray = ["Content-Type: application/json", 
										"Authorization: Bearer " + api_key]
	
	#if !base64image.is_empty():
		#temp_data["messages"][0]["content"].push_front(
							#{"type": "image_url", 
							#"image_url":
								#{"url": "data:image/jpeg;base64," + base64image,
								#"detail": input[3]}})
	var data = JSON.stringify(temp_data)
	var requset_data = {
		"head" : headers,
		"body" : data,
		"url" : api_url
	}
	return requset_data

func _parse_response(data : Dictionary):
	var answer : String = ""
	var json_result = data
	if json_result != null:
		# 安全地尝试
		if json_result.has("choices") and json_result["choices"].size() > 0 and\
				json_result["choices"][0].has("message") and\
				json_result["choices"][0]["message"].has("content"):
			answer = json_result["choices"][0]["message"]["content"]
		else:
			answer = str(json_result)
	return answer
