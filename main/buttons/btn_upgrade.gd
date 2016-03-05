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
	tooltip.show_data(self, {
		name = "Upgrade",
		price = "Depends"
	})

func _on_btn_tower_mouse_exit():
	get_node("animation").stop()
	get_node("icon").set_frame(0)
	tooltip.hide_data()

func _on_btn_tower_pressed():
	hud.tower_upgrade_mode(upgrade_scene)
