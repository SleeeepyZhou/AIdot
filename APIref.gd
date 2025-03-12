extends Node

func readsave():
	var save_data : Array = ["https://api.openai.com/v1/chat/completions", ""]
	return save_data


## API工具

# 线程池
var maxhttp : int = 10
var is_run : bool = false

# API运行
var api_url : String
var api_key : String
var time_out : int = 10


## 各家API模块

'''
示例结构
{"type": "json_schema",
"json_schema": {"name": "image_analysis_response",
				"strict": true,
				"schema": {"type": "object",
							"properties": {"category": { "type": "string" },
											"subject": { "type": "string" },
											"appearance": {"type": "object",
															"properties": {"costume": { "type": "string" },
																			"prop": { "type": "string" },
																			"expression": { "type": "string" }},
															"required": ["costume", "prop", "expression"],
															"additionalProperties": false},
											},
							"required": ["category", "subject", "appearance"],
							"additionalProperties": false}
				}
}
'''
func get_result(headers, data, sss=""):
	pass

# 结构化输出
var format : Dictionary = {}

# 词，图，模，质
func gemini_api(input) -> String:
	var inputprompt : String = input[0]
	var base64image : String = input[1]
	
	var tempprompt = inputprompt
	#var gemini_format
	#if formatrespon > -1 and !is_run:
		#format = %SchemaBox.send()
		#if !format.is_empty():
			#gemini_format = format["json_schema"]["schema"]  "properties"  "required"
	#is_run = true
	if !("Return output in json format:" in inputprompt):
		tempprompt += "Return output in json format: {description: description, \
						features: [feature1, feature2, feature3, etc]}"
	var tempdata = {
			"contents": [
				{"parts": [
						{"text": tempprompt}
							]}
						]
			}
	if !base64image.is_empty():
		tempdata["contents"][0]["parts"].append({"inline_data": {
										"mime_type": "image/jpeg",
										"data": base64image}})
	var data = JSON.stringify(tempdata)
	var headers : PackedStringArray = ["Content-Type: application/json"]
	var url : String = api_url + "/models/gemini-1.5-pro-exp-0801:generateContent?key=" + api_key
	# https://generativelanguage.googleapis.com/v1beta
	var result = await get_result(headers, data, url)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if (json_result.has("candidates") and json_result["candidates"].size() > 0) and\
					json_result["candidates"][0].has("content") and\
					(json_result["candidates"][0]["content"].has("parts") and \
					json_result["candidates"][0]["content"]["parts"].size() > 0) and \
					json_result["candidates"][0]["content"]["parts"][0].has("text"):
				answer = json_result["candidates"][0]["content"]["parts"][0]["text"]
			else:
				answer = str(json_result)
		return answer
	else:
		return result[1]


func claude_api(input) -> String:
	var inputprompt : String = input[0]
	var base64image : String = input[1]
	
	var temp_data = {
		"model": "claude_api",
		"max_tokens": 300,
		"messages": [{
					"role": "user", 
					"content": [{
							"type": "text", 
							"text": inputprompt
								}]
					}]
							}
	if !base64image.is_empty():
		temp_data["messages"][0]["content"].push_front({
							"type": "image", 
							"source": {"type": "base64",
										"media_type": "image/jpeg",
										"data": base64image}
														})
	var data = JSON.stringify(temp_data)
	var headers : PackedStringArray = ["Content-Type: application/json",
			"x-api-key:" + api_key,
			"anthropic-version: 2023-06-01"]
	
	var result = await get_result(headers, data)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if json_result.has("content") and\
				json_result["content"].size() > 0 and\
				json_result["content"][0].has("text"):
				answer = json_result["content"][0]["text"]
			else:
				answer = str(json_result)
		return answer
	else:
		return result[1]
