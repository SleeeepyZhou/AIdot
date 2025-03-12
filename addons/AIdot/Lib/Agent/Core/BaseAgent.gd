@tool
extends Node
class_name BaseAgent

@export var agent_name : String = ""

@export_enum("user","assistant","tool") var role : String = "assistant"
