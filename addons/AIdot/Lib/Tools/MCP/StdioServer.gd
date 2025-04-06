@tool
extends MCPServer
class_name StdioServer

func _set_server_path(path: String):
	if path.is_empty():
		server_path = path
		return
	var type : String = path.get_extension()
	match type:
		"py":
			server_path = path.simplify_path()
			_command = "python"
			if venv_path:
				_set_py_venv()
		"js":
			server_path = path.simplify_path()
			_command = "node"
		_:
			push_error("Server script must be a .py or .js file")
			return

@export_global_dir var venv_path : String = "":
	set(v):
		if v.is_empty():
			env.erase("PATH")
			venv_path = v
			return
		venv_path = v.trim_suffix("/")
		_set_py_venv()

var _command : String
@export var args : PackedStringArray

@export var env : Dictionary = {}

func _set_py_venv():
	if server_path.is_empty() or server_path.get_extension() != "py":
		return
	var python_path : String
	if OS.get_name() == "Windows":
		python_path = (venv_path + "/Scripts/python.exe").simplify_path()
		env["PATH"]  = (venv_path + "/Scripts").simplify_path() + ";" + OS.get_environment("PATH")
	elif OS.get_name() == "Linux" or OS.get_name() == "macOS":
		python_path = (venv_path + "/bin/python").simplify_path()
		env["PATH"]  = (venv_path + "/bin").simplify_path() + ":" + OS.get_environment("PATH")
	if !FileAccess.file_exists(python_path):
		push_error("Python interpreter not found in virtual environment: " + python_path)
	else:
		_command = python_path.simplify_path()
