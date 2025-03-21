extends Resource
class_name MCPStdioServer

@export var venv_path : String = "":
	set(v):
		venv_path = v.trim_suffix("/")
		set_py_venv()

@export var server_path : String = "":
	set(c):
		var type : String = c.get_extension()
		match type:
			".py":
				command = "python"
				if venv_path:
					set_py_venv()
			".js":
				command = "node"
			_:
				push_error("Server script must be a .py or .js file")

var command : String
@export var args : PackedStringArray

func set_py_venv():
	if server_path.is_empty() or server_path.get_extension() != ".py":
		return
	var python_path : String
	if OS.get_name() == "Windows":
		python_path = venv_path + "/Scripts/python.exe"
		
		#env['PATH'] = os.path.join(venv_path, 'Scripts') + os.pathsep + env['PATH']
	elif OS.get_name() == "Linux" or OS.get_name() == "macOS":
		python_path = venv_path + "/bin/python"
		#env['PATH'] = os.path.join(venv_path, 'bin') + os.pathsep + env['PATH']
	if !FileAccess.file_exists(python_path):
		push_error("Python interpreter not found in virtual environment: " + python_path)
	else:
		command = python_path.simplify_path()
