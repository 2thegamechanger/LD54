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
var _contacts = {}

func _ready():
	_direction = direction.normalized()
	_current_velocity = _direction * velocity
	_core_size = core_collider.shape.radius
	_field_size = field_collider.shape.radius
	change_color(0)
	
func _physics_process(delta):
	position += compute_movement() * delta
	if len(_contacts) > 0:
		handle_contact()

func compute_movement():
	_direction = _current_velocity.normalized()
	#_velocity = _direction * velocity
	motion_sprite.rotation = atan2(_direction.x, -_direction.y)
	
	return _current_velocity

func handle_contact():
	var weight = 0
	for c in _contacts.keys():
		var size = _field_size + _contacts[c]
		var dist = position.distance_to(c.global_position) - _core_size * 2
		weight += dist / size
	
	change_color(1.0 - clamp(weight, 0, 1))
	
func change_direction(phi:float):
	_current_velocity = _direction.rotated(phi) * velocity

func change_color(value:float):
	value = clamp(value, 0, 1)
	
	var bcc = Settings.COLOR_BULLET_COOL
	var bch = Settings.COLOR_BULLET_HOT
	var col = bcc.linear_interpolate(bch, value)
	var ca = core_sprite.modulate.a # core alpha
	var ma = motion_sprite.modulate.a # motion alpha
	core_sprite.modulate = col
	motion_sprite.modulate = col
	core_sprite.modulate.a = ca
	motion_sprite.modulate.a = ma

func _on_field_area_entered(area):
	_contacts[area] = area.get_children()[0].shape.radius

func _on_field_area_exited(area):
	_contacts.erase(area)
	if len(_contacts.keys()) == 0:
		change_color(0)


func _on_core_area_entered(area):
	queue_free()
