@tool
extends AIMemory
class_name LongMemory

var his_content : PackedStringArray = []
var idx_role : PackedStringArray = []
var idx_name : PackedStringArray = []

func reset():
	his_content.clear()
	idx_role.clear()
	idx_name.clear()

func set_history(
	his : PackedStringArray, 
	idx_r : PackedStringArray, 
	idx_n : PackedStringArray
	):
	his_content = his
	idx_role = idx_r
	idx_name = idx_n

func write_history(idx : int, content : String, role : String, char_name : String = ""):
	his_content[idx] = content
	idx_role[idx] = role
	idx_name[idx] = char_name

func add_history(content : String, role : String, char_name : String = ""):
	his_content.append(content)
	idx_role.append(role)
	idx_name.append(char_name)

func rag_zip():
	zip()

func zip():
	
	pass

func retrieval(prompt: String) -> String:
	var new_prompt = prompt + "------\nYou recalled the following:"
	
	
	new_prompt += "\n------"
	return ""
