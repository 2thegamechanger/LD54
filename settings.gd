extends Node
# this is a preloaded file containing all settings for the game

const MY_SETTING = "very nice"

const INPUT_USE_KEYS = true
const INPUT_USE_CONTROLLER = true
const INPUT_USE_MOUSE = false

const PLAYER_MAX_SPEED = 300
const PLAYER_VELOCITY_ATTACK = 12
const PLAYER_VELOCITY_DECAY = 1

const BORDER_PUSH_FORCE = 1.5 # times PLAYER_MAX_SPEED
const BORDER_PUSH_EXPONENT = 1.5
const BORDER_PUSH_DISTANCE = 0.2 # in percent of screen height

const COLOR_BULLET_COOL = Color("fb0000")
const COLOR_BULLET_HOT = Color("ffedb5")
const COLOR_PLAYER_COOL = Color("1a83ff")
const COLOR_PLAYER_HOT = Color("afffff")

const POINT_EXPONENT = 2
const ON_HIT_ENERGY_PENALTY_IN_PERCENT = 0.2
