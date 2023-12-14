extends RigidBody2D

var color = Color.LIGHT_SLATE_GRAY: set = _set_color, get = _get_color

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_color(color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _set_color(val):
	color = val
	$Circle.modulate = val

func _get_color():
	return color
