extends "tower_single_target.gd"

export(PackedScene) var missile_scene

var deal_damage_funcref

### Callbacks ###

func _ready():
	deal_damage_funcref = funcref(self, "deal_damage")

### Functions ###

func perform_attack():
	var direction = Vector2(0, 1).rotated(target.get_pos().angle_to_point(tower.get_pos()))
	var missile = missile_scene.instance()
	missile.setup(direction, deal_damage_funcref, reach)
	missile.set_pos(tower.get_pos())
	
	tower.level.add_child(missile)
