extends "tower_base.gd"

### Variables ###

var enemies = []

### Callbacks ###

func _ready():
	pass

### Functions ###

func attack():
	var possible_enemies = tower.get_overlapping_areas()
	enemies = []
	for enemy in possible_enemies:
		if enemy.get("hp"):
			enemies.push_back(enemy)
	
	if enemies.size() > 0:
		perform_attack()
		display_attack()
	else:
		hide_attack()

### Virtual functions (to be overriden) ###

func perform_attack():
	for enemy in enemies:
		if enemy.get("hp"):
			deal_damage(enemy)

func display_attack():
	if show_attack_indicator:
		tower.attack_indicator.show()
	else:
		tower.attack_indicator.hide()
	
	tower.animation_player.play("attack")
