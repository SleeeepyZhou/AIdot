@tool
@icon("res://addons/AIdot/Res/UI/Icon/Tool.png")
extends AIdotResource
class_name SkillBook
## The agent's action capability bag.
##
## Aggregates multiple [Skill] resources and provides a unified interface for:
## [br]• Querying LLM-ready tool schemas ([method get_chat_tools])
## [br]• Injecting skill instructions into system context ([method get_system_injection])
## [br]• Dispatching tool calls across all owned skills ([method use_tool])
##
## Assign to [member ChatAgent.skill_book]. On [code]_ready()[/code] the agent calls
## [method register_tools] to push all direct [BaseTool] instances to [ToolBox].

## Skills owned by this bag. Each [Skill] bundles usage instructions with tools.
@export var skills: Array[Skill] = []

# ── LLM interface ─────────────────────────────────────────────────────────────

## Returns aggregated OpenAI-format tool schemas for all skills.
## Deduplicates tools appearing in multiple skills.
func get_chat_tools() -> Array:
	var schemas: Array = []
	var seen: Dictionary = {}
	for skill: Skill in skills:
		for s in skill.get_schemas():
			var n: String = s.get("function", {}).get("name", "")
			if n and !seen.has(n):
				seen[n] = true
				schemas.append(s)
	return schemas

## Returns aggregated skill instruction blocks to inject into system context.
## Each skill contributes one block; blocks are separated by blank lines.
func get_system_injection() -> String:
	var parts := PackedStringArray()
	for skill: Skill in skills:
		var inj := skill.get_system_injection()
		if !inj.is_empty():
			parts.append(inj)
	return "\n\n".join(parts)

# ── Tool lookup ───────────────────────────────────────────────────────────────

## Finds and returns the [BaseTool] for [param tool_name] across all skills.
## Returns [code]null[/code] if not found.
func find_tool(tool_name: String) -> BaseTool:
	for skill: Skill in skills:
		var tool := skill.find_tool(tool_name)
		if tool:
			return tool
	return null

## Executes [param tool_name] with [param input] and awaits the result.
## Returns empty Array if the tool is not found in any skill.
func use_tool(tool_name: String, input: Dictionary = {}) -> Array:
	var tool := find_tool(tool_name)
	if !tool:
		push_error("SkillBook: Tool '%s' not found in any skill." % tool_name)
		return []
	return await tool.use_tool(input)

# ── ToolBox registration ──────────────────────────────────────────────────────

## Registers all direct [BaseTool] instances from every skill to [ToolBox].
## Call this from the owning agent's [code]_ready()[/code].
func register_tools() -> void:
	for skill: Skill in skills:
		for tool: BaseTool in skill.tools:
			if !tool._tool_name.is_empty():
				ToolBox._tool_box[tool._tool_name] = tool

## Unregisters all direct [BaseTool] instances from [ToolBox].
## Call this before swapping out a [SkillBook] at runtime.
func unregister_tools() -> void:
	for skill: Skill in skills:
		for tool: BaseTool in skill.tools:
			if ToolBox._tool_box.get(tool._tool_name) == tool:
				ToolBox._tool_box.erase(tool._tool_name)
