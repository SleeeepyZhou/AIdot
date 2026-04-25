extends BaseTool
## Writes a new GDScript-based ToolModule into ToolModules/ and hot-registers it.
##
## Creates the module folder, writes the .gd script and modinf.json, then calls
## ToolBox.scan_modules() so the new tool is immediately available this session.
## To also define a skill for the new tool, create a SKILL.md in SkillModules/.

func _call(arguments: Dictionary = {}) -> Array:
	var module_name: String = arguments.get("module_name", "").strip_edges()
	var tool_name: String = arguments.get("tool_name", "").strip_edges()
	var description: String = arguments.get("description", "").strip_edges()
	var script_code: String = arguments.get("script_code", "").strip_edges()
	var input_schema_json: String = arguments.get("input_schema_json", "{}").strip_edges()

	if module_name.is_empty() or tool_name.is_empty() or script_code.is_empty():
		return [false, "module_name, tool_name, and script_code are required."]

	if module_name.contains("/") or module_name.contains("\\") or module_name.contains(".."):
		return [false, "module_name must be a plain folder name with no path separators."]

	var json := JSON.new()
	var parse_err := json.parse(input_schema_json)
	var input_schema: Dictionary = {}
	if parse_err == OK and json.get_data() is Dictionary:
		input_schema = json.get_data()
	else:
		return [false, "input_schema_json is not valid JSON: " + input_schema_json]

	var base_path := "res://addons/AIdot/ToolModules/" + module_name
	var script_filename := module_name + ".gd"

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_path))

	var gd_file := FileAccess.open(ProjectSettings.globalize_path(base_path + "/" + script_filename), FileAccess.WRITE)
	if !gd_file:
		return [false, "Failed to create script file at: " + base_path]
	gd_file.store_string(script_code)
	gd_file.close()

	var modinf: Dictionary = {
		"script": script_filename,
		"name": tool_name,
		"description": description,
		"input_schema": input_schema
	}
	var json_file := FileAccess.open(ProjectSettings.globalize_path(base_path + "/modinf.json"), FileAccess.WRITE)
	if !json_file:
		return [false, "Failed to create modinf.json at: " + base_path]
	json_file.store_string(JSON.stringify(modinf, "\t"))
	json_file.close()

	ToolBox.scan_modules()
	return [true, "Tool '%s' created at %s and registered to ToolBox." % [tool_name, base_path]]
