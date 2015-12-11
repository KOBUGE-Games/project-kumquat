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

var tower_placement = false
var carried_tower = null

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	level = global.level
	budget = get_node("stats/budget/label")
	health = get_node("stats/health/label")
	
	get_node("next_wave").connect("pressed", level, "next_wave")
	
	budget.set_text("Budget: " + str(budget_current))
	health.set_text("Health: " + str(health_current))
	
	set_process_input(true)

func _input(ev):
	if tower_placement and carried_tower and level.get_parent().get_global_rect().has_point(ev.pos):
		if ev.type == InputEvent.MOUSE_MOTION:
			var tile_pos = level.tilemap_buildable.world_to_map(ev.pos - level.get_global_pos())
			carried_tower.set_pos(level.tilemap_buildable.map_to_world(tile_pos) + global.TILE_OFFSET)
			
			if level.tiles[tile_pos].type == level.Tile.TILE_BUILDABLE and !level.tiles[tile_pos].has_tower:
				carried_tower.get_node("sprite").set_modulate(Color(0.3, 1.0, 0.4)) # Buildable, green
			else:
				carried_tower.get_node("sprite").set_modulate(Color(1.0, 0.3, 0.3)) # Non buildable, red
		
		elif ev.type == InputEvent.MOUSE_BUTTON and ev.is_pressed() and !ev.is_echo():
			if ev.button_index == BUTTON_LEFT:
				# Place a tower
				var tile_pos = level.tilemap_buildable.world_to_map(ev.pos - level.get_global_pos())
				if level.tiles[tile_pos].type == level.Tile.TILE_BUILDABLE and !level.tiles[tile_pos].has_tower:
					# Stop the tower placing behaviour and "drop" the carried tower
					tower_placement = false
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
	tower_placement = false
	carried_tower.queue_free()
	update_budget(last_transaction)

### Signals ###

func tower_build_mode(tower_scene, price):
	if tower_placement and carried_tower:
		carried_tower.free()
	
	if budget_current >= price:
		update_budget(-price)
		tower_placement = true
		carried_tower = tower_scene.instance()
		level.add_child(carried_tower)
		carried_tower.set_carried(true)
