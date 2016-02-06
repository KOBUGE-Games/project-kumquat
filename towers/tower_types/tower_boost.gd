extends "tower_base.gd"

### Variables ###

export var reach_add = 0.0
export var frequency_add = 0.0
export var damage_add = 0

var towers = []

### Callbacks ###

func _ready():
	pass

### Functions ###

func attack():
	var possible_towers = tower.get_overlapping_bodies()
	towers = []
	for bounding_box in possible_towers:
		var tower = bounding_box.get_parent()
		if tower extends preload("res://towers/tower_dispatcher.gd"):
			if tower.active and !tower.tower_tier extends get_script():
				towers.push_back(tower)
	
	if towers.size() > 0:
		perform_attack()
		display_attack()
	else:
		hide_attack()

### Virtual functions (might be overriden) ###

func perform_attack():
	for tower in towers:
		tower.set_boosts(reach_add, frequency_add, damage_add, 1/(tower.frequency_add + frequency) + 0.1)

func display_attack():
	if show_attack_indicator:
		tower.attack_indicator.show()
	else:
		tower.attack_indicator.hide()
	
	tower.animation_player.play("attack")
