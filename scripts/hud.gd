extends Control

### Variables ###

# Nodes
var global
var level
var budget
var health

var budget_current = 1000
var health_current = 1000
var last_transaction = 0
var carried_tower = null
var level_offset = Vector2()

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	level = global.level
	budget = get_node("stats/budget/label")
	health = get_node("stats/health/label")
	
	get_node("next_wave").connect("pressed", level, "next_wave")
	
	budget.set_text("Budget: " + str(budget_current))
	health.set_text("Health: " + str(health_current))
	level_offset = level.get_pos()
	
	set_process_input(true)

func _input(ev):
	if carried_tower and ev.pos.x > level_offset.x and ev.pos.x < global.LEVEL_SIZE.x \
			and ev.pos.y > level_offset.y and ev.pos.y < global.LEVEL_SIZE.y:
		if ev.type == InputEvent.MOUSE_MOTION:
			var tile_pos = level.get_node("tilemap_tower").world_to_map(ev.pos - level_offset)
			carried_tower.set_pos(level.get_node("tilemap_tower").map_to_world(tile_pos) + global.TILE_OFFSET)
			
			if level.tiles[tile_pos].type == level.Tile.TILE_BUILDABLE and !level.tiles[tile_pos].has_tower:
				carried_tower.get_node("sprite").set_modulate(Color(0.3, 1.0, 0.4)) # Buildable, green
			else:
				carried_tower.get_node("sprite").set_modulate(Color(1.0, 0.3, 0.3)) # Non buildable, red
		
		elif ev.type == InputEvent.MOUSE_BUTTON and !ev.is_echo():
			if ev.button_index == BUTTON_LEFT:
				# Place a tower
				var tile_pos = level.get_node("tilemap_tower").world_to_map(ev.pos - level_offset)
				if level.tiles[tile_pos].type == level.Tile.TILE_BUILDABLE and !level.tiles[tile_pos].has_tower:
					# Stop the tower placing behaviour and "drop" the carried tower
					carried_tower.set_carried(false)
					carried_tower = null # Stop referencing this tower in the hud
					# FIXME: Check if we want to keep it on to place several towers (tower costs have then to be updated)
			elif ev.button_index == BUTTON_RIGHT:
				# Cancel action
				cancel_tower_placement()

### Functions

func update_budget(amount):
	last_transaction = -amount
	budget_current += amount
	budget.set_text("Budget: " + str(budget_current))
	for button in get_node("tower_buttons").get_children():
		if button.tower_price > budget_current:
			button.set_disabled(true)
		else:
			button.set_disabled(false)

func update_health(amount):
	health_current += amount
	health.set_text("Health: " + str(health_current))

func cancel_tower_placement():
	carried_tower.queue_free()
	budget_current += last_transaction
	budget.set_text("Budget: " + str(budget_current))

### Signals ###

func tower_build_mode(tower_scene, price):
	if carried_tower != null: # Should not happen...
		carried_tower.free()
	
	if budget_current >= price:
		update_budget(-price)
		carried_tower = tower_scene.instance()
		level.add_child(carried_tower)
		carried_tower.set_carried(true)
