extends RigidBody2D

var color = Color.LIGHT_SLATE_GRAY: set = _set_color, get = _get_color
var connections = []
var isAtom = true
var rerender = false

func _ready():
	_set_color(color)
	$AnimationPlayer.connect("animation_finished", _invis_scan)

func _physics_process(delta):
	$Scan.rotation = Global.rotate_things_deg
	
	if linear_velocity != Vector2.ZERO:
		rerender = true
	
	if rerender:
		var lines = get_connection_lines()
		for line in lines:
			line["lineNode"].points[line["index"]] = global_position
		rerender = false

func activate_scan_outline():
	$Scan.visible = true
	$AnimationPlayer.play("activate_scan_outline")

func deactivate_scan_outline():
	$AnimationPlayer.play_backwards("activate_scan_outline")
func _invis_scan(x):
	if $Scan.modulate.a == 0:
		$Scan.visible = false

func register_connection_with(atom, line, atomPointIndex):
	connections.append({
		"id": Global.connection_i,
		"atom": atom,
		"lineNode": line,
		"index": atomPointIndex
	})
	
	Global.connection_i += 1
func get_connection_lines():
	return connections

func disconnect_with(atom, loopQF=true):
	for connection in get_connection_lines():
		if connection["atom"] == atom:
			if loopQF:
				atom.disconnect_with(self, false)
			connection["lineNode"].queue_free()
			connections.erase(connection)

func rerender_connection_lines():
	rerender = true

func _set_color(val):
	color = val
	$Circle.modulate = val

func _get_color():
	return color

func _on_body_collision(body):
	if body.isAtom:
		body.rerender_connection_lines()
