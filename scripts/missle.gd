extends Area2D

### Variables ###

export var speed = 2.0 # Speed in tiles/second

var exploded = false

# Set by the tower class
var direction = Vector2()
var damage = 1.0
var distance_left = 1.0

# Nodes
var global

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	
	get_node("animation_player").connect("finished", self, "_on_animation_player_finished")
	
	set_fixed_process(true)

func _fixed_process(delta):
	if not exploded:
		# Check if we have to explode
		var enemies = get_overlapping_areas()
		for enemy in enemies:
			if enemy.get("hp"):
				distance_left = min(distance_left, 0.2)
				break
		
		# Explode when no distance is left
		distance_left -= (direction*speed*delta).length()
		if distance_left <= 0:
			explode(enemies)
		
		# Handle movement
		var motion = direction*speed*global.TILE_SIZE*delta
		set_pos(get_pos() + motion)

### Functions ###

func explode(enemies):
	exploded = true # Mark the missle as exploded, so it won't explode again
	
	# Decrease health
	for enemy in enemies:
		if enemy.get("hp"):
			enemy.hp -= damage
	
	# Play animation
	get_node("animation_player").play("explode")

### Signals ###

func _on_animation_player_finished():
	if get_node("animation_player").get_current_animation() == "explode":
		# We just finished playing the explode animation, so free the object
		queue_free()
	