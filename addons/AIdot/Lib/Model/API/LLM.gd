@tool
class_name LLMAPI
extends AIAPI
## LLM's API Node Class

## LLM's request method involves entering prompt words and receiving a response in the signal. 
## It return a Dictionary for debug.
func run_api_debug(prompt : String, history : Array = [], role : String = "user", 
		requset_id : int = 0, char_name : String = "") -> Array:
	var request_data = model.prepare_request(prompt, history, role, char_name)
	var response = await _get_result(request_data["head"],request_data["body"],request_data["url"])
	var result = model._get_debug_response(response)
	response_debug.emit(result, requset_id)
	return [result, requset_id]

## LLM's request method involves entering prompt words and receiving a response in the signal.
func run_api(prompt : String, history : Array = [], role : String = "user", 
		requset_id : int = 0, char_name : String = "") -> Array:
	var request_data = model.prepare_request(prompt, history, role, char_name)
	var get_response = await _get_result(request_data["head"],request_data["body"],request_data["url"])
	var result = model.get_response(get_response)
	response.emit(result[0], result[1], requset_id)
	return [result[0], result[1], requset_id]
