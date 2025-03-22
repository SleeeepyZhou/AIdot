extends MCPServer
class_name MCPStdioServer

@export_global_file var server_path : String = "":
	set(c):
		var type : String = c.get_extension()
		match type:
			".py":
				server_path = c
				_command = "python"
				if venv_path:
					_set_py_venv()
			".js":
				server_path = c
				_command = "node"
			_:
				push_error("Server script must be a .py or .js file")
				return
		var temp : PackedStringArray = [server_path]
		temp.append_array(args)
		args = temp

@export_global_dir var venv_path : String = "":
	set(v):
		venv_path = v.trim_suffix("/")
		_set_py_venv()

var _command : String
@export var args : PackedStringArray

@export var env : Dictionary = {}

func _set_py_venv():
	if server_path.is_empty() or server_path.get_extension() != ".py":
		return
	var python_path : String
	if OS.get_name() == "Windows":
		python_path = venv_path + "/Scripts/python.exe"
		env["PATH"]  = venv_path + "/Scripts;" + OS.get_environment("PATH")
	elif OS.get_name() == "Linux" or OS.get_name() == "macOS":
		python_path = venv_path + "/bin/python"
		env["PATH"]  = venv_path + "/bin:" + OS.get_environment("PATH")
	if !FileAccess.file_exists(python_path):
		push_error("Python interpreter not found in virtual environment: " + python_path)
	else:
		_command = python_path.simplify_path()
