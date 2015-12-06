extends Control

var tower_desc
var budget
var health
var health_current = 1000
var budget_current = 1000
var placeTower = false

func _ready():
	budget = get_node("Budget")
	budget.set_text("Budget: "+str(budget_current))
	tower_desc = get_node("Tower_desc")
	health = get_node("health_label")
	health.set_text("Health: "+str(health_current))
	tower_desc.hide()
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
	if placeTower and ev.type == InputEvent.MOUSE_MOTION:
		get_node("cursor_placeholder").set_pos(ev.pos)

func _on_cancel_pressed():
	placeTower = false
	get_node("cursor_placeholder").hide()