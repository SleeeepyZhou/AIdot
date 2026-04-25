@tool
extends Node
## Global tool and skill registry. Autoload singleton.
##
## Manages two plugin folder hierarchies (hot-scanned on startup and periodically):
## [br]• [code]ToolModules/[/code] — each subfolder contains a [code]modinf.json[/code]
##   and a [BaseTool] script. Loaded tools are registered to [member _tool_box].
## [br]• [code]SkillModules/[/code] — each subfolder contains a [code]skillinf.json[/code].
##   Loaded skills are registered to [member _skill_box].
##   A [code]modinf.json[/code] may also embed a [code]"skill"[/code] block to define
##   a skill alongside its tool.
##
## Agents use tools through [Skill] resources. Real-world interaction tools
## (MCP servers, HTTP endpoints, GodotServer) live here independently of any Agent.

# ── Module paths ──────────────────────────────────────────────────────────────

const TOOL_MODULES_PATH = "res://addons/AIdot/ToolModules"
const SKILL_MODULES_PATH = "res://addons/AIdot/SkillModules"

# ── MCP ───────────────────────────────────────────────────────────────────────

const _LATEST_PROTOCOL_VERSION = "2024-11-05"
const _MCP_VERSION = "0.1.0"
const SUPPORTED_PROTOCOL_VERSIONS = [1, _LATEST_PROTOCOL_VERSION]

var mcp_initialize: Dictionary = {
	"protocolVersion": _LATEST_PROTOCOL_VERSION,
	"capabilities": {
		"sampling": {},
		"roots": {"listChanged": true}
	},
	"clientInfo": {
		"name": "mcp",
		"version": _MCP_VERSION
	}
}

var _MCP_client: Dictionary[int, MCPClient] = {}

var _creating: bool = false
## Emitted when an MCP client connection attempt completes.
signal create_mcp(is_ok: bool)

func _connect_ok(is_ok: bool) -> void:
	if is_connected("connection", _connect_ok):
		disconnect("connection", _connect_ok)
	_creating = false
	create_mcp.emit(is_ok)

## Creates and connects an [MCPClient] for the given [param server].
## Emits [signal create_mcp] when done.
func create_mcp_from_server(server: MCPServer) -> void:
	if _creating:
		push_warning("ToolBox: Previous MCP connection still in progress.")
		return
	_creating = true
	var new_client := MCPClient.new()
	add_child(new_client)
	new_client.server = server
	new_client.connection.connect(_connect_ok)
	new_client.connect_to_server()

# ── Tool registry ─────────────────────────────────────────────────────────────

## Global tool registry: tool_name → BaseTool instance.
var _tool_box: Dictionary[String, BaseTool] = {}

## Returns all registered tool names.
func get_tool_names() -> PackedStringArray:
	return PackedStringArray(_tool_box.keys())

# ── Skill registry ────────────────────────────────────────────────────────────

## Global skill registry: skill_name → Skill instance.
var _skill_box: Dictionary[String, Skill] = {}

## Returns all registered skill names.
func get_skill_names() -> PackedStringArray:
	return PackedStringArray(_skill_box.keys())

## Returns the [Skill] for [param skill_name], or [code]null[/code] if not found.
func get_skill(skill_name: String) -> Skill:
	return _skill_box.get(skill_name)

## Emitted whenever new tools or skills are loaded by [method scan_modules].
signal tools_updated

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	scan_modules()
	var timer := Timer.new()
	timer.wait_time = 10.0
	timer.autostart = true
	timer.timeout.connect(scan_modules)
	add_child(timer)

# ── Module scanning ───────────────────────────────────────────────────────────

## Scans [code]ToolModules/[/code] and [code]SkillModules/[/code] for new plugins.
## Safe to call repeatedly; already-loaded names are skipped unless overwritten.
func scan_modules() -> void:
	var changed := false
	changed = _scan_tool_modules(TOOL_MODULES_PATH) or changed
	changed = _scan_skill_modules(SKILL_MODULES_PATH) or changed
	if changed:
		tools_updated.emit()

func _scan_tool_modules(dir_path: String) -> bool:
	var dir := DirAccess.open(dir_path)
	if !dir:
		return false
	var changed := false
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and !entry.begins_with("."):
			if _load_tool_module(dir_path + "/" + entry):
				changed = true
		entry = dir.get_next()
	return changed

func _load_tool_module(module_path: String) -> bool:
	var inf_path := module_path + "/modinf.json"
	if !FileAccess.file_exists(inf_path):
		return false
	var json_tool := JsonTool.new()
	var info: Dictionary = json_tool.read_json(inf_path)
	if info.is_empty():
		return false

	var tool_name: String = info.get("name", "")
	if tool_name.is_empty():
		push_warning("ToolBox: modinf.json in '%s' missing 'name' field." % module_path)
		return false

	# Skip if already registered (hot-reload only adds, doesn't overwrite live tools)
	if _tool_box.has(tool_name):
		# Check skill block for new skill entry
		return _maybe_load_skill_from_modinf(info, tool_name)

	var script_file: String = info.get("script", "")
	if script_file.is_empty():
		push_warning("ToolBox: modinf.json in '%s' missing 'script' field." % module_path)
		return false

	var script_path := module_path + "/" + script_file
	if !FileAccess.file_exists(script_path):
		push_warning("ToolBox: Script '%s' not found." % script_path)
		return false

	var loaded = load(script_path)
	if !loaded:
		push_warning("ToolBox: Failed to load '%s'." % script_path)
		return false

	var instance = loaded.new()
	if !(instance is BaseTool):
		push_warning("ToolBox: '%s' does not extend BaseTool." % script_path)
		return false

	instance._tool_name = tool_name
	instance._description = info.get("description", "")
	instance._input_schema = info.get("input_schema", {})
	_tool_box[tool_name] = instance

	# Auto-create a Skill from the embedded "skill" block, if present
	_maybe_load_skill_from_modinf(info, tool_name)
	return true

func _maybe_load_skill_from_modinf(info: Dictionary, tool_name: String) -> bool:
	var skill_block: Dictionary = info.get("skill", {})
	if skill_block.is_empty():
		return false
	var sname: String = skill_block.get("skill_name", tool_name)
	if _skill_box.has(sname):
		return false
	var skill := Skill.new()
	skill.skill_name = sname
	skill.description = skill_block.get("description", info.get("description", ""))
	skill.instructions = skill_block.get("instructions", "")
	skill.tool_names = PackedStringArray([tool_name])
	_skill_box[sname] = skill
	return true

func _scan_skill_modules(dir_path: String) -> bool:
	var dir := DirAccess.open(dir_path)
	if !dir:
		return false
	var changed := false
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and !entry.begins_with("."):
			if _load_skill_module(dir_path + "/" + entry):
				changed = true
		entry = dir.get_next()
	return changed

func _load_skill_module(module_path: String) -> bool:
	var skill_path := module_path + "/SKILL.md"
	if !FileAccess.file_exists(skill_path):
		return false

	var info := _parse_skill_md(skill_path)
	if info.is_empty():
		return false

	var sname: String = info.get("name", "")
	if sname.is_empty():
		push_warning("ToolBox: SKILL.md in '%s' missing 'name' field." % module_path)
		return false
	if _skill_box.has(sname):
		return false

	var skill := Skill.new()
	skill.skill_name = sname
	skill.description = info.get("description", "")
	skill.instructions = info.get("instructions", "")
	var raw_names: String = info.get("tool_names", "")
	if !raw_names.is_empty():
		skill.tool_names = PackedStringArray(
			raw_names.split(",", false).map(func(s): return s.strip_edges()))
	_skill_box[sname] = skill
	return true

## Parses a SKILL.md file. Returns a Dictionary with frontmatter keys plus
## [code]"instructions"[/code] containing the markdown body.
## Frontmatter is a YAML subset: simple [code]key: value[/code] lines between
## the opening and closing [code]---[/code] delimiters.
func _parse_skill_md(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if !file:
		return {}
	var content := file.get_as_text()
	file.close()

	# Must start with ---
	if !content.begins_with("---"):
		return {}
	var close := content.find("\n---", 3)
	if close == -1:
		return {}

	var frontmatter := content.substr(3, close - 3).strip_edges()
	var body := content.substr(close + 4).strip_edges()

	var result: Dictionary = {}
	for line in frontmatter.split("\n"):
		var colon := line.find(":")
		if colon == -1:
			continue
		var key := line.substr(0, colon).strip_edges()
		var val := line.substr(colon + 1).strip_edges()
		if !key.is_empty():
			result[key] = val
	result["instructions"] = body
	return result
