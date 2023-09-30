extends KinematicBody2D
class_name Bullet

export(float) var velocity = 200
export(Vector2) var direction = Vector2.LEFT

onready var core = $core
onready var motion = $motion
var _direction = Vector2.RIGHT
var _current_direction = Vector2.RIGHT
var _current_velocity = Vector2.ZERO

func _ready():
	_direction = direction.normalized()
	_current_velocity = _direction * velocity

func _physics_process(delta):
	var vec = move_and_slide(compute_movement())

func compute_movement():
	_direction = _current_velocity.normalized()
	#_velocity = _direction * velocity
	motion.rotation = atan2(_direction.x, -_direction.y)
	
	return _current_velocity
	
func change_direction(phi:float):
	_current_velocity = _direction.rotated(phi) * velocity
