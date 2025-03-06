@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("MatrixLib","res://addons/matrix_calc/Lib.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("MatrixLib")
