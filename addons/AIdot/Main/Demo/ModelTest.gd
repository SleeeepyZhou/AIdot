extends Node2D

func _ready():
	var testmod = QwenModel.new(ModelType.QWEN.QWEN_MAX)
	var api = LLMAPI.new(testmod, 15)
	add_child(api)
	api.run_llm("Test call...")
	var received = await api.llm_response
	print(received[0])
