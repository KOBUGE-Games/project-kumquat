extends Control

### Variables ###

# Consts
const TILE_SIZE = 32 # FIXME , get it from level node
const LEVEL_SIZE = Vector2(22*TILE_SIZE, 18*TILE_SIZE) # FIXME tile counts * tile size

# Nodes
var level
var budget
var health
var tower_desc

var budget_current = 1000
var health_current = 1000
var last_transaction = 0
var placeTower = false
var level_offset = Vector2()

# Packed scens
var tower_scene = preload("res://scenes/towers/tower1.xscn")

### Callbacks ###

func _ready():
	level = get_node("/root/Game/Level")
	budget = get_node("Budget")
	health = get_node("health_label")
	tower_desc = get_node("Tower_desc")
	
	budget.set_text("Budget: " + str(budget_current))
	health.set_text("Health: " + str(health_current))
	tower_desc.hide()
	level_offset = level.get_pos()
	
	set_process_input(true)

func updateBudget(amount):
	last_transaction = -amount
	budget_current += amount
	budget.set_text("Budget: " + str(budget_current))
	for button in get_node("Towers").get_children():
		if button.tower_price > budget_current:
			button.set_disabled(true)
		else:
			button.set_disabled(false)

func updateHealth(amount):
	health_current += amount
	health.set_text("Health: " + str(health_current))

func _input(ev):
	if (placeTower and ev.pos.x > level_offset.x and ev.pos.x < LEVEL_SIZE.x
			and ev.pos.y > level_offset.y and ev.pos.y < LEVEL_SIZE.y):
		if (ev.type == InputEvent.MOUSE_MOTION):
			get_node("cursor_placeholder").set_pos(ev.pos)
			
			var tile_pos = level.get_node("tilemap_tower").world_to_map(ev.pos-level_offset)
			if (level.tiles[tile_pos].type == level.Tile.TILE_BUILDABLE and !level.tiles[tile_pos].has_tower):
				get_node("cursor_placeholder").set_frame(1)
			else:
				get_node("cursor_placeholder").set_frame(0)
		
		elif (ev.type == InputEvent.MOUSE_BUTTON and !ev.is_echo()):
			if (ev.button_index == BUTTON_LEFT):
				# Place a tower
				var tile_pos = level.get_node("tilemap_tower").world_to_map(ev.pos-level_offset)
				if (level.tiles[tile_pos].type == level.Tile.TILE_BUILDABLE and !level.tiles[tile_pos].has_tower):
					var new_tower = tower_scene.instance()
					new_tower.set_pos(level.get_node("tilemap_tower").map_to_world(tile_pos) + Vector2(0.5, 0.5)*TILE_SIZE)
					level.add_child(new_tower)
					# Stop the tower placing behaviour
					# FIXME: Check if we want to keep it on to place several towers (tower costs have then to be updated)
					placeTower = false
					get_node("cursor_placeholder").hide()
			elif (ev.button_index == BUTTON_RIGHT):
				# Cancel action
				_on_cancel_pressed()

### Signals ###

func _on_cancel_pressed():
	placeTower = false
	get_node("cursor_placeholder").hide()
	budget_current += last_transaction
	budget.set_text("Budget: " + str(budget_current))
