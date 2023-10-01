extends Node2D
class_name Enemy

export(Data.entry_type) var entry = Data.entry_type.STRAIGHT
export(float) var entry_time_in_seconds = 2.0
export(float) var spawn_predelay_in_seconds = 2.0
export(float, 200, 500) var entry_distance = 300
export(Data.movement_type) var movement = Data.movement_type.NONE
export(float) var movement_speed = 1.0
export(float) var movement_range = 200
export(Array, NodePath) var emitters

onready var _placeholder_sprite = $enemy_sprite
var _level_manager:LevelManager = null
var _state = Data.ship_state.NONE
var _emitter_id = 0
var _start_time = 0
var _emitters = []

func _ready():
	_state = Data.ship_state.PAUSE
	if len(emitters) > 0:
		for e in emitters:
			var i = get_node(e)
			if i:
				_emitters.append(get_node(e))
		for e in _emitters:
			e.set_active(false)
	_start_time = spawn_predelay_in_seconds * Engine.iterations_per_second + OS.get_ticks_msec()
	_placeholder_sprite.visible = false


func _physics_process(delta):
	var ss = Data.ship_state
	match _state:
		ss.ENTRY:
			_state = ss.EMISSION
		ss.EMISSION:
			pass
		ss.DEATH:
			queue_free()
		ss.PAUSE:
			if _level_manager:
				_state = ss.ENTRY
	
	if len(_emitters) > 0 and start_time_passed():
		handle_emission()


func handle_emission():
	var e = _emitters[_emitter_id]
	if not e.is_active():
		e.set_active(true)
		#print("activated emitter: ",e.name," finish time: ",e._finish_time," current time: ", OS.get_ticks_msec())
	elif e.is_finished():
		#print("deactivated emitter ",e.name)
		e.set_active(false)
		_emitter_id += 1
		if _emitter_id > len(_emitters) - 1:
			_emitter_id = 0


func start_time_passed():
	return OS.get_ticks_msec() >= _start_time


func set_manager(manager):
	if manager is LevelManager:
		_level_manager = manager
