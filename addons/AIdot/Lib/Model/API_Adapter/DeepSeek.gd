@tool
class_name DeepSeekModel
extends BaseModel

func _default_model():
	model_name = ModelLayer.DEEPSEEK.DEEPSEEK_CHAT

func _validate_property(property: Dictionary) -> void:
	if property.name == "api_key":
		property.hint = PROPERTY_HINT_PASSWORD
	if property.name == "model_name":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(ModelLayer._ds)
