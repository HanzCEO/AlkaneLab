extends Node

var rotate_things_deg = 0
var selectedTool = "Select"
var connection_i = 0
var atomId_i = 0

var world = null

func set_world(w):
	world = w

func _physics_process(delta):
	rotate_things_deg += delta / 10

func analyze_compound_name():
	world.get_node("CanvasLayer/UpperContainer/CompoundName").analyze()
