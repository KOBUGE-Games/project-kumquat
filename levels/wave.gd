
extends Node

export(Array) var starts_open
export(float) var total_time
var enemies = []
var starts_open_positions = []

func _ready():
	for child in get_children():
		if child extends preload("wave_enemy.gd"):
			enemies.push_back(child)
	for i in range(starts_open.size()):
		starts_open[i] = get_node(starts_open[i])
		starts_open_positions.push_back(starts_open[i].get_pos())
