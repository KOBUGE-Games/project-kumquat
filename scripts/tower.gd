extends Area2D

### Variables ###

export var damage = 3

var active = false
var tile_pos = Vector2()

var tower_range = 0 # Range of the tower in tiles

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
	
	tower_range = get_node("collision_shape_2d").get_shape().get_radius() / global.TILE_SIZE
	
	var range_radius = get_node("range_indicator").get_texture().get_size().x/2
	get_node("range_indicator").set_scale(Vector2(1, 1)*global.TILE_SIZE*tower_range/range_radius)
	
	get_node("attack_timer").connect("timeout", self, "_attack")
	get_node("attack_timer").start()
	
	set_carried(false)

### Functions ###

func set_carried(carried):
	active = !carried
	tile_pos = level.tilemap.world_to_map(get_pos())
	level.tiles[tile_pos].has_tower = !carried
	get_node("sprite").set_opacity(1.0 - int(carried)*0.4)
	get_node("range_indicator").set_hidden(!carried)
	if !carried:
		get_node("sprite").set_modulate(Color(1.0, 1.0, 1.0))

### Virtual functions (to be overriden) ###

func attack():
	pass

func display_attack():
	attack_indicator.show()

func hide_attack():
	attack_indicator.hide()

### Signal handlers ###

func _attack():
	if !active:
		return
	attack()
