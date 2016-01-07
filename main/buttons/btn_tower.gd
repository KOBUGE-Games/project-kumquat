extends Button

### Variables ###

# Nodes
var global
var hud # The HUD node
var tooltip # The tower tooltip

# Characteristics
export(PackedScene) var tower_scene
var tower_name = "Unnamed"
var tower_damage = 100
var tower_range = 100
var tower_price = 100
var tower_reload = 1

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	hud = global.hud
	tooltip = hud.get_node("tower_tooltip")

	set_attributes_from_tower_scene(tower_scene)
	get_node("label").set_text(tower_name)
	
	if hud.budget_current < tower_price:
		set_disabled(true)

### Functions ###

func set_attributes_from_tower_scene(tower_scene):
	var tower = tower_scene.instance()
	get_node("icon").set_texture(tower.get_node("sprite").get_texture())
	
	var tier = tower.get_tier(1)
	tower_name = tier.name
	tower_damage = tier.damage
	tower_range = tier.reach
	tower_reload = tier.frequency
	tower_price = tier.price

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
	hud.tower_build_mode(tower_scene)
