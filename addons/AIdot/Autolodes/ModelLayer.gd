@tool
extends Node

const EXAMPLE_PATH = "res://addons/AIdot/Res/Data/ENV_example.json"
# User env
## The client-side retrieves the Callable for the default URL and key, 
## with the Callable input being mod_type, and outputs [URL, key].
var user_getenv : Callable = _get_env_example
func _get_env_example(mod_type : String) -> Array:
	var env_path = "user://.env"
	var json_tool = JsonTool.new()
	var file = FileAccess.open(env_path, FileAccess.READ)
	if !file:
		var dir := DirAccess.open("user://")
		if dir.copy(EXAMPLE_PATH, env_path) != OK:
			push_error("Unable to create 'res://.env' file, please copy the ENV_example.")
	var env_data = json_tool.read_json(env_path)
	return [env_data["url"].get(mod_type,""),env_data["key"].get(mod_type,"")] # url, key
## This is the method to obtain the user ".env" default URL and key. Please 
## modify the Callable variable user_getenv in ModelLayer and specify a new 
## method to automatically obtain the user default URL and key.
func get_user_env(mod_type : String) -> Array:
	var env_set = user_getenv.call(mod_type)
	return env_set # url, key

# Developer env
func _update_gitignore():
	var gitignore_path = "res://.gitignore"
	var gitignore_content = []
	if !FileAccess.file_exists(gitignore_path):
		var file = FileAccess.open(gitignore_path, FileAccess.WRITE)
		file.store_string(".env\n")
		file.close()
	else:
		var file = FileAccess.open(gitignore_path, FileAccess.READ)
		gitignore_content = file.get_as_text().split("\n")
		file.close()
		if !gitignore_content.has(".env"):
			var Wfile = FileAccess.open(gitignore_path, FileAccess.WRITE)
			gitignore_content.append(".env")
			var ignore = "\n".join(gitignore_content)
			Wfile.store_string(ignore)
func _get_env(model_type : String) -> Array:
	var type = get_type(model_type)
	if !OS.is_debug_build():
		return ModelLayer.get_user_env(type)
	
	var env_data
	var json_tool = JsonTool.new()
	var env_path = "res://.env"
	var file = FileAccess.open(env_path, FileAccess.READ)
	if !file:
		var dir := DirAccess.open("res://")
		if dir.copy(EXAMPLE_PATH, env_path) != OK:
			push_error("Unable to create 'res://.env' file, please copy the ENV_example.")
		else:
			_update_gitignore()
	env_data = json_tool.read_json(env_path)
	var env_set = [env_data["url"].get(type,""),env_data["key"].get(type,"")]
	return env_set

## Creat a model resource.
func creat_model(model_name : String, url : String = "", key : String = "", 
					config : Dictionary = {}):
	var type = get_type(model_name)
	if type == "OPENAI":
		return OpenAIModel.new(model_name, url, key, config)
	elif type == "QWEN":
		return QwenModel.new(model_name, url, key, config)
	elif type == "DEEPSEEK":
		return DeepSeekModel.new(model_name, url, key, config)
	
	else:
		return BaseModel.new(model_name, url, key, config)


## Get model type. 
static func get_type(model_name : String):
	if _oai.has(model_name):
		return "OPENAI"
	elif _qw.has(model_name):
		return "QWEN"
	elif _ds.has(model_name):
		return "DEEPSEEK"
	
	else:
		return DEFAULT


# Type
const DEFAULT = "basemodel"

const VLM_MODEL = [OPENAI.GPT_4O, OPENAI.GPT_4O_MINI, OPENAI.O3_MINI,
	OPENAI.O1, OPENAI.O1_MINI, OPENAI.O1_PREVIEW, 
	QWEN.QWEN_2_5_VL_72B, QWEN.QWEN_VL_MAX, QWEN.QWEN_VL_PLUS]

# GPT models
const _oai = [OPENAI.GPT_3_5_TURBO, OPENAI.GPT_4, OPENAI.GPT_4_TURBO, OPENAI.GPT_4O, 
			OPENAI.GPT_4O_MINI, OPENAI.GPT_4_5_PREVIEW, OPENAI.O1, OPENAI.O1_PREVIEW,
			OPENAI.O1_MINI, OPENAI.O3_MINI]
class OPENAI:
	const GPT_3_5_TURBO = "gpt-3.5-turbo"
	const GPT_4 = "gpt-4"
	const GPT_4_TURBO = "gpt-4-turbo"
	const GPT_4O = "gpt-4o"
	const GPT_4O_MINI = "gpt-4o-mini"
	const GPT_4_5_PREVIEW = "gpt-4.5-preview"
	const O1 = "o1"
	const O1_PREVIEW = "o1-preview"
	const O1_MINI = "o1-mini"
	const O3_MINI = "o3-mini"

# DeepSeek models
const _ds = [DEEPSEEK.DEEPSEEK_CHAT, DEEPSEEK.DEEPSEEK_REASONER]
class DEEPSEEK:
	const DEEPSEEK_CHAT = "deepseek-chat"
	const DEEPSEEK_REASONER = "deepseek-reasoner"

# Qwen models (Aliyun)
const _qw = [QWEN.QWEN_MAX, QWEN.QWEN_PLUS, QWEN.QWEN_TURBO, QWEN.QWEN_LONG, QWEN.QWEN_VL_MAX,
			QWEN.QWEN_VL_PLUS, QWEN.QWEN_MATH_PLUS, QWEN.QWEN_MATH_TURBO, QWEN.QWEN_CODER_TURBO,
			QWEN.QWEN_2_5_CODER_32B, QWEN.QWEN_2_5_VL_72B, QWEN.QWEN_2_5_72B, QWEN.QWEN_2_5_32B,
			QWEN.QWEN_2_5_14B, QWEN.QWEN_QWQ_32B, QWEN.QWEN_QVQ_72B]
class QWEN:
	const QWEN_MAX = "qwen-max"
	const QWEN_PLUS = "qwen-plus"
	const QWEN_TURBO = "qwen-turbo"
	const QWEN_LONG = "qwen-long"
	const QWEN_VL_MAX = "qwen-vl-max"
	const QWEN_VL_PLUS = "qwen-vl-plus"
	const QWEN_MATH_PLUS = "qwen-math-plus"
	const QWEN_MATH_TURBO = "qwen-math-turbo"
	const QWEN_CODER_TURBO = "qwen-coder-turbo"
	const QWEN_2_5_CODER_32B = "qwen2.5-coder-32b-instruct"
	const QWEN_2_5_VL_72B = "qwen2.5-vl-72b-instruct"
	const QWEN_2_5_72B = "qwen2.5-72b-instruct"
	const QWEN_2_5_32B = "qwen2.5-32b-instruct"
	const QWEN_2_5_14B = "qwen2.5-14b-instruct"
	const QWEN_QWQ_32B = "qwq-32b-preview"
	const QWEN_QVQ_72B = "qvq-72b-preview"
