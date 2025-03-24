@tool
extends EditorPlugin

## Model Layer
func model_layer_enter():
	add_autoload_singleton("ModelLayer", "res://addons/AIdot/Autolodes/ModelLayer.gd")
	# API
	add_custom_type("AIAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/API.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/API.png"))
	add_custom_type("LLMAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/LLM.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/API_node.png"))
	add_custom_type("VLMAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/VLM.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/API_node.png"))
	# Model
	add_custom_type("BaseModel", "Resource", preload("res://addons/AIdot/Lib/Model/BaseModel.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/Model.svg"))
	add_custom_type("DeepSeekModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/DeepSeek.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/deepseek.png"))
	add_custom_type("OpenAIModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/OpenAI.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/openai.png"))
	add_custom_type("QwenModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/Qwen.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/qwen.png"))
func model_layer_exit():
	remove_autoload_singleton("ModelLayer")
	# API
	remove_custom_type("AIAPI")
	remove_custom_type("LLMAPI")
	remove_custom_type("VLMAPI")
	# Model
	remove_custom_type("BaseModel")
	remove_custom_type("DeepSeekModel")
	remove_custom_type("OpenAIModel")
	remove_custom_type("QwenModel")

## Tools
func tool_box_enter():
	add_autoload_singleton("ToolBox", "res://addons/AIdot/Autolodes/ToolBox.gd")
	# tool
	add_custom_type("BaseTool", "Resource", preload("res://addons/AIdot/Lib/Tools/ToolMeta.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	add_custom_type("MCPTool", "Resource", preload("res://addons/AIdot/Lib/Tools/MCPTool.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	add_custom_type("GodotTool", "Resource", preload("res://addons/AIdot/Lib/Tools/GodotTool.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/icon.png"))
	# MCP
	add_custom_type("MCPClient", "Node", preload("res://addons/AIdot/Lib/Tools/MCP/MCPClient.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp_node.png"))
	add_custom_type("MCPServer", "Resource", preload("res://addons/AIdot/Lib/Tools/MCP/MCPServer.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	add_custom_type("MCPStdioServer", "Resource", preload("res://addons/AIdot/Lib/Tools/MCP/MCPStdioServer.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	# agent tool
	add_custom_type("ToolBag", "Resource", preload("res://addons/AIdot/Lib/Agent/Abilities/Action/ToolBag.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/Tool.png"))
func tool_box_exit():
	remove_autoload_singleton("ToolBox")
	# tool
	remove_custom_type("BaseTool")
	remove_custom_type("MCPTool")
	remove_custom_type("GodotTool")
	# MCP
	remove_custom_type("MCPClient")
	remove_custom_type("MCPServer")
	remove_custom_type("MCPStdioServer")
	# agent tool
	remove_custom_type("ToolBag")

## Maodot Chat
var GODOT_ASSISTANT : Control
func maochat_client():
	GODOT_ASSISTANT = preload("res://addons/AIdot/Res/Agents/GodotAssistant/GodotAssistant.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL,GODOT_ASSISTANT)
func maochat_exit():
	remove_control_from_bottom_panel(GODOT_ASSISTANT)
	GODOT_ASSISTANT.queue_free()

func _enter_tree() -> void:
	add_custom_type("AIdotResource", "Resource", preload("res://addons/AIdot/Lib/AIResource.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/icon.png"))
	
	model_layer_enter()
	tool_box_enter()
	maochat_client()

func _exit_tree() -> void:
	remove_custom_type("AIdotResource")
	
	model_layer_exit()
	tool_box_exit()
	maochat_exit()
