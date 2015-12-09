extends Button

### Variables ###

# Nodes
var global
var hud # The HUD node

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
	if hud.budget_current < tower_price:
		set_disabled(true)

### Signals ###

func _on_btn_tower_mouse_enter():
	hud.tower_desc.set_pos(get_pos() + Vector2(get_size().x + 10, get_parent().get_pos().y))
	var panel = hud.get_node("tower_desc/panel")
	panel.get_node("tower_name").set_text(tower_name)
	panel.get_node("tower_damage").set_text("Damage: " + str(tower_damage))
	panel.get_node("tower_range").set_text("Range: " + str(tower_range))
	panel.get_node("tower_reload").set_text("Reload: " + str(tower_reload))
	panel.get_node("tower_price").set_text("Price: " + str(tower_price))
	hud.tower_desc.show()

func _on_btn_tower_mouse_exit():
	hud.tower_desc.hide()

func _on_btn_tower_pressed():
	hud.tower_build_mode(self)
