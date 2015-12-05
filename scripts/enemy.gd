
extends Node2D

### Variables ###

# Constants
const WALK_ANIMS = {
	Vector2(0, 1): "walk_down",
	Vector2(0, -1): "walk_up",
	Vector2(1, 0): "walk_right",
	Vector2(-1, 0): "walk_left"
}

# FIXME: Move me to level scene or something
const TILE_SIZE = 64

# Nodes
var level  # The level node
var tilemap  # The level's tilemap

# Member variables
var cur_tile  # Our current position in tilemap coordinates
var dest_tile  # The tile we are moving to
var motion_dir = Vector2()  # The current direction we move in
var old_motion_dir = Vector2()  # Previous motion dir, saved for animation

export var type = "enemy1"  # Enemy type
export var speed = 1.0  # tiles/second
export var hp = 100  # health points

### Callbacks ###

func _ready():
	level = get_node("/root/Game/Level")
	tilemap = level.get_node("tilemap_grass")
	
	cur_tile = tilemap.world_to_map(get_pos())
	dest_tile = cur_tile
	
	set_fixed_process(true)

func _fixed_process(delta):
	# Handle potential death
	if (hp <= 0):
		# Stop walking
		set_fixed_process(false)
		# FIXME: add die animation
		#get_node("AnimationPlayer").play("die")
		return
	
	cur_tile = tilemap.world_to_map(get_pos())
	
	# Handle movement
	
	# Update target coordinates
	if (cur_tile == dest_tile):
		# Target tile reached, find the next destination
		var goal_dirs = level.tiles[cur_tile].goal_directions
		var index = randi() % goal_dirs.size()
		dest_tile = cur_tile + goal_dirs[index]
		old_motion_dir = motion_dir
		motion_dir = dest_tile - cur_tile
	
	# Update walk animation
	if (motion_dir != old_motion_dir):
		get_node("AnimationPlayer").play(WALK_ANIMS[motion_dir])
	
	# Move now
	var motion = motion_dir*speed*TILE_SIZE*delta
	set_pos(get_pos() + motion)

### Signals ###

func _on_AnimationPlayer_finished():
	if (get_node("AnimationPlayer").get_current_animation() == "die"):
		# We just finished playing the death animation, so free the object
		queue_free()
