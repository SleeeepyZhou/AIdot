@tool
extends EditorPlugin

## Model Layer
func model_layer_enter():
	add_autoload_singleton("ModelLayer", "res://addons/AIdot/Main/Autolodes/ModelLayer.gd")
	
	add_custom_type("AIAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/API.gd"), \
					preload("res://addons/AIdot/Res/UI/key_icon.png"))
	add_custom_type("LLMAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/LLM.gd"), \
					preload("res://addons/AIdot/Res/UI/key.png"))
	add_custom_type("VLMAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/VLM.gd"), \
					preload("res://addons/AIdot/Res/UI/key.png"))
	# Model
	add_custom_type("BaseModel", "Resource", preload("res://addons/AIdot/Lib/Model/BaseModel.gd"), \
					preload("res://addons/AIdot/Res/UI/AIResource.svg"))
	add_custom_type("DeepSeekModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/DeepSeek.gd"), \
					preload("res://addons/AIdot/Res/UI/AIResource.svg"))
	add_custom_type("OpenAIModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/OpenAI.gd"), \
					preload("res://addons/AIdot/Res/UI/AIResource.svg"))
	add_custom_type("QwenModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/Qwen.gd"), \
					preload("res://addons/AIdot/Res/UI/AIResource.svg"))
func model_layer_exit():
	remove_autoload_singleton("ModelLayer")
	
	remove_custom_type("AIAPI")
	remove_custom_type("LLMAPI")
	remove_custom_type("VLMAPI")
	# Model
	remove_custom_type("BaseModel")
	remove_custom_type("DeepSeekModel")
	remove_custom_type("OpenAIModel")
	remove_custom_type("QwenModel")



func _enter_tree() -> void:
	model_layer_enter()

func _exit_tree() -> void:
	model_layer_exit()
