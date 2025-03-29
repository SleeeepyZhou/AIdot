extends LineEdit

func _validate_property(property: Dictionary) -> void:
	if property.name == "text":
		property.usage |= PROPERTY_USAGE_SECRET
