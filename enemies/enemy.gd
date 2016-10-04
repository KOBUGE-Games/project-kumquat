extends Node2D

### Variables ###

# Constants
const WALK_ANIMS = {
	Vector2(0, 1): "walk_down",
	Vector2(0, -1): "walk_up",
	Vector2(1, 0): "walk_right",
	Vector2(-1, 0): "walk_left"
}

# Nodes
var global # The global autoload
var level # The level node
var tilemap # The level's tilemap

# Member variables
var cur_tile # Our current position in tilemap coordinates
var dest_tile # The tile we are moving to
var motion_dir = Vector2() # The current direction we move in
var old_motion_dir = Vector2() # Previous motion dir, saved for animation
var passed = {}

export var type = "enemy1" # Enemy type
export var speed = 2.0 # pixels/second
export var hp = 100 # health points
export var damage = 10 # the damage which it gives when reaches the dest
export var worth = 25 # the amount of money given to player after enemies death

var speed_multiplier = 1
var speed_multiplier_reset = 0

var maxhp = 0

var poison_damage = 0
var poison_duration = 0

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	level = global.level
	tilemap = level.tilemap
	
	cur_tile = tilemap.world_to_map(get_pos())
	dest_tile = cur_tile
	
	get_node("movement_anim").connect("finished", self, "_on_movement_anim_finished")
	get_node("effect_timer").connect("timeout", self, "_on_effect_timer_timeout")
	
	maxhp = hp
	
	set_fixed_process(true)

func _fixed_process(delta):
	# Handle potential death
	if hp <= 0:
		#Health bar to zero
		get_node("healthbar").hide()
		# Stop walking
		set_fixed_process(false)
		get_node("movement_anim").play("die")
		global.hud.update_budget(worth)
		return
	
	#Show health bar only when damaged, set to current health fraction
	if hp < maxhp:
		get_node("healthbar").show()
		get_node("healthbarbgd").show()
		get_node("healthbar").set_scale(Vector2(hp/(1.0*maxhp), 0.5))
	
	# Handle slowness
	speed_multiplier_reset -= delta
	if speed_multiplier_reset < 0:
		speed_multiplier = 1
	
	# Handle movement
	cur_tile = tilemap.world_to_map(get_pos() - motion_dir*global.TILE_OFFSET)
	
	# Update target coordinates
	if cur_tile == dest_tile:
		passed[cur_tile] = true
		# Intermediate target tile reached, find the next destination
		var directions = level.tiles[cur_tile].possible_directions
		if level.tiles[cur_tile].goal:
			set_fixed_process(false)
			get_node("movement_anim").stop()
			get_node("effect_anim").stop()
			global.hud.update_health(-damage)
			queue_free()
			return
		
		var total_weight = 0
		var weights = {}
		
		for direction in directions:
			weights[direction] = level.tiles[cur_tile].goal_direction_weigths[direction]
			weights[direction] += (2 / speed) * level.tiles[cur_tile].goal_direction_focused_weigths[direction]
			weights[direction] *= (direction.dot(motion_dir) + 1) / 2
			if passed.has(cur_tile + direction):
				weights[direction] *= 0.1
			weights[direction] += 0.01 # Small bias just in case
			total_weight += weights[direction]
		
		var selected = randf()
		
		for direction in directions:
			selected -= weights[direction] / total_weight
			if selected <= 0.001:
				dest_tile = cur_tile + direction
				selected = -1
				break
		
		if selected > 0:
			dest_tile = cur_tile + directions[directions.size() - 1]
		
		old_motion_dir = motion_dir
		motion_dir = dest_tile - cur_tile
		
		# Update walk animation
		if motion_dir != old_motion_dir:
			get_node("movement_anim").play(WALK_ANIMS[motion_dir])
	
	# Update animation speed
	get_node("movement_anim").set_speed(speed_multiplier)
	
	# Move now
	var motion = motion_dir*speed*speed_multiplier*global.TILE_SIZE*delta
	set_pos(get_pos() + motion)

### Functions ###

func take_damage(damage):
	hp -= damage
	global.hud.add_damage(damage)
	# Play hurt anim unless already playing poisoned anim
	if not poison_duration > 0:
		get_node("effect_anim").play("hurt")

func set_poisoned(damage, duration):
	poison_damage = damage
	poison_duration = duration
	get_node("effect_timer").start()
	get_node("effect_anim").get_animation("poison").set_loop(true)
	get_node("effect_anim").play("poison")

### Signals ###

func _on_movement_anim_finished():
	if get_node("movement_anim").get_current_animation() == "die":
		# We just finished playing the death animation, so free the object
		queue_free()

func _on_effect_timer_timeout():
	poison_duration -= get_node("effect_timer").get_wait_time()
	if poison_duration > 0:
		take_damage(poison_damage)
		get_node("effect_timer").start()
	else:
		# Disable looping so that the last animation plays and the effect goes back to normal
		get_node("effect_anim").get_animation("poison").set_loop(false)
