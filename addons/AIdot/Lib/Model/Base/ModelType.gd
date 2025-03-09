class_name ModelType

static func model_type(model : BaseModel):
	if model is OpenAIModel:
		return "OPENAI"
	elif model is QwenModel:
		return "QWEN"
	#elif model is DeepSeekModel:
		#return "DEEPSEEK"
	
	else:
		return DEFAULT

const DEFAULT = ""

# GPT models
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
class DEEPSEEK:
	const DEEPSEEK_CHAT = "deepseek-chat"
	const DEEPSEEK_REASONER = "deepseek-reasoner"

# Qwen models (Aliyun)
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
