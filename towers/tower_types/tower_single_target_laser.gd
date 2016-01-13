extends "tower_single_target.gd"

### Callbacks ###

func _ready():
	pass

### Functions ###

func display_attack():
	if show_attack_indicator:
		var attack_indicator = tower.attack_indicator
		
		var scale_y = target.get_pos().distance_to(tower.get_pos()) / tower.global.TILE_SIZE
		attack_indicator.set_scale(Vector2(attack_indicator.get_scale().x, scale_y))
		
		attack_indicator.set_rot(target.get_pos().angle_to_point(tower.get_pos()))
	
		attack_indicator.show()
	tower.animation_player.play("attack")

