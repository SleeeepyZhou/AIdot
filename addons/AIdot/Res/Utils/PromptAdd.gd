@tool
class_name PromptProcessor

# 动态提示词
func addition_prompt(text : String, image_path : String = "") -> String: # 提示词，图片路径
	if '{' not in text or '}' not in text:
		return text
	var file_name = image_path.get_file().rstrip("." + image_path.get_extension()) + ".txt"
	var dir_path = text.substr(text.find("{")+1, text.find("}")-text.find("{")-1)
	var full_path = (dir_path + "/" + file_name).simplify_path()
	var file = FileAccess.open(full_path, FileAccess.READ)
	var file_content := ""
	if file:
		file_content = file.get_as_text()
		file.close()
	return text.replace("{" + dir_path + "}", file_content)
