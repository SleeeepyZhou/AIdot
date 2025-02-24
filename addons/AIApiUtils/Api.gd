extends Node
class_name API_Util
## AI API tool for quickly using various LLM/MLLM APIs.
##
## Plugin docking adapts to various commonly used large model APIs on the market, 
## including OpenAI's GPT series models, Qwen VL series models, claude, 
## and local models such as cog、moondream (using OpenAI API adaptation scripts),
## allowing AI to be integrated into applications and games created in Godot.
##
## @experimental

# @tutorial(Tutorial 2): https://example.com/tutorial_2

## 工具接口
var VLMutils : Variant = preload("res://addons/AIApiUtils/Lib/VLMUtils.gd").new()
func _ready():
	add_child(VLMutils)

## 图片输入质量
enum IMAGE_Q {HIGH, LOW, AUTO}

## 结构化规则存档位置路径
const FORMATSAVE = "res://addons/AIApiUtils/Lib/format.gd"

## 查看已存储的结构化规则
var format_list : Array = []:
	get:
		var format_save = load(FORMATSAVE).new()
		format_list = format_save.format_list
		return format_list

## 查看支持的api模型列表
var mod_list : Array = []:
	get:
		mod_list = VLMutils.API_TYPE
		return mod_list

## 重置用户的API信息
func reset():
	VLMutils.reset()

## 存储用户的APIurl以及key，存储位置在"user://data.api"
func save(api_url : String, api_key : String):
	VLMutils.api_save([api_url, api_key])

## 获取id为format_id的format
func get_format(format_id : int = 0) -> Dictionary:
	var format_save = load(FORMATSAVE).new()
	if format_save.format_save.size() > 0:
		format_id = clampi(format_id, 0, format_save.format_save.size() - 1)
		return format_save.format_save[format_id]
	else:
		return {"Error" : "NO DATA"}

## 运行VLMAPI，prompt提示词为必须输入，api_mod可调用mod_list查看
func run_VLMapi(prompt : String, api_mod : int = 0, timeout : int = 10, image_path : String = "", \
			image_quality : int = IMAGE_Q.AUTO, format : Dictionary = { }) -> String:
	timeout = clampi(timeout, 0, 300)
	api_mod = clampi(api_mod, 0, VLMutils.API_TYPE.size() - 1)
	image_quality = clampi(image_quality, 0, 2)
	return await VLMutils.run_api(prompt, api_mod, image_path, image_quality, timeout, format)
