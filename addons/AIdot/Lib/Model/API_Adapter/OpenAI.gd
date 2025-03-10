@tool
class_name OpenAIModel
extends BaseModel


	#if !format.is_empty() and !is_run:
		#temp_data["response_format"] = format
