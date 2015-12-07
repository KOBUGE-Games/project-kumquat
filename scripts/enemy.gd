
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
const TILE_SIZE = 32
const TILE_OFFSET = Vector2(TILE_SIZE/2, TILE_SIZE/2)

# Nodes
var level  # The level node
var tilemap  # The level's tilemap

# Member variables
var cur_tile  # Our current position in tilemap coordinates
var dest_tile  # The tile we are moving to
var motion_dir = Vector2()  # The current direction we move in
var old_motion_dir = Vector2()  # Previous motion dir, saved for animation

export var type = "enemy1"  # Enemy type
export var speed = 2.0  # tiles/second
export var hp = 100  # health points
export var damage = 10 # the damage which it gives when reaches the dest

### Callbacks ###

func _ready():
	level = get_node("/root/game/level")
	tilemap = level.get_node("tilemap_grass")
	
	cur_tile = tilemap.world_to_map(get_pos())
	dest_tile = cur_tile
	
	set_fixed_process(true)

func _fixed_process(delta):
	# Handle potential death
	if (hp <= 0):
		# Stop walking
		set_fixed_process(false)
		get_node("animation_player").play("die")
		return
	
	# Handle movement
	cur_tile = tilemap.world_to_map(get_pos() - motion_dir*TILE_OFFSET)
	
	# Update target coordinates
	if (cur_tile == dest_tile):
		# Intermediate target tile reached, find the next destination
		var goal_dirs = level.tiles[cur_tile].goal_directions
		if (goal_dirs.size() == 0):
			# Dead-end, assuming it's the goal
			set_fixed_process(false)
			get_node("animation_player").stop()
			# FIXME: Do stuff
			get_node("/root/game/hud").updateHealth(-damage)
			return
		
		var index = randi() % goal_dirs.size()
		dest_tile = cur_tile + goal_dirs[index]
		old_motion_dir = motion_dir
		motion_dir = dest_tile - cur_tile
		
		# Update walk animation
		if (motion_dir != old_motion_dir):
			get_node("animation_player").play(WALK_ANIMS[motion_dir])
	
	# Move now
	var motion = motion_dir*speed*TILE_SIZE*delta
	set_pos(get_pos() + motion)

### Signals ###

func _on_AnimationPlayer_finished():
	if (get_node("animation_player").get_current_animation() == "die"):
		# We just finished playing the death animation, so free the object
		queue_free()
