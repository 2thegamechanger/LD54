extends Node2D
class_name Ship


onready var core_sprite = $core_sprite
onready var core_collider = $core/core_collider
onready var field_collider = $field/field_collider
var _direction = Vector2.RIGHT
var _mouse_delta = Vector2.ZERO
var _velocity = Vector2.ZERO
var _contacts = {}
var _core_size = 0
var _field_size = 0

signal add_points
signal got_hit


func _ready():
	if Settings.INPUT_USE_MOUSE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_core_size = core_collider.shape.radius
	_field_size = field_collider.shape.radius
	change_color(0)

func _physics_process(delta):
	position += compute_movement() * delta
	position += compute_border_force() * delta
	#position += compute_border_force() * delta
	if len(_contacts) > 0:
		handle_contact()


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


func handle_contact():
	var weight = 0
	for c in _contacts.keys():
		var size = _field_size + _contacts[c]
		var dist = position.distance_to(c.global_position) - _core_size * 2
		weight += 1.0 - (dist / size)
	
	var pe = Settings.POINT_EXPONENT
	change_color(clamp(weight, 0, 1))
	emit_signal("add_points", pow(weight + 1.0, pe))


func change_color(value:float):
	value = clamp(value, 0, 1)
	
	var bcc = Settings.COLOR_PLAYER_COOL
	var bch = Settings.COLOR_PLAYER_HOT
	var col = bcc.linear_interpolate(bch, value)
	var ca = core_sprite.modulate.a # core alpha
	core_sprite.modulate = col
	core_sprite.modulate.a = ca


func compute_border_force():
	var pms = Settings.PLAYER_MAX_SPEED
	var bpf = Settings.BORDER_PUSH_FORCE
	var bpe = Settings.BORDER_PUSH_EXPONENT
	var bpd = Settings.BORDER_PUSH_DISTANCE

	var viewport_rect = get_viewport_rect()
	var sw = viewport_rect.size.x # screen width
	var sh = viewport_rect.size.y # screen height
	bpd *= sh # make distance percentage of screen height

	var gp = global_position
	var distances = [bpd - gp.x, -sw+bpd+gp.x, bpd - gp.y, -sh+bpd+gp.y]
	var f = []
	for d in distances:
		f.append( pow( max(d, 0) / bpd, bpe) )
	var force = Vector2.ZERO
	force += f[0] * Vector2.RIGHT
	force += f[1] * Vector2.LEFT
	force += f[2] * Vector2.DOWN
	force += f[3] * Vector2.UP
	
	return force * bpf * pms

func _on_field_area_entered(area):
	_contacts[area] = area.get_children()[0].shape.radius


func _on_field_area_exited(area):
	_contacts.erase(area)
	if len(_contacts) == 0:
		change_color(0)


func _on_core_area_entered(area):
	emit_signal("got_hit")
