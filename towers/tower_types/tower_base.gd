extends Node

### Constants ###

const DAMAGE_DIRECT = 0
const DAMAGE_SLOW = 1
const DAMAGE_POISON = 2

### Variables ###

export var damage = 1
export var damage_duration = 1.0 # Valid only for Slow and Poison
export(int, "Direct", "Slow", "Poison") var damage_type = 0
export var frequency = 1.0
export var reach = 4.0
export var name = "Unnamed"
export var price = 100
export var show_attack_indicator = true

var tower # Tower dispatcher node

### Callbacks ###

func _ready():
	pass

### Utility functions ###

func deal_damage(target):
	if damage_type == DAMAGE_DIRECT:
		target.hp -= damage
		tower.global.hud.add_damage(damage)
	elif damage_type == DAMAGE_SLOW:
		target.speed_multiplier = min(target.speed_multiplier, 1/float(damage))
		target.speed_multiplier_reset = max(target.speed_multiplier_reset, damage_duration)

### Virtual functions (to be overriden) ###

func attack():
	pass

func display_attack():
	if show_attack_indicator:
		tower.attack_indicator.show()

func hide_attack():
	tower.attack_indicator.hide()
