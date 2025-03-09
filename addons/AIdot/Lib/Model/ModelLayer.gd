extends Node

func _get_env_example(mod_type : String) -> Array:
	const EXAMPLE_PATH = "res://addons/AIdot/Lib/Model/ENV_example.json"
	var env_path = "user://.env"
	var json_tool = preload("res://addons/AIdot/Utils/Json.gd").new()
	var file = FileAccess.open(env_path, FileAccess.READ)
	if !file:
		var dir := DirAccess.open("user://")
		if dir.copy(EXAMPLE_PATH, env_path) != OK:
			push_error("Unable to create 'res://.env' file, please copy the ENV_example.")
	var env_data = json_tool.read_json(env_path)
	return [env_data["url"].get(mod_type,""),env_data["key"].get(mod_type,"")] # url, key

## This is an example method that can directly override and modify the API key reading behavior 
## after exporting application.
func get_user_env(mod_type : String) -> Array:
	var env_set = _get_env_example(mod_type)
	return env_set # url, key
