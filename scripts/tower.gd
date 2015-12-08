extends Area2D

### Variables ###

export var damage = 3

var target = null
var tile_pos = Vector2()

# Nodes
var global
var level
var attack_indicator
var animation_player

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	level = global.level
	attack_indicator = get_node("attack_indicator")
	animation_player = get_node("animation_player")
	
	get_node("attack_timer").connect("timeout", self, "attack")
	get_node("attack_timer").start()
	
	tile_pos = level.get_node("tilemap_tower").world_to_map(get_pos())
	level.tiles[tile_pos].has_tower = true

### Functions ###

func attack():
	var enemies = get_overlapping_areas()
	if target == null or not (target in enemies) or target.hp <= 0:
		target = null
		var min_squared_distance = null
		for enemy in enemies:
			if enemy.get("hp"):
				var distance = enemy.get_pos().distance_squared_to(get_pos())
				if min_squared_distance == null or distance < min_squared_distance:
					target = enemy
					min_squared_distance = distance
	
	if target != null:
		target.hp -= damage
		attack_indicator.set_scale(Vector2(attack_indicator.get_scale().x, target.get_pos().distance_to(get_pos())/global.TILE_SIZE))
		attack_indicator.set_rot(target.get_pos().angle_to_point(get_pos()))
		attack_indicator.show()
		animation_player.play("attack")
	else:
		attack_indicator.hide()
