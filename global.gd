extends Node

var rotate_things_deg = 0
var selectedTool = "Select"

func _physics_process(delta):
	rotate_things_deg += delta / 10
