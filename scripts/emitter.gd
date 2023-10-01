extends Node2D
class_name Emitter

export(float, 0.1, 10) var spawn_interval_in_seconds = 3
export(int) var amount = 1
export(float, 1.0, 500.0) var bullet_speed = 200.0
export(float, 0.0, 1.0) var bullet_speed_deviation_in_percent = 0.0
export(float, 0.0, 180.0) var angle_deviation_in_degree = 0.0
export(PackedScene) var bullet_scene = null
export(Data.bullet_modifier) var bullet_modifier = Data.bullet_modifier.NONE
export(Data.bullet_pattern) var bullet_pattern = Data.bullet_pattern.RANDOM
export(Data.bullet_dispension) var bullet_dispension = Data.bullet_dispension.BURST
export(float, 0, 3) var modifier_amplitude = 1.0
export(float, 0.5, 3) var modifier_frequency = 1.0

onready var _placeholder_sprite = $placeholder_sprite
var _bullet = null
var _spawn_state = 0.0
var _interval = 0
var _next_spawn_time = 0
var _next_bullet_spawn_time
var _is_active = false
var _is_finished = false
var _finish_time = 0
var _has_spawned = false

func _ready():
	_next_spawn_time = _interval * Engine.iterations_per_second + OS.get_ticks_msec()
	_bullet = bullet_scene
	_interval = spawn_interval_in_seconds
	_placeholder_sprite.visible = false


func _physics_process(delta):
	if not _bullet or not _is_active or _is_finished: return
	if finish_time_passed(): _is_finished = true
	
	var bd = Data.bullet_dispension
	match bullet_dispension:
		bd.NONE:
			#if spawn_time_passed():
			#	pass#set_next_spawn()
			pass
		bd.CHAIN:
			if not _has_spawned:#spawn_time_passed():
				#set_next_spawn()
				_has_spawned = true
				set_next_bullet_spawn(0)
				_spawn_state = 0.0
				
			if bullet_spawn_time_passed():
				handle_spawn(_spawn_state, bullet_pattern, bullet_modifier)
				_spawn_state += 1.0 / (amount + 0)
				set_next_bullet_spawn()
		bd.BURST:
			if not _has_spawned:#spawn_time_passed():
				_spawn_state = 0.0
				for i in range(amount):
					handle_spawn(_spawn_state, bullet_pattern, bullet_modifier)
					_spawn_state += 1.0 / (amount + 0)
				#set_next_spawn()
				_has_spawned = true


func handle_spawn(state, pattern, modifier):
	var bp = Data.bullet_pattern
	match pattern:
		bp.NONE:
			return
		bp.CIRCLE_CW:
			var rdir = rand_range(-1, 1) * angle_deviation_in_degree
			var vec = Vector2.LEFT.rotated(deg2rad(rdir))
			var rvel = rand_range(1.0 - bullet_speed_deviation_in_percent, 1.0)
			spawn_bullet( global_position
						, vec.rotated(state * PI * 2.0)
						, bullet_speed * rvel
						, modifier 
						, modifier_amplitude
						, modifier_frequency)
		bp.CIRCLE_CCW:
			var rdir = rand_range(-1, 1) * angle_deviation_in_degree
			var vec = Vector2.LEFT.rotated(deg2rad(rdir))
			var rvel = rand_range(1.0 - bullet_speed_deviation_in_percent, 1.0)
			spawn_bullet( global_position
						, vec.rotated(-state * PI * 2.0)
						, bullet_speed * rvel
						, modifier 
						, modifier_amplitude
						, modifier_frequency)
		bp.RANDOM:
			var rdir = rand_range(-1, 1) * angle_deviation_in_degree
			var rvel = rand_range(1.0 - bullet_speed_deviation_in_percent, 1.0)
			spawn_bullet( global_position
						, Vector2.LEFT.rotated(deg2rad(rdir))
						, bullet_speed * rvel
						, modifier
						, modifier_amplitude
						, modifier_frequency )


func spawn_bullet(pos, direction, speed, modifier, amplitude, frequency):
	var b = _bullet.instance() as Bullet
	b.modifier_type = modifier
	b.modifier_amplitude = amplitude
	b.modifier_frequency = frequency
	b.velocity = speed
	# parent to level or root
	var n = self
	while n.get_parent():
		n = n.get_parent()
		if n is Level:
			n.add_child(b)
			break
	if not n.get_parent(): get_tree().root.add_child(b)
	b.position = pos
	b.set_direction(direction)
	# TODO: Handle frame difference in bullet spawn
	# TODO: add rotation in world space


func spawn_time_passed():
	return OS.get_ticks_msec() >= _next_spawn_time


func set_next_spawn(value = _interval):
	if value != 0.0:
		_next_spawn_time = value * Engine.iterations_per_second * 20 + OS.get_ticks_msec()
	else:
		_next_spawn_time = OS.get_ticks_msec()


func bullet_spawn_time_passed():
	return OS.get_ticks_msec() >= _next_bullet_spawn_time


func set_next_bullet_spawn(value = _interval / (amount + 0)):
	if value != 0.0:
		_next_bullet_spawn_time = value * Engine.iterations_per_second * 20 + OS.get_ticks_msec()
	else:
		_next_bullet_spawn_time = OS.get_ticks_msec()


func finish_time_passed():
	return OS.get_ticks_msec() >= _finish_time


func set_finish_time(value = _interval):
	if value != 0.0:
		_finish_time = value * Engine.iterations_per_second * 20 + OS.get_ticks_msec()
	else:
		_finish_time = OS.get_ticks_msec()


func set_active(value:bool):
	if not _is_active and value:
		_is_active = true
		_is_finished = false
		_spawn_state = 0.0
		_has_spawned = false
		set_finish_time()
	elif _is_active and not value:
		_is_active = false
		_is_finished = true
		_spawn_state = 0.0
		_has_spawned = true
		set_next_bullet_spawn(0)
		set_next_spawn(0)
		set_finish_time(0)


func is_active():
	return _is_active


func is_finished():
	return _is_finished
