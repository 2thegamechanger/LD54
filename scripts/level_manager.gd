extends Node2D
class_name LevelManager

export var required_energy = 10000
onready var player = $ship
onready var bars = [$ui/energy_bar/energy_left, $ui/energy_bar/energy_right]
onready var ui = $ui
onready var score_text = $ui/score
var _score = 0
var _energy_since_last_hit = 0.0
var _current_energy = 0.0
var _stacked_multiplier = 0.0
var _level_multiplier = 0.0
var _current_multiplier


func _ready():
	for b in bars: b.rect_scale.x = 0


func update_score():
	# TODO: add separator
	var num_str = "%015d" % _score
	var formatted_str = ""
	var count = 0

	for i in range(num_str.length() - 1, -1, -1):
		count += 1
		formatted_str = num_str[i] + formatted_str
		if count % 3 == 0 and i != 0:
			formatted_str = "'" + formatted_str
			
	if _current_multiplier > 1.0:
		formatted_str +=  " x %s" % [str(_current_multiplier)]
	
	score_text.text = formatted_str
	

func _on_ship_add_points(value):
	if not value: return
	
	_current_energy += value
	_energy_since_last_hit += value
	for b in bars:
		b.rect_scale.x = clamp(_current_energy / required_energy, 0, 1)
	
	var eslh = _energy_since_last_hit
	var re = required_energy
	_level_multiplier = round((eslh / re) * 10.0) / 10.0
	_current_multiplier = _level_multiplier + _stacked_multiplier + 1.0
	
	_score += value * _current_multiplier
	update_score()


func _on_ship_got_hit():
	var ohepip = Settings.ON_HIT_ENERGY_PENALTY_IN_PERCENT
	_energy_since_last_hit = 0.0
	_current_multiplier = 0.0
	_stacked_multiplier = 0.0
	_current_energy = max(_current_energy - required_energy * ohepip, 0.0)
