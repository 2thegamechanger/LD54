extends KinematicBody2D
class_name Ship

var _direction = Vector2.RIGHT
var _mouse_delta = Vector2.ZERO
var _velocity = Vector2.ZERO

func _ready():
	if Settings.INPUT_USE_MOUSE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		

func _physics_process(delta):
	var vec = move_and_slide(compute_movement())


func _input(event):
	if event is InputEventMouseMotion:
		_mouse_delta = event.relative


func compute_movement():
	var msp = Settings.PLAYER_MAX_SPEED
	var va = Settings.PLAYER_VELOCITY_ATTACK 
	var vd = Settings.PLAYER_VELOCITY_DECAY
	
	var vel = Vector2.ZERO
	
	if Settings.INPUT_USE_KEYS:
		if Input.is_action_pressed("left"): vel += Vector2.LEFT
		if Input.is_action_pressed("right"): vel += Vector2.RIGHT
		if Input.is_action_pressed("up"): vel += Vector2.UP
		if Input.is_action_pressed("down"): vel += Vector2.DOWN
	
	if Settings.INPUT_USE_CONTROLLER:
		var joy = Vector2(Input.get_joy_axis(0,0), Input.get_joy_axis(0,1))
		if joy.length() > 0.5: vel += joy
	
	if Settings.INPUT_USE_MOUSE:
		vel += _mouse_delta
	
	_direction = vel.normalized()
	_mouse_delta = Vector2.ZERO
	if vel != Vector2.ZERO:
		_velocity += _direction * va
	else: 
		_velocity -= _velocity.normalized() * vd
	_velocity = Utils.vec_clamp(_velocity, 0.0, msp)
	
	return _velocity
