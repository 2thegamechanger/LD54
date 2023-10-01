extends Node2D


export(float, 0.1, 5) var spawn_interval_in_seconds = 1.0
export(float, 1.0, 500.0) var bullet_speed = 200.0
export(float, 0.0, 1.0) var bullet_speed_deviation_in_percent = 0.0
export(float, 0.0, 180.0) var angle_deviation_in_degree = 0.0
export(PackedScene) var bullet_scene = null

var _bullet = null
var _interval = 0
var _next_spawn_time = 0

func _ready():
	_next_spawn_time = _interval * Engine.iterations_per_second + OS.get_ticks_msec()
	_bullet = bullet_scene
	_interval = spawn_interval_in_seconds


func _physics_process(delta):
	if _bullet and OS.get_ticks_msec() >= _next_spawn_time:
		#print("frame difference is ",OS.get_ticks_msec() - _next_spawn_time, "frames")
		# TODO: Handle frame difference in bullet spawn
		var b = _bullet.instance() as Bullet
		b.velocity = bullet_speed * rand_range(1.0 - bullet_speed_deviation_in_percent, 1.0)
		get_tree().root.add_child(b)
		b.position = global_position
		b.set_direction(Vector2.UP) # TODO: CONTINUE HERE!
		b.change_direction(deg2rad(rand_range(-1, 1) * angle_deviation_in_degree))
	
		# TODO: add rotation in world space
		_next_spawn_time += _interval * Engine.iterations_per_second * 20
