extends Control

var tower_desc
var budget
var health
var health_current = 1000
var budget_current = 1000
var placeTower = false
var level_offset_x = 0
var level_offset_y = 0
var tile_size = 32 # FIXME , get it from level node
var level_size_h = 22 * tile_size # FIXME tile h count * tile size
var level_size_v = 18 * tile_size # FIXME tile h count * tile size

func _ready():
	budget = get_node("Budget")
	budget.set_text("Budget: "+str(budget_current))
	tower_desc = get_node("Tower_desc")
	health = get_node("health_label")
	health.set_text("Health: "+str(health_current))
	tower_desc.hide()
	level_offset_x = get_node("/root/Game/Level").get_pos().x
	level_offset_y = get_node("/root/Game/Level").get_pos().y
	set_process_input(true)
	
	
func updateBudget(amount):
	budget_current += amount
	budget.set_text("Budget: "+str(budget_current))
	for button in get_node("Towers").get_children():
		if button.tower_price > budget_current:
			button.set_disabled(true)
		else:
			button.set_disabled(false)
			
func updateHealth(amount):
	health_current += amount
	health.set_text("Health: "+str(health_current))

func _input(ev):
	if placeTower and ev.type == InputEvent.MOUSE_MOTION and ev.pos.x > level_offset_x and ev.pos.x < level_size_h and ev.pos.y > level_offset_y and ev.pos.y < level_size_v:
		get_node("cursor_placeholder").set_pos(ev.pos)
		print(get_node("/root/Game/Level").tiles[Vector2(floor((ev.pos.x-level_offset_x)/tile_size),floor((ev.pos.y+level_offset_y)/tile_size))].type == preload("level.gd").Tile.TILE_BUILDABLE)
		if get_node("/root/Game/Level").tiles[Vector2(floor((ev.pos.x-level_offset_x)/tile_size),floor((ev.pos.y+level_offset_y)/tile_size))].type == preload("level.gd").Tile.TILE_BUILDABLE:
			get_node("cursor_placeholder").set_frame(1)
		else:
			get_node("cursor_placeholder").set_frame(0)


func _on_cancel_pressed():
	placeTower = false
	get_node("cursor_placeholder").hide()