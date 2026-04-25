@tool
extends EditorPlugin

## Model Layer
func model_layer_enter():
	add_autoload_singleton("ModelLayer", "res://addons/AIdot/Autolodes/ModelLayer.gd")
	# Model
	add_custom_type("BaseModel", "Resource", preload("res://addons/AIdot/Lib/Model/BaseModel.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/Model.svg"))
	add_custom_type("DeepSeekModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/DeepSeek.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/deepseek.png"))
	add_custom_type("OpenAIModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/OpenAI.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/openai.png"))
	add_custom_type("QwenModel", "Resource", preload("res://addons/AIdot/Lib/Model/API_Adapter/Qwen.gd"), \
					preload("res://addons/AIdot/Res/UI/Model/qwen.png"))
	# API
	add_custom_type("AIAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/API.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/API.png"))
	add_custom_type("LLMAPI", "HTTPRequest", preload("res://addons/AIdot/Lib/Model/API/LLM.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/API_node.png"))
func model_layer_exit():
	remove_autoload_singleton("ModelLayer")
	# API
	remove_custom_type("AIAPI")
	remove_custom_type("LLMAPI")
	# Model
	remove_custom_type("BaseModel")
	remove_custom_type("DeepSeekModel")
	remove_custom_type("OpenAIModel")
	remove_custom_type("QwenModel")

## Memory
func memory_enter():
	add_custom_type("AIMemory", "Resource", preload("res://addons/AIdot/Lib/Agent/Abilities/Memory/Memory.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Agent.svg"))
	
	add_custom_type("MemoryBlock", "Resource", preload("res://addons/AIdot/Lib/Agent/Abilities/Memory/MemoryBlock.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Agent.svg"))
	add_custom_type("AgentMemory", "Resource", preload("res://addons/AIdot/Lib/Agent/Abilities/Memory/AgentMemory.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Agent.svg"))
	add_custom_type("LongMemory", "Resource", preload("res://addons/AIdot/Lib/Agent/Abilities/Memory/LongMemory.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Agent.svg"))
func memory_exit():
	remove_custom_type("AIMemory")
	
	remove_custom_type("MemoryBlock")
	remove_custom_type("AgentMemory")
	remove_custom_type("LongMemory")

## Tools
func tool_box_enter():
	add_autoload_singleton("ToolBox", "res://addons/AIdot/Autolodes/ToolBox.gd")
	# tool
	add_custom_type("BaseTool", "Resource", preload("res://addons/AIdot/Lib/Tools/ToolMeta.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	# MCP
	add_custom_type("MCPClient", "Node", preload("res://addons/AIdot/Lib/Tools/MCP/MCPClient.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp_node.png"))
	add_custom_type("MCPServer", "Resource", preload("res://addons/AIdot/Lib/Tools/MCP/MCPServer.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	add_custom_type("StdioServer", "Resource", preload("res://addons/AIdot/Lib/Tools/MCP/StdioServer.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	add_custom_type("HTTPServer", "Resource", preload("res://addons/AIdot/Lib/Tools/MCP/HTTPServer.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
	add_custom_type("GodotServer", "Resource", preload("res://addons/AIdot/Lib/Tools/MCP/GodotServer.gd"),\
					preload("res://addons/AIdot/Res/UI/Icon/mcp.png"))
func tool_box_exit():
	remove_autoload_singleton("ToolBox")
	# tool
	remove_custom_type("BaseTool")
	# MCP
	remove_custom_type("MCPClient")
	remove_custom_type("MCPServer")
	remove_custom_type("StdioServer")
	remove_custom_type("HTTPServer")
	remove_custom_type("GodotServer")

## Agent
func agent_enter():
	## Abilities
	# Memory
	memory_enter()
	# Tools
	tool_box_enter()
	# Action (Skill + SkillBook have class_name so Godot auto-registers them;
	#         add_custom_type here gives them editor icons)
	add_custom_type("Skill", "Resource", \
					preload("res://addons/AIdot/Lib/Agent/Abilities/Action/Skill.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Tool.png"))
	add_custom_type("SkillBook", "Resource", \
					preload("res://addons/AIdot/Lib/Agent/Abilities/Action/SkillBook.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Tool.png"))

	add_autoload_singleton("AgentCoordinator", "res://addons/AIdot/Autolodes/AgentCoordinator.gd")
	add_custom_type("BaseAgent", "Node", preload("res://addons/AIdot/Lib/Agent/Core/BaseAgent.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Agent.svg"))
	add_custom_type("ChatAgent", "Node", preload("res://addons/AIdot/Lib/Agent/Core/ChatAgent.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Agent.svg"))
	add_custom_type("UserAgent", "Node", preload("res://addons/AIdot/Lib/Agent/Core/UserAgent.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/Agent.svg"))
func agent_exit():
	## Abilities
	# Memory
	memory_exit()
	# Tools
	tool_box_exit()
	# Action
	remove_custom_type("Skill")
	remove_custom_type("SkillBook")

	remove_autoload_singleton("AgentCoordinator")
	remove_custom_type("BaseAgent")
	remove_custom_type("ChatAgent")
	remove_custom_type("UserAgent")

## Maodot Chat
var GODOT_ASSISTANT : Control
func maochat_client():
	GODOT_ASSISTANT = preload("res://addons/AIdot/Res/Agents/GodotAssistant/MaoChat.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL,GODOT_ASSISTANT)
func maochat_exit():
	remove_control_from_bottom_panel(GODOT_ASSISTANT)
	GODOT_ASSISTANT.queue_free()

func _enter_tree() -> void:
	add_custom_type("AIdotResource", "Resource", preload("res://addons/AIdot/Res/Data/AIResource.gd"), \
					preload("res://addons/AIdot/Res/UI/Icon/icon.png"))
	
	model_layer_enter()
	agent_enter()
	maochat_client()

func _exit_tree() -> void:
	remove_custom_type("AIdotResource")
	
	maochat_exit()
	agent_exit()
	model_layer_exit()
