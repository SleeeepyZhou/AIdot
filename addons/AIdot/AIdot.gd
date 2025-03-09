@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("ModelLayer", "res://addons/AIdot/Lib/Model/ModelLayer.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("ModelLayer")
	
