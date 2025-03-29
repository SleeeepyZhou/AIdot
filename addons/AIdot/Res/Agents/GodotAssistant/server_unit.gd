@tool
extends MarginContainer

@onready var server_path: LineEdit = $Box/PathBox/Path
@onready var venv_path: LineEdit = $Box/PathBox/Venv
@onready var env_input: CodeEdit = $Box/Env

@onready var status_show: LineEdit = $Box/ButtonBox/Status
@onready var tool_show: VBoxContainer = $Box/ToolShow/Box

@onready var mcp_client: MCPClient = $MCPClient
var mcp_server: MCPStdioServer

const TOOLS_UNIT = preload("res://addons/AIdot/Res/Agents/GodotAssistant/ToolsUnit.tscn")

signal server_change

func _ready() -> void:
	mcp_server = mcp_client.server

func _connected(is_connect: bool):
	if is_connect:
		status_show.text = "Connected"
		var list = mcp_client.get_list()
		for tool in list:
			var unit = TOOLS_UNIT.instantiate()
			unit.in_data = tool
			tool_show.add_child(unit)
	else:
		status_show.text = "Disconnected"

func _on_show_env_toggled(toggled_on: bool) -> void:
	env_input.visible = toggled_on


func _on_show_tools_toggled(toggled_on: bool) -> void:
	$Box/ToolShow.visible = toggled_on


func _on_connect_pressed() -> void:
	mcp_client.connection.connect(is_connected)
	server_path.editable = false
	venv_path.editable = false
	env_input.editable = false
	mcp_server.server_path = server_path.text
	mcp_server.venv_path = venv_path.text
	var env = JSON.parse_string(env_input.text)
	if env:
		mcp_server.env = JSON.parse_string(env_input.text)
	else:
		push_warning("Environment parse failed.")
	mcp_client.connect_to_server()
	server_change.emit()


func _on_disconnect_pressed() -> void:
	for child in tool_show.get_children():
		child.queue_free()
	mcp_client.stop()
	server_path.editable = true
	venv_path.editable = true
	env_input.editable = true
	server_change.emit()


func _on_delete_pressed() -> void:
	_on_disconnect_pressed()
	server_change.emit()
	queue_free()
