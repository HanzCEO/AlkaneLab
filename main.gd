extends Node2D

var tool = "Select"
var dashedCircle = preload("res://circle-dashed.svg")
var normalCircle = preload("res://circle.svg")
var activeAtom = false
var hoveredAtom = false
var mousePressed  = false

func register_new_atom(atom):
	$Atoms.add_child(atom)
	
	atom.position = $CameraGuy.global_position
	atom.connect("mouse_entered", _process_atom_hover.bind(atom, 1))
	atom.connect("mouse_exited", _process_atom_hover.bind(atom, 0))
	
func _process_atom_hover(atom, isEnter):
	if isEnter:
		atom.activate_scan_outline()
		hoveredAtom = atom
	elif not mousePressed:
		atom.deactivate_scan_outline()
		hoveredAtom = false
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if hoveredAtom:
				hoveredAtom.get_node("Circle").texture = normalCircle
				mousePressed = true
				activeAtom = hoveredAtom
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			if hoveredAtom:
				activeAtom.deactivate_scan_outline()
				activeAtom.get_node("Circle").texture = dashedCircle
				mousePressed = false
				if not hoveredAtom is RigidBody2D:
					pass
				elif Global.selectedTool == "Select":
					# Make a bond
					var line = Line2D.new()
					line.add_point(activeAtom.position)
					line.add_point(hoveredAtom.position)
					$Connections.add_child(line)
				activeAtom = false
