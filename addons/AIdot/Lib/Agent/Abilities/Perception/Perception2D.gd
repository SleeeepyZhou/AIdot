extends Node2D
class_name AgentSensor2D

var body : Area2D
var listener : AudioListener2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	listener = AudioListener2D.new()
	add_child(listener)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
