@tool
extends MarginContainer

const MAO = preload("res://addons/AIdot/Res/UI/Chat/Mao.tres")
const CAT = preload("res://addons/AIdot/Res/UI/Chat/Cat.jpg")

const role = {
	"assistant" : MAO,
	"user" : CAT
}

@onready var _chat: RichTextLabel = $ChatUnit/Panel/Box/Chat
var _chat_text : String:
	set(t):
		_chat_text = t
		_chat.text = _chat_text
	get:
		return _chat.text

@onready var _head: TextureRect = $ChatUnit/HeadBox/HeadContainer/Head
var _chater : String = "assistant":
	set(r):
		_chater = r
		_head.texture = role[_chater]

var chat_data : Dictionary:
	set(d):
		if !d.get("content") or !d.get("role"):
			push_error("Invalid _chat data.")
			return
		if !role.keys().has(d.get("role")):
			push_error("Invalid identity.")
			return
		chat_data = d
		_chater = d.get("role")
		_chat_text = d.get("content")
	get:
		return {
			"role": _chater,
			"content": _chat_text
		}
