class_name VLMAPI
extends AIAPI
## VLM's API Node Class

## VLM's reply signal contains a parsed reply string or error message.
signal vlm_response

## VLM's request method involves entering prompt words and image, and receiving a response in the signal.
func run_vlm(prompt : String, image):
	var request_data = model.create_request(prompt)
	var response = await _get_result(request_data["head"],request_data["body"],request_data["url"])
	var result = model.get_response(response)
	vlm_response.emit(result)
