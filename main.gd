extends Node2D

var tool = "Select"
var dashedCircle = preload("res://circle-dashed.svg")
var normalCircle = preload("res://circle.svg")

func register_new_atom(atom):
	$Atoms.add_child(atom)
	
	atom.position = $CameraGuy.global_position
	atom.connect("mouse_entered", _process_atom_hover.bind(atom, 1))
	atom.connect("mouse_exited", _process_atom_hover.bind(atom, 0))
	
func _process_atom_hover(atom, isEnter):
	if isEnter:
		atom.activate_scan_outline()
	else:
		atom.deactivate_scan_outline()
	
	
