extends Node

var rotate_things_deg = 0
var selectedTool = "Select"
var connection_i = 0
var atomId_i = 0

func _physics_process(delta):
	rotate_things_deg += delta / 10
