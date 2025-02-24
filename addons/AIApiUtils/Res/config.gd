@tool
extends VBoxContainer

const SAVEPATH = "user://data.api"
func _ready():
	var save_data : Array = ["https://api.openai.com/v1/chat/completions", ""]
	if FileAccess.file_exists(SAVEPATH):
		var data = FileAccess.open(SAVEPATH, FileAccess.READ).get_var()
		if (not data) or (not data is Array):
			var dir = FileAccess.open(SAVEPATH, FileAccess.WRITE)
			dir.store_var(save_data)
			dir.close()
			data = save_data
		save_data = data
	else:
		var dir = FileAccess.open(SAVEPATH, FileAccess.WRITE)
		dir.store_var(save_data)
		dir.close()
	$Box/APIurl.text = save_data[0]
	$Box/APIkey.text = save_data[1]

func _on_confirm_pressed():
	var data : Array[String] = [$Box/APIurl.text, $Box/APIkey.text]
	var save_data = FileAccess.open(SAVEPATH, FileAccess.WRITE)
	save_data.store_var(data)
	save_data.close()

func _on_use_format_toggled(toggled_on):
	$Editbox.visible = toggled_on
