extends "tower_single_target.gd"

### Callbacks ###

func _ready():
	pass

### Functions ###

func display_attack():
	attack_indicator.set_scale(Vector2(attack_indicator.get_scale().x, target.get_pos().distance_to(get_pos()) / global.TILE_SIZE))
	attack_indicator.set_rot(target.get_pos().angle_to_point(get_pos()))
	get_node("rotator").set_rot(target.get_pos().angle_to_point(get_pos()))

	attack_indicator.show()
	animation_player.play("attack")

