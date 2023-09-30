extends Node2D
class_name Bullet

export(float) var velocity = 200
export(Vector2) var direction = Vector2.LEFT

onready var core_sprite = $core_sprite
onready var motion_sprite = $motion_sprite
onready var core_collider = $core/core_collider
onready var field_collider = $field/field_collider
var _direction = Vector2.RIGHT
var _current_direction = Vector2.RIGHT
var _current_velocity = Vector2.ZERO
var _core_size = 0
var _field_size = 0
var _contact = {}

func _ready():
	_direction = direction.normalized()
	_current_velocity = _direction * velocity
	_core_size = core_collider.shape.radius
	_field_size = field_collider.shape.radius
	
func _physics_process(delta):
	position += compute_movement() * delta
	if len(_contact) > 0:
		handle_contact()

func compute_movement():
	_direction = _current_velocity.normalized()
	#_velocity = _direction * velocity
	motion_sprite.rotation = atan2(_direction.x, -_direction.y)
	
	return _current_velocity

func handle_contact():
	var bcc = Settings.COLOR_BULLET_COOL
	var bch = Settings.COLOR_BULLET_HOT
	
	var weight = 0
	for c in _contact.keys():
		#var size = _field_size - _core_size
		var dist = position.distance_to(c.global_position) - _core_size * 2
		weight += dist / _field_size
		print("distance: ",dist," weight: ", weight," field size: ",_field_size)
	
	var col = bch.linear_interpolate(bcc, clamp(weight, 0, 1))
	core_sprite.modulate = col
	motion_sprite.modulate = col
	
func change_direction(phi:float):
	_current_velocity = _direction.rotated(phi) * velocity


func _on_field_area_entered(area):
	_contact[area] = true

func _on_field_area_exited(area):
	_contact.erase(area)


func _on_core_area_entered(area):
	queue_free()
