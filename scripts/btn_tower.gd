extends Button

### Variables ###

# Nodes
var global
var hud # The HUD node
var tooltip # The tower tooltip

# Characteristics
export var tower_name = "Unnamed"
export var tower_scene_name = "tower1"
export var tower_damage = 100
export var tower_range = 100
export var tower_reload = 1
export var tower_price = 100
var tower_scene = load("res://scenes/towers/" + tower_scene_name + ".xscn")

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	hud = global.hud
	tooltip = hud.get_node("tower_tooltip")
	if hud.budget_current < tower_price:
		set_disabled(true)

### Signals ###

func _on_btn_tower_mouse_enter():
	tooltip.set_pos(get_pos() + Vector2(get_size().x + 10, get_parent().get_pos().y))
	tooltip.get_node("name").set_text(tower_name)
	tooltip.get_node("damage").set_text("Damage: " + str(tower_damage))
	tooltip.get_node("range").set_text("Range: " + str(tower_range))
	tooltip.get_node("reload").set_text("Reload: " + str(tower_reload))
	tooltip.get_node("price").set_text("Price: " + str(tower_price))
	tooltip.show()

func _on_btn_tower_mouse_exit():
	tooltip.hide()

func _on_btn_tower_pressed():
	hud.tower_build_mode(tower_scene, tower_price)
