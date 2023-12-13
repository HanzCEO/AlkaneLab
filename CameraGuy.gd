extends CharacterBody2D

var SPEED = 300

func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W):
		velocity += Vector2.UP
	elif Input.is_key_pressed(KEY_S):
		velocity += Vector2.DOWN
	if Input.is_key_pressed(KEY_D):
		velocity += Vector2.RIGHT
	elif Input.is_key_pressed(KEY_A):
		velocity += Vector2.LEFT
	
	velocity *= SPEED
	move_and_slide()
