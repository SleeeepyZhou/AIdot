@tool
class_name QwenModel
extends BaseModel

func _default_model():
	model_type = ModelLayer.QWEN.QWEN_MAX

func _validate_property(property: Dictionary) -> void:
	if property.name == "api_key":
		property.hint = PROPERTY_HINT_PASSWORD
	if property.name == "model_type":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(ModelLayer._qw)
