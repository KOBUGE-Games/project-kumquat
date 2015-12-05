extends Control

var tower_desc
var budget
var budget_current = 1000

func _ready():
	budget = get_node("Budget")
	budget.set_text("Budget: "+str(budget_current))
	tower_desc = get_node("Tower_desc")
	tower_desc.hide()
	
	
func updateBudget(amount):
	budget_current += amount
	budget.set_text("Budget: "+str(budget_current))
	for button in get_node("Towers").get_children():
		if button.tower_price > budget_current:
			button.set_disabled(true)
		else:
			button.set_disabled(false)