extends "tower.gd"

### Variables ###

var target = null

### Callbacks ###

func _ready():
	pass

### Functions ###

func attack():
	var enemies = get_overlapping_areas()
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
	target.hp -= damage

func pick_target(enemies):
	var min_squared_distance = null
	for enemy in enemies:
		if enemy.get("hp"):
			var distance = enemy.get_pos().distance_squared_to(get_pos())
			if min_squared_distance == null or distance < min_squared_distance:
				target = enemy
				min_squared_distance = distance

func keep_target():
	return true

func display_attack():
	attack_indicator.set_rot(target.get_pos().angle_to_point(get_pos()))
	attack_indicator.show()
	animation_player.play("attack")

func hide_attack():
	attack_indicator.hide()
