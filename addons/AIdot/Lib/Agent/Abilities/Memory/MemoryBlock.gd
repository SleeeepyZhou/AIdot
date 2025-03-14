@tool
extends AIMemory
class_name MemoryBlock

@export_enum("user","assistant","tool","system") var role: String = "user"
@export_multiline var content: String = ""
@export var character_name: String = ""

var _h_data : Dictionary:
	set(d):
		role = d.get("role", "user")
		content = d.get("content", "")
		character_name = d.get("name", "")
	get:
		if character_name.is_empty():
			return {
				"role": role,
				"content": content
			}
		return {
			"role": role,
			"name": character_name,
			"content": content
		}
