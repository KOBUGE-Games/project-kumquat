extends Control

### Variables ###

# Nodes
var level
var budget
var health
var tower_desc

var budget_current = 1000
var health_current = 1000
var placeTower = false
var level_offset = Vector2()
var tile_size = 32 # FIXME , get it from level node
var level_size_h = 22*tile_size # FIXME tile h count * tile size
var level_size_v = 18*tile_size # FIXME tile h count * tile size

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
	if (placeTower and ev.type == InputEvent.MOUSE_MOTION
			and ev.pos.x > level_offset.x and ev.pos.x < level_size_h
			and ev.pos.y > level_offset.y and ev.pos.y < level_size_v):
		get_node("cursor_placeholder").set_pos(ev.pos)
		
		if (level.tiles[Vector2(floor((ev.pos.x-level_offset.x)/tile_size),floor((ev.pos.y+level_offset.y)/tile_size))].type == level.Tile.TILE_BUILDABLE):
			get_node("cursor_placeholder").set_frame(1)
		else:
			get_node("cursor_placeholder").set_frame(0)

func _on_cancel_pressed():
	placeTower = false
	get_node("cursor_placeholder").hide()
