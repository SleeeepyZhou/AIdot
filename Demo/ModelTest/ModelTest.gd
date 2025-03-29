extends Node2D

func _ready():
	var testmod = QwenModel.new(ModelLayer.QWEN.QWEN_MAX)
	var api = LLMAPI.new(testmod, 15)
	add_child(api)
	api.run_llm("Test call...")
	var received = await api.response
	print(received[0])
