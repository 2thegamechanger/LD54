extends KinematicBody2D

var _direction = Vector2.RIGHT

func _ready():
	pass
		

func _physics_process(delta):
	move_and_slide(compute_movement(delta))


func compute_movement(delta):
	var sp = Settings.PLAYER_SPEED
	var vel = Vector2.ZERO
	if Input.is_action_pressed("left"): vel += Vector2.LEFT
	if Input.is_action_pressed("right"): vel += Vector2.RIGHT
	if Input.is_action_pressed("up"): vel += Vector2.UP
	if Input.is_action_pressed("down"): vel += Vector2.DOWN
	
	_direction = vel.normalized()
	print(_direction * sp)
	return _direction * sp #*delta
