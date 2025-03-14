@tool
class_name OpenAIModel
extends BaseModel

func _default_model():
	model_type = ModelLayer.OPENAI.GPT_4O_MINI

func _validate_property(property: Dictionary) -> void:
	if property.name == "api_key":
		property.hint = PROPERTY_HINT_PASSWORD
	if property.name == "model_type":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(ModelLayer._oai)

	#if !format.is_empty() and !is_run:
		#temp_data["response_format"] = format
