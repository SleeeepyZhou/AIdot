@tool
extends Node
class_name MCPClient

# Config
@export var server : MCPStdioServer = MCPStdioServer.new()
@export var auto_connect : bool = false
@export var auto_reconnect : bool = false
@export var max_reconnect_attempts : int = 3
var _retry : int = 0
@export_tool_button("Connect server") var _connect = connect_to_server
@export_tool_button("Close server") var _close = stop

signal connection(is_connect: bool)
signal message_received(message: Dictionary)
signal log_record(log: String)

var _rpc : JSONRPC = JSONRPC.new()

var _running := false
var _pid: int
var _stdio: FileAccess
var _stderr: FileAccess

var _request_counter : int = 0
var _stdout_buffer := ""
var _stderr_buffer := ""

func _ready() -> void:
	if auto_connect:
		connect_to_server()

# Send JSON-RPC
func _send_message(message: Dictionary) -> bool:
	if !_running or !_stdio:
		return false
	
	var json_str := JSON.stringify(message)
	#if json_str.contains("\n"):
		#push_error("Message contains invalid newline character")
		#return false
	_stdio.store_line(json_str)
	_request_counter += 1
	return _stdio.get_error() == OK
# Reconnect
func _reconnect(err_str : String):
	connection.emit(false)
	push_error(err_str + " Wait 1s retry.")
	if auto_reconnect and _retry < max_reconnect_attempts:
		_retry += 1
		await get_tree().create_timer(1.0).timeout
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
		_reconnect("Failed to start MCP server.")
		return false
	#assert(!result.is_empty(), "Failed to start MCP server")
	
	_stdio = result["stdio"]
	_stderr = result["stderr"]
	_pid = result["pid"]
	_retry = 0
	_running = true
	print("MCP server connect on pid: ", _pid)
	#_send_message(_rpc.make_request("initialize", {}, _request_counter))
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
		print("MCP server closed on pid: ", _pid)
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		stop()

# Process IO
func _process(delta: float) -> void:
	if !_running:
		return
	
	_process_stdout()
	_process_stderr()
	
	if !OS.is_process_running(_pid):
		stop()
		_reconnect("Connect closed.")

# Std Out
func _process_stdout() -> void:
	if !_stdio:
		return
	var chunk := _stdio.get_as_text()
	while chunk != "":
		_stdout_buffer += chunk
		chunk = _stdio.get_as_text()
	
	var newline_pos := _stdout_buffer.find("\n")
	
	if !_stdout_buffer.is_empty():
		print("New out: ", _stdout_buffer)
	
	while newline_pos != -1:
		var message_str := _stdout_buffer.substr(0, newline_pos)
		_stdout_buffer = _stdout_buffer.substr(newline_pos + 1)
		
		var message = JSON.parse_string(message_str)
		if message:
			message_received.emit(message)
			print(message)
		else:
			push_error("Failed to parse message: ", message_str)
		
		newline_pos = _stdout_buffer.find("\n")

# Std Err
func _process_stderr() -> void:
	if !_stderr:
		return
	
	var chunk := _stderr.get_as_text()
	while chunk != "":
		_stderr_buffer += chunk
		chunk = _stderr.get_as_text()
	
	if !_stderr_buffer.is_empty():
		print("New err: ", _stdout_buffer)
	
	var newline_pos := _stderr_buffer.find("\n")
	while newline_pos != -1:
		var log_line := _stderr_buffer.substr(0, newline_pos)
		_stderr_buffer = _stderr_buffer.substr(newline_pos + 1)
		log_record.emit(log_line)
		newline_pos = _stderr_buffer.find("\n")


@export_tool_button("Test") var _test = test
func test():
	print(123)
	_send_message(_rpc.make_request("initialize", {}, _request_counter))
	
	
