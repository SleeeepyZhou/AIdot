@tool
extends TabContainer

const Default_Model_path = "user://maochat/maochat.tres"

func _ready() -> void:
	chat_bot.chat_completed.connect(call_back)
	_on_type_pressed()
	if FileAccess.file_exists(Default_Model_path):
		chat_bot.model = load(Default_Model_path)
		url.text = chat_bot.model.api_url
		key.text = chat_bot.model.api_key
		type.text = ModelLayer.get_type(chat_bot.model.model_name)
		llm.text = chat_bot.model.model_name


# MaoChat
@onready var chat_bot: ChatAgent = $MaoChat/MaoChat/ScrollContainer/ChatBot
@onready var chat_list: VBoxContainer = $MaoChat/MaoChat/ScrollContainer/ChatList
const CHAT_UNIT = preload("res://addons/AIdot/Res/Agents/GodotAssistant/ChatUnit.tscn")

@onready var user_agent: UserAgent = $MaoChat/MaoChat/Input/Input/UserAgent
@onready var input_box: TextEdit = $MaoChat/MaoChat/Input/Input/InputBox
@onready var send: Button = $MaoChat/MaoChat/Input/Input/Send
@onready var idle_pan: PanelContainer = $MaoChat/MaoChat/Input/IdlePan
@onready var idle: RichTextLabel = $MaoChat/MaoChat/Input/IdlePan/Idle

const idle_effects = [
	"[pulse freq=1.0 color=#ffffff40 ease=-2.0]{0}[/pulse]",
	"[wave amp=50.0 freq=5.0 connected=1]{0}[/wave]",
	"[shake rate=20.0 level=5 connected=1]{0}[/shake]",
	"[tornado radius=10.0 freq=1.0 connected=1]{0}[/tornado]",
	"[rainbow freq=1.0 sat=0.8 val=0.8]{0}[/rainbow]",
]
const rainbow_phrases = [
	"🌈 正在穿越彩虹隧道... 98%", 
	"📡 量子波动速读中... ███████░░░",
	"🚀 正在准备跃迁跳跃... 倒计时3秒",
	"🕶️ 正在解码元宇宙入口... 验证通过",
	"🎮 启动云游戏协议... 🕹️ 加载成就系统",
	"🔭 星际导航校准中... 🌌 发现新星门",
	"🤖 AI诗人正在创作... ✍️ 生成彩虹十四行诗",
	"🧬 正在克隆快乐基因... ⚗️ 培养液浓度正常",
	"🛸 接收外星快递中... 📦 包裹已消毒",
	"🎨 渲染虚拟彩虹... 🖌️ 正在混合七种光波",
	"🌀 破解次元壁... 💥 发现隐藏关卡",
	"🔮 预测未来天气... ☀️ 明日将出现太阳雨",
	"🧿 启动幸运增幅器... 🐱 黑猫转化白猫程序",
	"🪐 同步轨道空间站... 👨🚀 宇航员表情包已更新",
	"🎲 正在掷命运骰子... 🎯 结果为：大吉",
	"🦄 捕捉幻兽幼崽... 🍬 使用彩虹软糖诱捕",
	"⌛ 时空褶皱修复中... ⏳ 维持因果律稳定",
	"🐟 量子锦鲤加载中... 💫 好运buff已叠加",
	"🧊 正在融化冰河世纪... 🌸 史前花朵即将绽放",
	"🎭 切换人格面具... 🤹 准备多元演绎",
	"🤯 三体问题简化为... 💡 双击点亮太阳",
	"🍵 正在泡电子茶... ⌛ 等待量子沸腾",
	"🎧 脑波降噪中... 🎶 检测到BGM《天空之城》",
	"🐌 加速蜗牛进程... 🏎️ 当前时速0.5公里",
	"📚 加载人生重开模拟器... 🌠 选择『彩虹学者』职业",
	"🛋️ 检测到舒适区... ⚠️ 建议继续瘫坐",
	"🍳 煎蛋物理学研究... ☢️ 完美溏心率99.9%",
	"🧘 进入禅定模式... 🙏 404烦恼未找到",
	"📊 分析摸鱼数据... 📈 今日效率曲线：__---~~~",
	"🎁 准备时空盲盒... ✨ 内含平行世界的你"
]
func idle_text():
	var effect: String = "[center]"
	if randf() < 0.1:
		var base_text = "请稍等..." + rainbow_phrases[randi()%len(rainbow_phrases)] +\
						"(发现彩蛋 幸运+1)"
		effect += idle_effects[-1].format([base_text])
	else:
		var base_text = "请稍等......"
		effect += idle_effects[randi()%(len(idle_effects)-1)].format([base_text])
	effect += "[/center]"
	return effect


func _on_send_pressed() -> void:
	if !chat_bot.model:
		push_error("ChatBot has no model.")
		return
	send.disabled = true
	input_box.editable = false
	idle.text = idle_text()
	idle_pan.visible = true
	chat_bot.chat(input_box.text, user_agent)


func call_back(chat_id : int, _final_answer : String, chat_info : Dictionary):
	if chat_info.get("status") == "failed":
		idle.text = "Chat failed, Please check errors in the console output."
		push_error(chat_info.get("result"))
		await get_tree().create_timer(3).timeout
		idle_pan.visible = false
		input_box.editable = true
		send.disabled = false
		return
	var in_unit = CHAT_UNIT.instantiate()
	chat_list.add_child(in_unit)
	in_unit.chat_data = chat_info["input"]
	var out_unit = CHAT_UNIT.instantiate()
	chat_list.add_child(out_unit)
	out_unit.chat_data = chat_info["result"]["message"]
	input_box.text = ""
	idle_pan.visible = false
	input_box.editable = true
	send.disabled = false


# API config
@onready var type: OptionButton = $Config/APIConfig/Select/Type
@onready var llm: OptionButton = $Config/APIConfig/Select/LLM
@onready var cllm: LineEdit = $Config/APIConfig/Select/CLLM

@onready var url: LineEdit = $Config/APIConfig/APIUrl/Url
@onready var key: LineEdit = $Config/APIConfig/APIKey/Key

@onready var use_res: CheckBox = $Config/APIConfig/Path/UseRes
@onready var model_path: LineEdit = $Config/APIConfig/Path/Path

func refresh_model():
	type.clear()
	for t in ModelLayer.model_list.keys():
		type.add_item(t)

var _is_refresh : bool = false
func _on_type_pressed() -> void:
	if !_is_refresh:
		refresh_model()

func _on_type_item_selected(index: int) -> void:
	llm.clear()
	var model_list : Array = ModelLayer.model_list[type.text]
	if model_list.is_empty():
		llm.visible = false
		cllm.visible = true
		return
	llm.visible = true
	cllm.visible = false
	for m in model_list:
		llm.add_item(m)


func _on_use_res_toggled(toggled_on: bool) -> void:
	model_path.visible = toggled_on


func _on_save_pressed() -> void:
	if chat_bot.model:
		chat_bot.model.save_model(Default_Model_path)
		print("The currently used model has been set as default.")
	else:
		push_warning("Please set up the model for the Bot first.")


func _on_set_pressed() -> void:
	var model : BaseModel
	if use_res.button_pressed:
		if model_path.text.get_extension() != "tres":
			push_error("The file is not a resource file."+model_path.text.get_extension())
		else:
			var res = load(model_path.text)
			if res is BaseModel:
				model = res
			else:
				push_error("The file is not a model resource."+model_path.text)
	else:
		if type.text == "DEFAULT":
			if url.text.is_empty() or key.text.is_empty():
				model = ModelLayer.creat_model(cllm.text)
			else:
				model = ModelLayer.creat_model(cllm.text, url.text, key.text)
		else:
			if url.text.is_empty() or key.text.is_empty():
				model = ModelLayer.creat_model(llm.text)
			else:
				model = ModelLayer.creat_model(llm.text, url.text, key.text)
		url.text = model.api_url
		key.text = model.api_key
	chat_bot.model = model
	print("Model setted.")


# MCP config
@onready var server_list: VBoxContainer = $MCP/MCP/ServerBox/ServerList
const SERVER_UNIT = preload("res://addons/AIdot/Res/Agents/GodotAssistant/ServerUnit.tscn")

func get_tools():
	chat_bot.tool_bag.add_tool(ToolBox.get_box_tool())

func _on_add_server_pressed() -> void:
	var unit = SERVER_UNIT.instantiate()
	server_list.add_child(unit)
	unit.server_change.connect(get_tools)
