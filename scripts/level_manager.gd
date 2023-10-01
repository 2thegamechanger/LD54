extends Node2D
class_name LevelManager

export var required_energy = 10000
export(Array, PackedScene) var levels = []
onready var player = $ship
onready var bars_bg = $ui/energy_bar
onready var bars = [$ui/energy_bar/energy_left, $ui/energy_bar/energy_right]
onready var ui = $ui
onready var score_text = $ui/score_over
onready var score_text2 = $ui/score_under
onready var multi_text = $ui/multi_over
onready var multi_text2 = $ui/multi_under
onready var fscore_text = $ui/fscore_over
onready var fscore_text2 = $ui/fscore_under
onready var go_text = $ui/game_over
onready var go_text2 = $ui/game_under


var _score = 0
var _energy_since_last_hit = 0.0
var _current_energy = 0.0
var _stacked_multiplier = 0.0
var _level_multiplier = 0.0
var _current_multiplier = 0.0
var _current_level:Level = null
var _current_level_id = 0
#var _music_volume = 0
#var _arpeggio_volume = -50
#var _highpass_value = 25

func _ready():
	for b in bars: b.rect_scale.x = 0
	spawn_level()
	score_text.visible = false
	score_text2.visible = false
	multi_text.visible = false
	multi_text2.visible = false
	fscore_text.visible = false
	fscore_text2.visible = false
	go_text.visible = false
	go_text2.visible = false


func update_score():
	# TODO: add separator
	var num_str = "%015d" % _score
	var formatted_str = ""
	var count = 0

	if _current_level_id >= 3:
		score_text.visible = true
		score_text2.visible = true
		multi_text.visible = true
		multi_text2.visible = true
		
	if _current_level_id >= 15:
		fscore_text.visible = true
		fscore_text2.visible = true
		go_text.visible = true
		go_text2.visible = true
		score_text.visible = false
		score_text2.visible = false
		multi_text.visible = false
		multi_text2.visible = false
		bars_bg.visible = false
		bars[0].visible = false
		bars[1].visible = false
		

	for i in range(num_str.length() - 1, -1, -1):
		count += 1
		formatted_str = num_str[i] + formatted_str
		if count % 3 == 0 and i != 0:
			formatted_str = "'" + formatted_str
	
	var formatted_mul = ""
	if _current_multiplier > 1.0:
		formatted_mul =  "X%s" % [str(_current_multiplier)]
	
	score_text.text = formatted_str
	score_text2.text = formatted_str
	fscore_text.text = formatted_str
	fscore_text2.text = formatted_str
	multi_text.text = formatted_mul
	multi_text2.text = formatted_mul


func update_bars():
	for b in bars:
			b.rect_scale.x = clamp(_current_energy / required_energy, 0, 1)
	


func spawn_level(id = _current_level_id):
	if len(levels) == 0: return
	if id < 0 or id >= len(levels): return
	if _current_level: return
	
	var l = levels[id].instance() as Level
	add_child(l)
	l.position = position
	_current_level = l
	required_energy = l.energy_required
	_stacked_multiplier += _level_multiplier
	_level_multiplier = 0.0
	_current_energy = 0.0
	_current_multiplier = _level_multiplier + _stacked_multiplier + 1.0
	update_bars()
	update_score()


func finish_level():
	if _current_level:
		_current_level.queue_free()
		#TODO: spawn enemy debree + effect
		_current_level_id += 1
		_current_level = null
		spawn_level()


func _on_ship_add_points(value):
	if not value: return
	
	if _current_energy >= required_energy:
		finish_level()
	else:
		_current_energy += value
		_energy_since_last_hit += value
		
		var eslh = _energy_since_last_hit
		var re = required_energy
		_level_multiplier = round((eslh / re) * 10.0) / 10.0
		_current_multiplier = _level_multiplier + _stacked_multiplier + 1.0
		
		_score += value * _current_multiplier
	update_score()
	update_bars()
#	update_music()


#func update_music():
#	var value = clamp(_current_energy / required_energy, 0, 1)
#	var _highpass_value = AudioServer.get_bus_effect(1,0)
#	highpass.cutoff_hz = pow(value * 10, 2.7) + 25
#	buzz.volume_db = _buzz_volume


func _on_ship_got_hit():
	var ohepip = Settings.ON_HIT_ENERGY_PENALTY_IN_PERCENT
	_energy_since_last_hit = 0.0
	_current_multiplier = 0.0
	_stacked_multiplier = 0.0
	_current_energy = max(_current_energy - required_energy * ohepip, 0.0)
