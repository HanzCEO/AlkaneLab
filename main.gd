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
		if Global.selectedTool == "Select":
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				if hoveredAtom:
					hoveredAtom.get_node("Circle").texture = normalCircle
					mousePressed = true
					activeAtom = hoveredAtom
			elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
				if hoveredAtom and activeAtom:
					activeAtom.deactivate_scan_outline()
					activeAtom.get_node("Circle").texture = dashedCircle
					mousePressed = false
					if not hoveredAtom is RigidBody2D:
						pass
					else:
						# Make a bond
						var line = Line2D.new()
						line.add_point(hoveredAtom.position)
						line.add_point(activeAtom.position)
						$Connections.add_child(line)
						activeAtom.register_connection_with(hoveredAtom, line, 1)
						hoveredAtom.register_connection_with(activeAtom, line, 0)
					activeAtom = false
		elif Global.selectedTool == "Move":
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				if hoveredAtom:
					mousePressed = true
					activeAtom = hoveredAtom
			elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
				if activeAtom:
					activeAtom.linear_damp = 5
					activeAtom = false
					mousePressed = false
		elif Global.selectedTool == "Delete":
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				if hoveredAtom:
					var connections = hoveredAtom.get_connection_lines().duplicate()
					for connection in connections:
						hoveredAtom.disconnect_with(connection["atom"])
					
					var t: Tween = hoveredAtom.create_tween()
					t.tween_property(hoveredAtom, "scale", Vector2.ZERO, 0.2)
					t.connect("finished", hoveredAtom.queue_free)
					t.play()
					hoveredAtom = false

func _physics_process(delta):
	if Global.selectedTool == "Move":
		if activeAtom and mousePressed:
			var mpos = get_global_mouse_position()
			var apos = activeAtom.global_position
			if mpos.distance_to(apos) < 2.0:
				activeAtom.set_linear_velocity(Vector2())
				activeAtom.linear_damp = 5
			else:
				activeAtom.rerender_connection_lines()
				activeAtom.linear_damp = 0
				activeAtom.set_linear_velocity(apos.direction_to(mpos) * apos.distance_to(mpos) * 1000 * delta)
