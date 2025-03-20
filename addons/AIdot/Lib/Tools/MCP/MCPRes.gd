extends Resource
class_name MCPStdioServer

var venv_path : String:
	set(v):
		v.get_basename()

var server_path : String:
	set(c):
		var type : String = c.get_extension()
		match type:
			".py":
				command = "python"
				if venv_path:
					var python_path : String
					if OS.get_name() == "Windows":
						python_path = venv_path + "/Scripts/python.exe"
						pass
					elif OS.get_name() == "Linux" or OS.get_name() == "macOS":
						pass
				push_error("Python interpreter not found in virtual environment: {python_executable}")
			".js":
				command = "node"
				pass
			_:
				push_error("Server script must be a .py or .js file")
				return
		
		#env = os.environ.copy()
		#
		#if is_python:
			#if venv_path:
				#if sys.platform == 'win32':
					#python_executable = os.path.join(venv_path, 'Scripts', 'python.exe')
					#env['PATH'] = os.path.join(venv_path, 'Scripts') + os.pathsep + env['PATH']
				#else:
					#python_executable = os.path.join(venv_path, 'bin', 'python')
					#env['PATH'] = os.path.join(venv_path, 'bin') + os.pathsep + env['PATH']
				#if not os.path.exists(python_executable):
					#pass
				#command = python_executable
			#else:
				#command = "python"
		#else:
			#command = "node"
		#
		#pass

var command : String
var args : PackedStringArray
