@tool
extends Node

func _get_env_example(mod_type : String) -> Array:
	const EXAMPLE_PATH = "res://addons/AIdot/Lib/Model/ENV_example.json"
	var env_path = "user://.env"
	var json_tool = preload("res://addons/AIdot/Utils/Json.gd").new()
	var file = FileAccess.open(env_path, FileAccess.READ)
	if !file:
		var dir := DirAccess.open("user://")
		if dir.copy(EXAMPLE_PATH, env_path) != OK:
			push_error("Unable to create 'res://.env' file, please copy the ENV_example.")
	var env_data = json_tool.read_json(env_path)
	return [env_data["url"].get(mod_type,""),env_data["key"].get(mod_type,"")] # url, key

## This is an example method that can directly override and modify the API key reading behavior 
## after exporting application.
func get_user_env(mod_type : String) -> Array:
	var env_set = _get_env_example(mod_type)
	return env_set # url, key


func creat_model(mod_type : String, url : String = "", key : String = "", config : Dictionary = {}):
	var type = get_type(mod_type)
	if type == "OPENAI":
		return OpenAIModel.new(mod_type, url, key, config)
	elif type == "QWEN":
		return QwenModel.new(mod_type, url, key, config)
	elif type == "DEEPSEEK":
		return DeepSeekModel.new(mod_type, url, key, config)
	
	else:
		return BaseModel.new(mod_type, url, key, config)


const VLM_MODEL = [OPENAI.GPT_4O, OPENAI.GPT_4O_MINI, OPENAI.O3_MINI,
	OPENAI.O1, OPENAI.O1_MINI, OPENAI.O1_PREVIEW, 
	QWEN.QWEN_2_5_VL_72B, QWEN.QWEN_VL_MAX, QWEN.QWEN_VL_PLUS]

static func get_type(model_type : String):
	if _oai.has(model_type):
		return "OPENAI"
	elif _qw.has(model_type):
		return "QWEN"
	elif _ds.has(model_type):
		return "DEEPSEEK"
	
	else:
		return DEFAULT

const DEFAULT = "basemodel"

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
