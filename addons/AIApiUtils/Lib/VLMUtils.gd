extends Node

## 用户数据
const SAVEPATH = "user://data.api"
func reset():
	var access = DirAccess.open(SAVEPATH.get_base_dir())
	access.remove(SAVEPATH)
func api_save(data : Array = ["https://api.openai.com/v1/chat/completions", ""]):
	var save_data = FileAccess.open(SAVEPATH, FileAccess.WRITE)
	save_data.store_var(data)
	save_data.close()
func readsave():
	var save_data : Array = ["https://api.openai.com/v1/chat/completions", ""]
	if FileAccess.file_exists(SAVEPATH):
		var data = FileAccess.open(SAVEPATH, FileAccess.READ).get_var()
		if not data:
			data = save_data
		save_data = data
	else:
		api_save()
		save_data = readsave()
	api_url = save_data[0]
	api_key = save_data[1]
	return save_data


## API工具

# 线程池
var maxhttp : int = 10
var is_run : bool = false

# API运行
var api_url : String
var api_key : String
var time_out : int = 10

const QUALITY = ["high", "low", "auto"]
const API_TYPE = ["gpt-4o-2024-08-06", "gpt-4o-mini", "qwen-vl-plus", \
				"qwen-vl-max", "claude", "gemini-1.5-pro-exp-0801", "local"]

var API_FUNC : Array[Callable] = [Callable(self,"openai_api"), 
								Callable(self,"openai_api"),
								Callable(self,"qwen_api"), 
								Callable(self,"qwen_api"), 
								Callable(self,"claude_api"),
								Callable(self,"gemini_api"),
								Callable(self,"openai_api")]


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

func openai_api(input : Array) -> String:
	# 取参
	var inputprompt : String = input[0]
	var base64image : String = input[1]
	var mod : String = input[2]
	
	# 构造
	var temp_data = {
		"model": mod,
		"messages": [
				{
				"role": "user",
				"content":
						[{"type": "text", "text": inputprompt}]
				}
					],
		"max_tokens": 300
		}
	var headers : PackedStringArray = ["Content-Type: application/json", 
										"Authorization: Bearer " + api_key]
	if !format.is_empty() and !is_run:
		temp_data["response_format"] = format
	if !base64image.is_empty():
		temp_data["messages"][0]["content"].push_front(
							{"type": "image_url", 
							"image_url":
								{"url": "data:image/jpeg;base64," + base64image,
								"detail": input[3]}})
	var data = JSON.stringify(temp_data)
	is_run = true
	
	# 结果
	var result = await get_result(headers, data)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if json_result.has("choices") and json_result["choices"].size() > 0 and\
					json_result["choices"][0].has("message") and\
					json_result["choices"][0]["message"].has("content"):
				answer = json_result["choices"][0]["message"]["content"]
			else:
				answer = str(json_result)
		return answer
	else:
		return result[1]

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


func qwen_api(input) -> String:
	var inputprompt : String = input[0]
	var base64image : String = input[1]
	var mod : String = input[2]
	
	var tempdata = {
		"model": mod,
		"input": {
			"messages": [
				{"role": "system",
				"content": [{"text": "You are a helpful assistant."}]},
				{"role": "user",
				"content": [{"text": inputprompt}]}
						]
				}
					}
	if !base64image.is_empty():
		tempdata["input"]["messages"][1]["content"].push_front({"image": "data:image/jpeg;base64," + base64image})
	var data = JSON.stringify(tempdata)
	var headers : PackedStringArray = ["Authorization: Bearer " + api_key,
										"Content-Type: application/json"]
	
	var result = await get_result(headers, data)
	var answer = ""
	if result[0]:
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if json_result.has("output") and\
				json_result["output"].has("choices") and\
				json_result["output"]["choices"].size() > 0 and\
				json_result["output"]["choices"][0].has("message") and\
				json_result["output"]["choices"][0]["message"].has("content") and\
				json_result["output"]["choices"][0]["message"]["content"].size() > 0 and\
				json_result["output"]["choices"][0]["message"]["content"][0].has("text"):
				answer = json_result["output"]["choices"][0]["message"]["content"][0]["text"]
			else:
				answer = str(json_result)
	elif !result[0]:
		answer = result[1]
	return answer
