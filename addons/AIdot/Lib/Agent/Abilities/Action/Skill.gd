@tool
@icon("res://addons/AIdot/Res/UI/Icon/Tool.png")
extends AIdotResource
class_name Skill
## A named capability unit: usage instructions bound to a set of tools.
##
## Skill belongs to the [b]Action[/b] ability layer. It wraps one or more tools
## with LLM-facing instructions, telling the agent when and how to use them.
##
## Inspired by Claude Code skills (github.com/anthropics/skills):
## each Skill is a named instruction block that grants the agent a focused capability.
## Tools are the mechanism; the Skill is the intent.
##
## Skills can be defined in two ways:
## [br]• [b]SkillModules/[/b] — drop a [code]skillinf.json[/code] into a subfolder;
##   [ToolBox] hot-loads it on startup and when new folders are detected.
## [br]• [b]Inline resource[/b] — create a [code].tres[/code] and assign to a [SkillBook].

## Unique name shown to the LLM as a capability header.
@export var skill_name: String = ""
## When/how to use this skill. Helps the LLM decide when to invoke its tools.
@export_multiline var description: String = ""
## Injected into system context while this skill is active.
## Describe tool usage patterns, expected inputs/outputs, and constraints.
@export_multiline var instructions: String = ""
## Names of tools already in [ToolBox] that this skill uses
## (populated after MCP connection, or set from [code]skillinf.json[/code]).
@export var tool_names: PackedStringArray = []
## Direct [BaseTool] instances provided by this skill.
## [SkillBook] registers these to [ToolBox] on agent [code]_ready()[/code].
@export var tools: Array[BaseTool] = []
## Optional MCP server. Connect via [ToolBox.create_mcp_from_server] after ready;
## then add the server's tool names to [member tool_names].
@export var mcp_server: MCPServer = null

# ── Instructions ─────────────────────────────────────────────────────────────

## Returns the system context block to inject for this skill.
## Returns empty string if both [member skill_name] and [member instructions] are unset.
func get_system_injection() -> String:
	if skill_name.is_empty() and instructions.is_empty():
		return ""
	var parts := PackedStringArray()
	if !skill_name.is_empty():
		var header := "[Skill: %s]" % skill_name
		if !description.is_empty():
			header += " — " + description
		parts.append(header)
	if !instructions.is_empty():
		parts.append(instructions)
	return "\n".join(parts)

# ── Tool schemas ──────────────────────────────────────────────────────────────

## Returns aggregated OpenAI-format tool schemas for this skill.
## Deduplicates tools that appear in both [member tools] and [member tool_names].
func get_schemas() -> Array:
	var schemas: Array = []
	var seen: Dictionary = {}
	for tool: BaseTool in tools:
		if tool._tool_name.is_empty() or seen.has(tool._tool_name):
			continue
		seen[tool._tool_name] = true
		schemas.append(_make_schema(tool))
	for name: String in tool_names:
		if seen.has(name):
			continue
		if ToolBox._tool_box.has(name):
			seen[name] = true
			schemas.append(_make_schema(ToolBox._tool_box[name]))
		else:
			push_warning("Skill '%s': tool '%s' not in ToolBox." % [skill_name, name])
	return schemas

# ── Tool execution ────────────────────────────────────────────────────────────

## Finds the [BaseTool] for [param tool_name] within this skill. Returns [code]null[/code] if not found.
func find_tool(tool_name: String) -> BaseTool:
	for tool: BaseTool in tools:
		if tool._tool_name == tool_name:
			return tool
	if tool_names.has(tool_name):
		if ToolBox._tool_box.has(tool_name):
			return ToolBox._tool_box[tool_name]
	return null

## Executes [param tool_name] and awaits the result. Returns empty Array if not found.
func use_tool(tool_name: String, input: Dictionary = {}) -> Array:
	var tool := find_tool(tool_name)
	if !tool:
		return []
	return await tool.use_tool(input)

# ── Internal ──────────────────────────────────────────────────────────────────

func _make_schema(tool: BaseTool) -> Dictionary:
	return {
		"type": "function",
		"function": {
			"name": tool._tool_name,
			"description": tool._description,
			"parameters": tool._input_schema
		},
		"strict": true
	}
