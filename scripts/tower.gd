
extends Area2D

export var damage = 3

var target = null
var attack_indicator
var animation_player

func _ready():
	get_node("attack_timer").connect("timeout", self, "attack")
	get_node("attack_timer").start()
	
	attack_indicator = get_node("attack_indicator")
	animation_player = get_node("AnimationPlayer")

func attack():
	var enemies = get_overlapping_areas()
	if target == null or not ( target in enemies ) or target.hp <= 0:
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
		attack_indicator.set_scale(Vector2(attack_indicator.get_scale().x, target.get_pos().distance_to(get_pos()) / 32))
		attack_indicator.set_rot(target.get_pos().angle_to_point(get_pos()))
		attack_indicator.show()
		animation_player.play("attack")
	else:
		attack_indicator.hide()
