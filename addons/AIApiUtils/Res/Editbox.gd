@tool
extends MarginContainer

'''
example_data = {
		"model": "gpt-4o-2024-08-06",
		"messages": [{"role": "user",
					"content": [{"type": "text",
								"text": "Example prompt"}]
					}],
		"max_tokens": 300,
		"temperature": 0.2,
		"response_format": 
			# 以下为存储数据	{"type": "json_schema",
							"json_schema": {"name": "image_analysis_response",
											"strict": true,
											"schema": {"type": "object",
														"properties": {"category": { "type": "string" },
																		"subject": { "type": "string" },
																		"appearance": {"type": "object",
																						"properties": {"costume": { "type": "string" },
																										"prop": { "type": "string" },
																										"expression": { "type": "string" }},
																						"required": ["costume", "prop", "expression"],
																						"additionalProperties": false},
																		"environment": {"type": "object",
																						"properties": {"location": { "type": "string" },
																										"time_of_day": { "type": "string" },
																										"mood": { "type": "string" }},
																						"required": ["location", "time_of_day", "mood"],
																						"additionalProperties": false},
																		"photography_details": {"type": "object",
																								"properties": {"shot_type": { "type": "string" },
																												"lighting": { "type": "string" },
																												"background": { "type": "string" }},
																								"required": ["shot_type", "lighting", "background"],
																								"additionalProperties": false}
																		},
														"required": ["category", "subject", "appearance", "environment", "photography_details"],
														"additionalProperties": false}
											}
							}
				}
example_answer = {
		"category": "",
		"subject": "",
		"appearance": {
						"costume": "",
						"prop": "", 
						"expression": ""
						},
		"environment": {
						"location": "",
						"time_of_day": "",
						"mood": ""
						},
		"photography_details": {
						"shot_type": "",
						"lighting": "",
						"background": ""}
						}
example_schema = {
		"type": "object",
		"properties": {"category": {"type": "string", 
									"description": ""},
						"subject": { "type": "string" },
						"appearance": {"type": "object",
										"properties": {"costume": { "type": "string" },
														"prop": { "type": "string" },
														"expression": { "type": "string" }},
										"required": ["costume", "prop", "expression"],
										"additionalProperties": false},
						"environment": {"type": "object",
										"properties": {"location": { "type": "string" },
														"time_of_day": { "type": "string" },
														"mood": { "type": "string" }},
										"required": ["location", "time_of_day", "mood"],
										"additionalProperties": false},
						"photography_details": {"type": "object",
												"properties": {"shot_type": { "type": "string" },
																"lighting": { "type": "string" },
																"background": { "type": "string" }},
												"required": ["shot_type", "lighting", "background"],
												"additionalProperties": false}
						},
		"required": ["category", "subject", "appearance", "environment", "photography_details"],
		"additionalProperties": false
				}
'''


const FORMATPATH = "res://addons/AIApiUtils/Res/format.api"
const FORMATSAVE = "res://addons/AIApiUtils/Lib/format.gd"

func zerojson(path : String = FORMATPATH):
	var data : Dictionary = {"example_schema":{}}
	var save_data = FileAccess.open(path, FileAccess.WRITE)
	save_data.store_var(data)
	save_data.close()
func readjson(path : String = FORMATPATH) -> Dictionary:
	var save_data : Dictionary = {}
	if FileAccess.file_exists(path):
		var data = FileAccess.open(path, FileAccess.READ).get_var()
		if not data:
			return {}
		if not data is Dictionary:
			data = {}
		save_data = data
	else:
		zerojson(path)
		save_data = readjson(path)
	return save_data
func updata_list():
	$Box/ButtonBox/Format.clear()
	var formatdir = readjson()
	
	var format_data : String = "\n"
	var format_ar : String = "["
	var format_list : Array = []
	
	for key in formatdir:
		$Box/ButtonBox/Format.add_item(key)
	
		format_data += "const " + key + "=" + str(formatdir[key]) + "\n"
		format_ar += key + ","
		format_list.append(key)
	if format_ar.ends_with(","):
		format_ar = format_ar.substr(0, len(format_ar) - 1)
	var data = FileAccess.open(FORMATSAVE, FileAccess.WRITE)
	data.store_string("extends Node\n" + format_data + "const format_list =" + str(format_list) \
						+ "\nvar format_save =" + format_ar + "]")
	data.close()
	EditorInterface.get_resource_filesystem().reimport_files([FORMATSAVE])

# 读
const unit_path = "res://addons/AIApiUtils/Res/schema_unit.tscn"

func creat_nodeunit(formatdir : Dictionary): # 从数据构建子节点
	var format_name = formatdir.get("json_schema", {"name":"error"}).get("name","error")
	$Box/Namebox/Name.text = format_name
	if format_name in "errorJSON":
		return
	var notedir = formatdir.get("Note", {format_name.to_upper():"noteError"})
	$Box/Namebox/Note.text = notedir[format_name.to_upper()]
	if notedir[format_name.to_upper()] in "noteError":
		return
	var schema = formatdir["json_schema"].get("schema",{"properties":{}})
	analysis($Box/Box/Unitbox, schema["properties"], notedir)
func analysis(box : Control, properties : Dictionary, notedir : Dictionary):
	for key in properties:
		var temp = load(unit_path)
		var newunit = temp.instantiate()
		box.add_child(newunit)
		var combin : bool = properties[key].get("type","string") in "object"
		newunit.update_text(key, combin, notedir.get(key,""), properties[key].get("description",""))
		if combin:
			var newbox = newunit.get_node("Unitbox")
			analysis(newbox, properties[key].get("properties",{}), notedir)

# 写
func _on_save_pressed(): # 从子节点获取结构
	var format : Dictionary = {
								"type": "json_schema",
								"json_schema": {"name": "",
												"strict": true}
								}
	var schema : Dictionary = {"type": "object"}
	
	# 存方法名
	var schema_name = $Box/Namebox/Name.text
	if schema_name.is_empty():
		$Warning.text = "Where's my name?"
		$Warning.visible = true
		await get_tree().create_timer(3).timeout
		$Warning.visible = false
		return false
	format["json_schema"]["name"] = schema_name
	
	# 初始盒子
	var box : PackedStringArray = []
	var object : Dictionary = {}
	var notedir : Dictionary = {}
	notedir[schema_name.to_upper()] = $Box/Namebox/Note.text
	for child in $Box/Box/Unitbox.get_children():
		var unit_pp = child.send_properties(notedir)
		if unit_pp[0].is_empty():
			continue
		box.append(unit_pp[0])
		object[unit_pp[0]] = unit_pp[1]
		notedir = unit_pp[2]
	if object.is_empty():
		$Warning.text = "Please type something, plz"
		$Warning.visible = true
		await get_tree().create_timer(3).timeout
		$Warning.visible = false
		return false
	
	schema["properties"] = object
	schema["required"] = box
	schema["additionalProperties"] = false
	format["Note"] = notedir
	format["json_schema"]["schema"] = schema
	
	var dir = readjson()
	dir[schema_name] = format
	var save_data = FileAccess.open(FORMATPATH, FileAccess.WRITE)
	save_data.store_var(dir)
	save_data.close()
	
	updata_list()


# 外部JSON分享
func _enter_tree():
	#get_viewport().files_dropped.connect(on_files_dropped) # 文件拖拽信号
	if !FileAccess.file_exists(FORMATPATH):
		zerojson()
	updata_list()
#func on_files_dropped(files):
	#var path : String = files[0]
	#if ("share" in path.get_extension()) and visible:
		#var json_string = FileAccess.open(path, FileAccess.READ).get_as_text()
		#var parse_result = JSON.parse_string(json_string)
		#for child in $Box/Box/Unitbox.get_children():
			#child.queue_free()
		#creat_nodeunit(parse_result)
#func share_json():
	#var schema_name = $SchemaEdit/Box/Namebox/Name.text
	#if await _on_save_pressed():
		#var schema_dir = readjson()[schema_name]
		#var json_string = JSON.stringify(schema_dir)
		#var json_path = (OS.get_executable_path().get_base_dir() + "/" + schema_name + ".share").simplify_path()
		#var save_data = FileAccess.open(json_path, FileAccess.WRITE)
		#save_data.store_string(json_string)
		#save_data.close()


func _on_del_pressed():
	var forname : String = $Box/ButtonBox/Format.text
	if !forname.is_empty():
		var dir = readjson()
		dir.erase(forname)
		var save_data = FileAccess.open(FORMATPATH, FileAccess.WRITE)
		save_data.store_var(dir)
		save_data.close()
	updata_list()

func newformat():
	$Box/Namebox/Name.text = ""
	$Box/Namebox/Note.text = ""
	for child in $Box/Box/Unitbox.get_children():
		child.queue_free()
	_on_add_pressed()

func readformat():
	var format_name : String = $Box/ButtonBox/Format.text
	for child in $Box/Box/Unitbox.get_children():
		child.queue_free()
	if format_name.is_empty():
		return
	var formatdir = readjson().get(format_name, {})
	creat_nodeunit(formatdir)

func _on_add_pressed():
	var temp = load(unit_path)
	var newunit = temp.instantiate()
	$Box/Box/Unitbox.add_child(newunit)

func _on_name_text_changed(new_text):
	var regex = RegEx.create_from_string("[,.\\w\\s-]+")
	var result = regex.search($Box/Namebox/Name.text)
	var temp : String = ""
	if result:
		temp = result.get_string()
	if temp != new_text:
		$Box/Namebox/Name.clear()
		$Box/Namebox/Name.insert_text_at_caret(temp)
		$Box/Namebox/Name/Label.visible = true
		await get_tree().create_timer(3).timeout
		$Box/Namebox/Name/Label.visible = false

