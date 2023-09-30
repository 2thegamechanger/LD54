extends Node2D

export(float, 0, 180) var random_angle_in_degree = 0.0
export(float, 0.1, 5) var spawn_interval = 1.0
export(PackedScene) var bullet_scene = null

var _bullet = null
var _next_spawn_time = 0

func _ready():
	_next_spawn_time = spawn_interval * Engine.iterations_per_second + OS.get_ticks_msec()
	_bullet = bullet_scene


func _physics_process(delta):
	if _bullet and OS.get_ticks_msec() >= _next_spawn_time:
		#print("frame difference is ",OS.get_ticks_msec() - _next_spawn_time, "frames")
		# TODO: Handle frame difference in bullet spawn
		var b = _bullet.instance()
		get_tree().root.add_child(b)
		_next_spawn_time += spawn_interval * Engine.iterations_per_second * 20
