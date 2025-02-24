@tool
extends HBoxContainer

var key : String = "":
	get:
		key = $Keyword.text
		return key
	set(t):
		$Keyword.text = t
		key = t
var description : String = "":
	get:
		description = $Description.text
		return description
	set(t):
		$Description.text = t
		description = t
var is_object : bool = false:
	set(b):
		$Combination.button_pressed = b
		is_object = b
var note : String = "":
	get:
		note = $Note/Note.text
		return note
	set(t):
		$Note/Note.text = t
		note = t

func update_text(keyword : String, combin : bool = false, notaword : String = "", descri : String = ""):
	key = keyword
	description = descri
	is_object = combin
	note = notaword

func send_properties(notedir : Dictionary = {}): # 向上返回数据
	var properties : Dictionary = {}
	notedir[key] = note
	if !description.is_empty():
		properties["description"] = description
	if is_object:
		var object : Dictionary = {}
		var box : PackedStringArray = []
		for child in $Unitbox.get_children():
			var unit_pp = child.send_properties(notedir)
			if unit_pp[0].is_empty():
				continue
			box.append(unit_pp[0])
			object[unit_pp[0]] = unit_pp[1]
			notedir = unit_pp[2]
		if object.is_empty():
			properties["type"] = "string"
		else:
			properties["type"] = "object"
			properties["properties"] = object
			properties["required"] = box
			properties["additionalProperties"] = false
	else:
		properties["type"] = "string"
	return [key, properties, notedir]

func _on_combination_toggled(toggled_on):
	if toggled_on:
		$Add.visible = true
		is_object = true
	else:
		$Add.visible = false
		is_object = false
		for child in $Unitbox.get_children():
			child.queue_free()
func _on_add_pressed():
	var temp = load("res://Lib/Extra/JsonSchema/schema_unit.tscn")
	var newunit = temp.instantiate()
	$Unitbox.add_child(newunit)
func _on_delete_button_up():
	queue_free()
func _on_note_pressed():
	$Note/Note.visible = !$Note/Note.visible
func _on_keyword_text_changed(new_text):
	var regex = RegEx.create_from_string("[,.\\w\\s-]+")
	var result = regex.search($Keyword.text)
	var temp : String = ""
	if result:
		temp = result.get_string()
	if temp != new_text:
		$Keyword.clear()
		$Keyword.insert_text_at_caret(temp)
		$Keyword/Label.visible = true
		await get_tree().create_timer(3).timeout
		$Keyword/Label.visible = false
func _on_description_text_changed():
	var new_text = $Description.text
	var regex = RegEx.create_from_string("[,.\\w\\s-]+")
	var result = regex.search($Description.text)
	var temp : String = ""
	if result:
		temp = result.get_string()
	if temp != new_text:
		$Description.clear()
		$Description.insert_text_at_caret(temp)
		$Keyword/Label.visible = true
		await get_tree().create_timer(3).timeout
		$Keyword/Label.visible = false
