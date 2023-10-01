extends Node
# this is a preloaded scene containing all enums/data types for the game

enum my_enum {
	NONE,
	ONE,
	DONE
}

enum bullet_pattern {
	NONE,
	RANDOM,
	CIRCLE,
}

enum bullet_dispension {
	NONE,
	BURST,
	CHAIN
}

enum bullet_modifier {
	NONE,
	ROTATE,
	PERISTALSIS,
	WAVE
}

enum entry_type {
	NONE,
	SPAWN,
	STRAIGHT,
	CURVED
}

enum movement_type {
	NONE,
	STATIONARY,
	WAVE,
	CIRCULAR
}

enum ship_state {
	NONE,
	ENTRY,
	EMISSION,
	PAUSE,
	DEATH
}

enum emitter_state {
	NONE,
	WARMUP,
	EMISSION,
	COOLDOWN,
	PAUSE
}
