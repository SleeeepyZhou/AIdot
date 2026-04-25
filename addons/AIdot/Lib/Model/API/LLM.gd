@tool
class_name LLMAPI
extends AIAPI
## Unified LLM / VLM API Node.
##
## Handles both text-only (LLM) and multimodal (VLM) requests through a single
## interface. Pass an [Image] [Texture2D] to [method run_api] to enable vision;
## omit it (or pass [code]null[/code]) for a standard text request.
##
## [b]Vision support[/b]: The model must be listed in [member ModelLayer.VLM_MODEL].
## Using a non-VLM model with an image will emit a warning and drop the image.

## Run an LLM (or VLM) request and return [code][answer, debug, request_id][/code].
## [param image] is optional — supply a [Texture2D] to send a vision request.
func run_api(prompt : String, history : Array = [], role : String = "user",
		request_id : int = 0, char_name : String = "",
		image : Texture2D = null) -> Array:
	var request_data = _build_request(prompt, history, role, char_name, image)
	var get_response = await _get_result(request_data["head"], request_data["body"], request_data["url"])
	var result = model.get_response(get_response)
	response.emit(result[0], result[1], request_id)
	return [result[0], result[1], request_id]

## Same as [method run_api] but returns the raw debug Dictionary instead of the
## parsed answer string.
func run_api_debug(prompt : String, history : Array = [], role : String = "user",
		request_id : int = 0, char_name : String = "",
		image : Texture2D = null) -> Array:
	var request_data = _build_request(prompt, history, role, char_name, image)
	var raw = await _get_result(request_data["head"], request_data["body"], request_data["url"])
	var result = model._get_debug_response(raw)
	response_debug.emit(result, request_id)
	return [result, request_id]


func _build_request(prompt : String, history : Array, role : String,
		char_name : String, image : Texture2D) -> Dictionary:
	var base64 := ["", ""]
	if image != null:
		if !ModelLayer.VLM_MODEL.has(model.model_name):
			push_warning("LLMAPI: model '%s' is not in VLM_MODEL list; image will be ignored." \
				% model.model_name)
		else:
			var processor := ImageProcessor.new()
			base64 = ["image_url", processor.texture_to_base64(image)]
	return model.prepare_request(prompt, history, role, char_name, base64)
