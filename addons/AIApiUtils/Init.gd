@tool
extends EditorPlugin

var api_config = preload("res://addons/AIApiUtils/Res/config.tscn").instantiate()

func _enter_tree():
	add_autoload_singleton("API", "res://addons/AIApiUtils/Api.gd")
	add_control_to_bottom_panel(api_config, "VLMAPIConfig")
	#add_custom_type("AIApi", "Node", preload("res://addons/AIApiUtils/ApiUtils.gd"), \
					#preload("res://addons/AIApiUtils/key1.png"))

func _exit_tree():
	remove_autoload_singleton("API")
	remove_control_from_bottom_panel(api_config)
	api_config.queue_free()
	#remove_custom_type("AIApi")
