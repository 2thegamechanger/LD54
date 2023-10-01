extends Node2D
class_name Effect


func _on_sound_finished():
	queue_free()
