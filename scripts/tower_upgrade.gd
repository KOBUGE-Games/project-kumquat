
extends Node2D

### Variables ###

var placed = false
var tile_pos = Vector2()
var current_tier = 0

# Nodes
var global
var level

func _ready():
	global = get_node("/root/global")
	level = global.level
	# animation_player = get_node("animation_player")

func set_carried(carried):
	placed = !carried
	tile_pos = level.tilemap.world_to_map(get_pos())
	get_node("sprite").set_opacity(1.0 - int(carried)*0.4)
	
	if !carried:
		get_node("sprite").set_modulate(Color(1.0, 1.0, 1.0))
		level.tiles[tile_pos].tower.upgrade_tier()
		queue_free()

func update_status(tile_type, tile_tower):
	if can_place(tile_type, tile_tower):
		get_node("sprite").set_modulate(Color(0.3, 1.0, 0.4)) # Buildable, green
	else:
		get_node("sprite").set_modulate(Color(1.0, 0.3, 0.3)) # Non buildable, red

func can_place(tile_type, tile_tower):
	return tile_type == level.Tile.TILE_BUILDABLE and tile_tower != null and tile_tower.can_upgrade_tier()

