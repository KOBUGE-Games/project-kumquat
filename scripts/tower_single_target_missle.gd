extends "tower_single_target.gd"

export(PackedScene) var missle_scene


### Callbacks ###

func _ready():
	pass

### Functions ###

func perform_attack():
	var missle = missle_scene.instance()
	missle.set_pos(get_pos())
	missle.direction = Vector2(0, 1).rotated(target.get_pos().angle_to_point(get_pos()))
	missle.damage = damage
	missle.distance_left = tower_range
	
	level.add_child(missle)