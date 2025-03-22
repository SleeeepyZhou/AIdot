@tool
extends Node
class_name MCPClient

# Config
@export var server : MCPStdioServer = MCPStdioServer.new()
@export var auto_connect : bool = false
@export var auto_reconnect : bool = false
@export_tool_button("Connect server") var _connect = connect_to_server

signal connection(is_connect: bool)
signal message_received(message: Dictionary)
signal log_record(log: String)


var _rpc : JSONRPC = JSONRPC.new()

var _running := false
var _pid: int
var _stdio: FileAccess
var _stderr: FileAccess

var _read_buffer := ""
var _stderr_buffer := ""

func _ready() -> void:
	if auto_connect:
		connect_to_server()

# Run server
func connect_to_server() -> bool:
	var server_run : String = server._command
	var arguments : PackedStringArray = server.args
	assert(server_run,"MCP server script has not been set up yet.")
	if !server.env.is_empty():
		for key in server.env.keys():
			OS.set_environment(key,server.env[key])
	var result := OS.execute_with_pipe(server_run, arguments, false)
	if result.is_empty():
		push_error("Failed to start MCP server")
		connection.emit(false)
		return false
	#assert(!result.is_empty(), "Failed to start MCP server")
	
	_stdio = result["stdio"]
	_stderr = result["stderr"]
	_pid = result["pid"]
	_running = true
	connection.emit(true)
	return true

# Close
func stop() -> void:
	if _running:
		_running = false
		if _stdio:
			_stdio.close()
		if _stderr:
			_stderr.close()
		if OS.is_process_running(_pid):
			OS.kill(_pid)
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		stop()

# Process IO
func _process(delta: float) -> void:
	if !_running:
		return
	
	_process_stdio()
	_process_stderr()
	
	if !OS.is_process_running(_pid):
		stop()
		connection.emit(false)
		if auto_reconnect:
			connect_to_server()

# Send JSON-RPC
func send_message(message: Dictionary) -> bool:
	if !_running or !_stdio:
		return false
	
	var json_str := JSON.stringify(message)
	if json_str.contains("\n"):
		push_error("Message contains invalid newline character")
		return false
	_stdio.store_line(json_str)
	return _stdio.get_error() == OK

# func _process(_delta: float) -> void:
# 	var _read_buffer : String = ""
# 	while true:
# 		var chunk := _stdio.get_as_text()
# 		if chunk.is_empty():
# 			break
# 		_read_buffer += chunk
# 		print(_read_buffer)
# print("123123")

# 处理标准输出数据
func _process_stdio() -> void:
	while true:
		var chunk := _stdio.get_as_text()
		if chunk.is_empty():
			break
		_read_buffer += chunk
	
	while "\n" in _read_buffer:
		var newline_pos := _read_buffer.find("\n")
		var message_str := _read_buffer.substr(0, newline_pos)
		_read_buffer = _read_buffer.substr(newline_pos + 1)
		
		var json := JSON.new()
		var error := json.parse(message_str)
		if error == OK:
			emit_signal("message_received", json.data)
		else:
			push_error("Failed to parse message: ", message_str)

# 处理标准错误日志
func _process_stderr() -> void:
	if not _stderr:
		return
	
	while true:
		var chunk := _stderr.get_as_text()
		if chunk.is_empty():
			break
		_stderr_buffer += chunk
	
	while "\n" in _stderr_buffer:
		var newline_pos := _stderr_buffer.find("\n")
		var log_line := _stderr_buffer.substr(0, newline_pos)
		_stderr_buffer = _stderr_buffer.substr(newline_pos + 1)
		emit_signal("log_received", log_line)
