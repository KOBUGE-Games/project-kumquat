extends "tower_base.gd"

### Variables ###

var target = null

### Callbacks ###

func _ready():
	pass

### Functions ###

func attack():
	var enemies = tower.get_overlapping_areas()
	if (target == null or not keep_target()) or not (target in enemies) or not target.get("hp") or target.hp <= 0:
		target = null
		pick_target(enemies)
	
	if target != null:
		perform_attack()
		display_attack()
	else:
		hide_attack()

### Virtual functions (to be overriden) ###

func perform_attack():
	deal_damage(target)

func pick_target(enemies):
	if damage_type == DAMAGE_DIRECT:
		var min_squared_distance = null
		for enemy in enemies:
			if enemy.get("hp"):
				var distance = enemy.get_pos().distance_squared_to(tower.get_pos())
				if min_squared_distance == null or distance < min_squared_distance:
					target = enemy
					min_squared_distance = distance
	elif damage_type == DAMAGE_SLOW:
		var min_squared_distance = null
		var min_duration = null
		for enemy in enemies:
			if enemy.get("hp"):
				var distance = enemy.get_pos().distance_squared_to(tower.get_pos())
				var duration = enemy.speed_multiplier_reset
				if min_duration == null or min_squared_distance == null or duration < min_duration or (distance < min_squared_distance and duration == min_duration):
					target = enemy
					min_squared_distance = distance
					min_duration = duration

func keep_target():
	return damage_type == DAMAGE_DIRECT

func display_attack():
	if show_attack_indicator:
		tower.attack_indicator.set_rot(target.get_pos().angle_to_point(tower.get_pos()))
		tower.attack_indicator.show()
	else:
		tower.attack_indicator.hide()
		
	
	tower.animation_player.play("attack")
