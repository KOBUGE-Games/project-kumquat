extends Button

### Variables ###

# Nodes
var global
var hud # The HUD node
var tooltip # The tower tooltip

# Characteristics
export var upgrade_scene = preload("res://towers/drop_upgrade/drop_upgrade.tscn")

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	hud = global.hud
	tooltip = hud.get_node("tower_tooltip")

### Signals ###

func _on_btn_tower_mouse_enter():
	get_node("animation").play("reflection")
	tooltip.set_pos(get_pos() + Vector2(get_size().x + 10, get_parent().get_pos().y))
	tooltip.get_node("name").set_text("Upgrade")
	tooltip.get_node("damage").set_text("")
	tooltip.get_node("range").set_text("")
	tooltip.get_node("reload").set_text("")
	tooltip.get_node("price").set_text("Price: Depends")
	tooltip.show()

func _on_btn_tower_mouse_exit():
	get_node("animation").stop()
	get_node("icon").set_frame(0)
	tooltip.hide()

func _on_btn_tower_pressed():
	hud.tower_upgrade_mode(upgrade_scene)
