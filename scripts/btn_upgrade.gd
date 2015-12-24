extends Button

### Variables ###

# Nodes
var global
var hud # The HUD node
var tooltip # The tower tooltip

# Characteristics
export var upgrade_price = 100
export var upgrade_scene = preload("res://scenes/towers/tower_upgrade.tscn")

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	hud = global.hud
	tooltip = hud.get_node("tower_tooltip")
	
	if hud.budget_current < upgrade_price:
		set_disabled(true)

### Signals ###

func _on_btn_tower_mouse_enter():
	tooltip.set_pos(get_pos() + Vector2(get_size().x + 10, get_parent().get_pos().y))
	tooltip.get_node("name").set_text("Upgrade")
	tooltip.get_node("damage").set_text("")
	tooltip.get_node("range").set_text("")
	tooltip.get_node("reload").set_text("")
	tooltip.get_node("price").set_text("Price: " + str(upgrade_price))
	tooltip.show()

func _on_btn_tower_mouse_exit():
	tooltip.hide()

func _on_btn_tower_pressed():
	hud.tower_upgrade_mode(upgrade_scene, upgrade_price)
