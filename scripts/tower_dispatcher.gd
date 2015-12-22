extends Area2D

### Variables ###

var active = false
var tile_pos = Vector2()
var current_tier = 0

# Nodes
var global
var level
var attack_indicator
var reach_indicator
var animation_player

var tower_tier

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	level = global.level
	attack_indicator = get_node("attack_indicator")
	animation_player = get_node("animation_player")
	reach_indicator = get_node("reach_indicator")
	
	get_node("attack_timer").connect("timeout", self, "_attack")
	get_node("attack_timer").start()
	
	connect("mouse_enter", self, "_mouse_enter")
	connect("mouse_exit", self, "_mouse_exit")
	
	set_tier(1)
	
	set_carried(false)

### Functions ###

func has_tier(tier):
	return get_node(str("tier_", tier)) != null

func set_tier(tier):
	tower_tier = get_node(str("tier_", tier))
	current_tier = tier
	
	# Pass nodes over
	tower_tier.tower = self
	
	# Update current status
	set_reach(tower_tier.reach)
	set_attack_time(1/tower_tier.frequency)
	get_node("sprite").set_frame(tier - 1)

func can_upgrade_tier():
	return has_tier(current_tier + 1)

func upgrade_tier():
	set_tier(current_tier + 1)

func set_reach(reach):
	reach = reach + 0.5
	var scale = reach * global.TILE_SIZE / get_shape(0).get_radius()
	var shape_transform = Matrix32().scaled(Vector2(scale, scale))
	
	var reach_indicator_radius = reach_indicator.get_texture().get_size().x/2
	var reach_indicator_scale = reach * global.TILE_SIZE / reach_indicator_radius
	reach_indicator.set_scale(Vector2(reach_indicator_scale, reach_indicator_scale))
	
	set_shape_transform(0, shape_transform)

func set_attack_time(time):
	get_node("attack_timer").set_wait_time(time)

func set_carried(carried):
	active = !carried
	tile_pos = level.tilemap.world_to_map(get_pos())
	get_node("sprite").set_opacity(1.0 - int(carried)*0.4)
	set_show_info(carried)
	
	if !carried:
		get_node("sprite").set_modulate(Color(1.0, 1.0, 1.0))
		level.tiles[tile_pos].has_tower = true

func set_show_info(show_info):
	reach_indicator.set_hidden(!show_info)

### Signal handlers ###

func _mouse_enter():
	set_show_info(true)

func _mouse_exit():
	set_show_info(false)

func _attack():
	if !active:
		return
	
	tower_tier.attack()
