extends Control

### Variables ###

# Nodes
var global
var level
var budget
var health

export var budget_current = 1000
export var health_current = 1000
var pending_transaction = 0

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
	if tower_placement and carried_tower:
		if ev.type == InputEvent.MOUSE_MOTION:
			var tile_pos = level.tilemap.world_to_map(ev.pos - level.get_global_pos())
			carried_tower.set_pos(level.tilemap.map_to_world(tile_pos) + global.TILE_OFFSET + Vector2(0,-8))
			
			if level.tiles.has(tile_pos):
				carried_tower.update_status(level.tiles[tile_pos].type, level.tiles[tile_pos].tower)
			else:
				carried_tower.update_status(level.Tile.TILE_SOLID, null)
		
		elif ev.type == InputEvent.MOUSE_BUTTON and ev.is_pressed() and !ev.is_echo():
			if ev.button_index == BUTTON_LEFT:
				# Place an instance of the carried tower
				var tile_pos = level.tilemap.world_to_map(ev.pos - level.get_global_pos())
				if level.tiles.has(tile_pos) and carried_tower.can_place(level.tiles[tile_pos].type, level.tiles[tile_pos].tower) \
						and budget_current + pending_transaction >= 0:
					# Place the carried tower
					update_budget(pending_transaction)
					var placed_tower = carried_tower.duplicate()
					level.add_child(placed_tower)
					placed_tower.set_carried(false)
			elif ev.button_index == BUTTON_RIGHT:
				# Cancel the pending placement and discard the carried tower
				cancel_tower_placement()

### Functions

func update_budget(amount):
	budget_current += amount
	budget.set_text("Budget: " + str(budget_current))
	for button in get_node("tower_buttons").get_children():
		if (button.get('tower_price') and button.tower_price > budget_current) or \
				(button.get('upgrade_price') and button.upgrade_price > budget_current):
			button.set_disabled(true)
		else:
			button.set_disabled(false)

func update_health(amount):
	health_current += amount
	health.set_text("Health: " + str(health_current))

func cancel_tower_placement():
	tower_placement = false
	pending_transaction = 0
	carried_tower.queue_free()

### Signals ###

func tower_build_mode(tower_scene, price):
	if tower_placement and carried_tower:
		carried_tower.free()
	
	if budget_current >= price:
		tower_placement = true
		pending_transaction = -price
		carried_tower = tower_scene.instance()
		level.add_child(carried_tower)
		carried_tower.set_pos(Vector2(48, 48))
		carried_tower.set_carried(true)

func tower_upgrade_mode(upgrade_scene, price):
	if tower_placement and carried_tower:
		carried_tower.free()
	
	if budget_current >= price:
		tower_placement = true
		pending_transaction = -price
		carried_tower = upgrade_scene.instance()
		level.add_child(carried_tower)
		carried_tower.set_pos(Vector2(48, 48))
		carried_tower.set_carried(true)
