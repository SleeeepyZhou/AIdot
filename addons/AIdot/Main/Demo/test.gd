extends Node2D

func _ready():
	var testmod = OpenAIModel.new()
	testmod.get_response([true,""])
