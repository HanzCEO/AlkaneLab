extends RigidBody2D

var color = Color.LIGHT_SLATE_GRAY: set = _set_color, get = _get_color
var connections = []

func _ready():
	_set_color(color)
	$AnimationPlayer.connect("animation_finished", _invis_scan)

func _physics_process(delta):
	$Scan.rotation = Global.rotate_things_deg

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
		"atom": atom,
		"lineNode": line,
		"index": atomPointIndex
	})
func get_connection_lines():
	return connections

func _set_color(val):
	color = val
	$Circle.modulate = val

func _get_color():
	return color
