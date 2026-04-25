@tool
extends Node
class_name Planner
## Planning advisor component for ChatAgent.
##
## Attach as a child node of a [ChatAgent] to enable LLM-powered planning.
## Before each LLM call the agent will consult the Planner, which generates
## a concise action plan injected as a system-level context message.
##
## The Planner uses the parent agent's model by default ([member use_agent_model]),
## or an independently configured [member model].

signal plan_ready(plan: String, request_id: int)

## System prompt that shapes the planner's output style.
@export_multiline var planning_prompt: String = \
	"You are an internal planning assistant for an AI agent. " \
	+ "Given the conversation history and the user's latest request, " \
	+ "output a concise step-by-step action plan (bullet points). " \
	+ "Be brief and specific. Do NOT respond to the user directly."

## When true the Planner shares the parent ChatAgent's model.
## When false it uses [member model] independently.
@export var use_agent_model: bool = true

## Independent model (only used when [member use_agent_model] is false).
@export var model: BaseModel = null:
	set(m):
		model = m
		if !use_agent_model and _api:
			_api.model = model

var _api: LLMAPI = null

func _ready() -> void:
	if !use_agent_model and model:
		_setup_api(model)


## Called by [ChatAgent] when its model changes.
## Configures this planner's LLMAPI to use the same model.
func setup(agent_model: BaseModel) -> void:
	if use_agent_model:
		_setup_api(agent_model)


func _setup_api(m: BaseModel) -> void:
	if _api:
		_api.queue_free()
	_api = LLMAPI.new(m)
	add_child(_api)


## Generate a planning suggestion given conversation [param context] and the
## current [param goal] (the user's latest message).
## Returns the plan as a String. Must be used with [code]await[/code].
func plan(context: Array, goal: String = "") -> String:
	if !_api or !_api.model:
		push_error("Planner: No model configured. Set use_agent_model=true or assign a model.")
		return ""

	# Build a minimal history: system planning prompt + conversation context
	var history: Array = [AgentMemory.template_memory(planning_prompt, "system")]
	history.append_array(context)

	var prompt: String = goal if !goal.is_empty() \
		else "Summarise what the agent should do next."

	var result: Array = await _api.run_api(prompt, history, "user")
	var plan_text: String = result[0]
	plan_ready.emit(plan_text, result[2])
	return plan_text
