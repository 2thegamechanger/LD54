extends Node2D
class_name Bullet

export(float) var velocity = 200
export(Vector2) var direction = Vector2.LEFT
export(PackedScene) var death_effect = null
export(Data.bullet_modifier) var modifier_type = Data.bullet_modifier.PERISTALSIS
export(float, 0, 3) var modifier_amplitude = 1.0 # relative to movement speed?
export(float, 0.5, 3) var modifier_frequency = 1.0


onready var core_sprite = $core_sprite
onready var motion_sprite = $motion_sprite
onready var core_collider = $core/core_collider
onready var field_collider = $field/field_collider
var _direction = Vector2.LEFT
var _current_direction = Vector2.LEFT
var _current_velocity = Vector2.ZERO
var _core_size = 0
var _field_size = 0
var _contacts = {}
var _modifier_value = 0.0


func _ready():
	_direction = direction.normalized()
	_current_velocity = _direction * velocity
	_core_size = core_collider.shape.radius
	_field_size = field_collider.shape.radius
	change_color(0)


func _physics_process(delta):
	# collisions
	if len(_contacts) > 0:
		handle_contact()
	
	# state
	var bm = Data.bullet_modifier
	match modifier_type:
		bm.NONE:
			compute_movement(delta)
		bm.PERISTALSIS:
			handle_peristalsis_modifier(delta)
		bm.ROTATE:
			handle_rotate_modifier(delta)
		bm.WAVE:
			handle_wave_modifier(delta)
		bm.COMBINED:
			handle_combined_modifier(delta)


func handle_peristalsis_modifier(delta):
	var mv = _modifier_value
	var mf = modifier_frequency
	var ma = modifier_amplitude
	var val = -cos(mv * mf * PI) * ma
	val = val * (0.5 * ma)  + (0.5 * ma)
	var vel = direction * velocity
	_current_velocity = vel * (1.0 - (val)) * 2.0
	compute_movement(delta)


func handle_rotate_modifier(delta):
	var ma = modifier_amplitude / PI
	_current_velocity = _current_velocity.rotated(deg2rad(ma))
	compute_movement(delta)


func handle_wave_modifier(delta):
	var mv = _modifier_value
	var mf = modifier_frequency
	var ma = modifier_amplitude
	var val = cos(mv * mf * PI) * ma
	_current_velocity = _current_velocity.normalized() * velocity * ma * 1.12
	_current_velocity = _current_velocity.rotated(deg2rad(val * 2.0))
	compute_movement(delta)


func handle_combined_modifier(delta):
	var mv = _modifier_value
	var mf = modifier_frequency
	var ma = modifier_amplitude
	
	# peristalsis
	var val = cos(mv * mf * PI * 2.0) * ma
	val = val * (0.5 * ma)  + (0.5 * ma)
	var vel = direction * velocity * 0.5
	_current_velocity = vel * (1.0 - (val)) * 4.5
	
	# wave
	val = cos(mv * mf * PI) * ma
	_current_velocity = _current_velocity.rotated(val)
	
	compute_movement(delta)	


func compute_movement(delta):
	position += _current_velocity * delta
	if _current_velocity != Vector2.ZERO:
		_direction = _current_velocity.normalized()
	motion_sprite.rotation = atan2(_direction.x, -_direction.y)
	_modifier_value += delta


func handle_contact():
	var weight = 0
	for c in _contacts.keys():
		var size = _field_size + _contacts[c]
		var dist = position.distance_to(c.global_position) - _core_size * 2
		weight += dist / size
	
	change_color(1.0 - clamp(weight, 0, 1))


func set_direction(dir:Vector2):
	direction = dir.normalized()
	_current_velocity = direction * velocity
	_direction = direction


func change_direction(phi:float):
	direction = direction.rotated(phi)
	_direction = direction
	_current_velocity = direction * velocity


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
	if death_effect and area.owner is Ship:
		var e = death_effect.instance() as Effect
		get_tree().root.add_child(e)
	queue_free()
