@tool
class_name VLMAPI
extends AIAPI
## VLM's API Node Class

func _request(prompt : String, image : Texture2D = null, history : Array = [], 
			role : String = "user", char_name : String = ""):
	var base64 := ["",""]
	if !ModelLayer.VLM_MODEL.has(model.model_type):
		image = null
		push_error("This model is not a VLM! Ignore multimodal inputs.")
	if image:
		var processor = ImageProcessor.new()
		base64 = ["image_url", processor.texture_to_base64(image)]
	var request_data = model.prepare_request(prompt, history, role, char_name, base64)
	var response = await _get_result(request_data["head"],request_data["body"],request_data["url"])
	return response

## VLM's request method involves entering prompt words and image, 
## and receiving a response in the signal. It return a Dictionary for debug.
func run_api_debug(prompt : String, image : Texture2D = null, history : Array = [], 
			role : String = "user", char_name : String = ""):
	var response = await _request(prompt, image, history, role, char_name)
	var result = model._get_debug_response(response)
	response_debug.emit(result)

## VLM's request method involves entering prompt words and image, 
## and receiving a response in the signal. 
func run_api(prompt : String, image : Texture2D = null, history : Array = [], 
			role : String = "user", char_name : String = ""):
	var get_response = await _request(prompt, image, history, role, char_name)
	var result = model.get_response(get_response)
	response.emit(result[0], result[1])
