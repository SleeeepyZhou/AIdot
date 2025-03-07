
func read_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed: ", path)
		return {}
	var json_data = file.get_as_text() # 读取文件内容
	file.close()

	var parse = JSON.parse_string(json_data)
	if parse:
		return parse
	else:
		push_error("Failed: JSON parse")
		return {}

func find_json(response : String):
	pass
