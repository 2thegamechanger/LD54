extends Node
# utility functions for different purposes

func vec_clamp(v:Vector2, minimum:float = 0.0, maximum:float = 1.0):
	if v == Vector2.ZERO: return Vector2.ZERO
	var l = v.length()
	var c = clamp(l, minimum, maximum)
	return v * (c/l)
