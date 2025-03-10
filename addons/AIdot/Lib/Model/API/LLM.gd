@tool
class_name LLMAPI
extends AIAPI
## LLM's API Node Class

## LLM's reply signal contains a parsed reply string or error message Dictionary for debug. 
signal response_debug(debug : Dictionary)

## LLM's request method involves entering prompt words and receiving a response in the signal. 
## It return a Dictionary for debug.
func run_api_debug(prompt : String, history : Array = [], 
			role : String = "user", char_name : String = ""):
	var request_data = model.prepare_request(prompt, history, role, char_name)
	var response = await _get_result(request_data["head"],request_data["body"],request_data["url"])
	var result = model._get_debug_response(response)
	response_debug.emit(result)

## LLM's reply signal contains a parsed reply string or error String and debug Dictionary.
signal response(answer : String, debug : Dictionary)

## LLM's request method involves entering prompt words and receiving a response in the signal.
func run_api(prompt : String, history : Array = [], 
			role : String = "user", char_name : String = ""):
	var request_data = model.prepare_request(prompt, history, role, char_name)
	var response = await _get_result(request_data["head"],request_data["body"],request_data["url"])
	var result = model.get_response(response)
	response.emit(result[0], result[1])
