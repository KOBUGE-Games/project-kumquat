extends "tower_single_target.gd"

export(PackedScene) var missle_scene

var deal_damage_funcref

### Callbacks ###

func _ready():
	deal_damage_funcref = funcref(self, "deal_damage")

### Functions ###

func perform_attack():
	var missle = missle_scene.instance()
	missle.set_pos(tower.get_pos())
	missle.direction = Vector2(0, 1).rotated(target.get_pos().angle_to_point(tower.get_pos()))
	missle.damage_funcref = deal_damage_funcref
	missle.distance_left = reach
	
	tower.level.add_child(missle)