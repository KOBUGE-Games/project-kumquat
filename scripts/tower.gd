extends Node

### Variables ###

export var damage = 1
export var frequency = 1.0
export var reach = 4.0

var tower # Tower dispatcher node

### Callbacks ###

func _ready():
	pass

### Virtual functions (to be overriden) ###

func attack():
	pass

func display_attack():
	tower.attack_indicator.show()

func hide_attack():
	tower.attack_indicator.hide()
