extends KinematicBody2D

var _direction = Vector2.RIGHT

func _ready():
	pass
		

func _physics_process(delta):
	var vel = compute_movement(delta)
	move_and_slide(vel)
	_direction = vel.normalized()


func compute_movement(delta):
	pass
