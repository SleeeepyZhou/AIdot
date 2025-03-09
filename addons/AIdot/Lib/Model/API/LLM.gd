@tool
class_name LLMAPI
extends AIAPI
## LLM's API Node Class

## LLM's reply signal contains a parsed reply string or error message.
signal llm_response

## LLM's request method involves entering prompt words and receiving a response in the signal.
func run_llm(prompt : String, history : Array = [], 
			role : String = "user", char_name : String = ""):
	var request_data = model.prepare_request(prompt, history, role, char_name)
	var response = await _get_result(request_data["head"],request_data["body"],request_data["url"])
	var result = model.get_response(response)
	llm_response.emit(result)
